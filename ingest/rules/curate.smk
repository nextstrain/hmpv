"""
This part of the workflow handles transforming the data into standardized
formats and expects input file

    sequences_ndjson = "data/sequences.ndjson"

This will produce output files as

    metadata = "data/metadata.tsv"
    sequences = "data/sequences.fasta"

Parameters are expected to be defined in `config.transform`.
"""

rule fetch_general_geolocation_rules:
    output:
        general_geolocation_rules = "data/general-geolocation-rules.tsv"
    params:
        geolocation_rules_url = config['curate']['geolocation_rules_url']
    shell:
        """
        curl {params.geolocation_rules_url} > {output.general_geolocation_rules}
        """

rule concat_geolocation_rules:
    input:
        general_geolocation_rules = "data/general-geolocation-rules.tsv",
        local_geolocation_rules = config['curate']['local_geolocation_rules']
    output:
        all_geolocation_rules = "data/all-geolocation-rules.tsv"
    shell:
        """
        cat {input.general_geolocation_rules} {input.local_geolocation_rules} >> {output.all_geolocation_rules}
        """

rule curate:
    input:
        sequences_ndjson = "data/ncbi.ndjson",
        all_geolocation_rules = "data/all-geolocation-rules.tsv",
        annotations = config['curate']['annotations'],
    output:
        metadata = "data/curated_metadata.tsv",
        sequences = "data/sequences.fasta"
    log:
        "logs/curate.txt"
    params:
        field_map = config['curate']['field_map'],
        strain_regex = config['curate']['strain_regex'],
        strain_backup_fields = config['curate']['strain_backup_fields'],
        date_fields = config['curate']['date_fields'],
        expected_date_formats = config['curate']['expected_date_formats'],
        genbank_location_field=config["curate"]["genbank_location_field"],
        articles = config['curate']['titlecase']['articles'],
        abbreviations = config['curate']['titlecase']['abbreviations'],
        titlecase_fields = config['curate']['titlecase']['fields'],
        authors_field = config['curate']['authors_field'],
        authors_default_value = config['curate']['authors_default_value'],
        abbr_authors_field = config['curate']['abbr_authors_field'],
        annotations_id = config['curate']['annotations_id'],
        id_field = config['curate']['id_field'],
        sequence_field = config['curate']['sequence_field']
    shell:
        """
        (cat {input.sequences_ndjson} \
            | augur curate rename \
                --field-map {params.field_map} \
            | augur curate normalize-strings \
            | augur curate transform-strain-name \
                --strain-regex {params.strain_regex} \
                --backup-fields {params.strain_backup_fields} \
            | augur curate format-dates \
                --date-fields {params.date_fields} \
                --expected-date-formats {params.expected_date_formats} \
            | augur curate parse-genbank-location \
                --location-field {params.genbank_location_field} \
            | augur curate titlecase \
                --titlecase-fields {params.titlecase_fields} \
                --articles {params.articles} \
                --abbreviations {params.abbreviations} \
            | augur curate abbreviate-authors \
                --authors-field {params.authors_field} \
                --default-value {params.authors_default_value} \
                --abbr-authors-field {params.abbr_authors_field} \
            | augur curate apply-geolocation-rules \
                --geolocation-rules {input.all_geolocation_rules} \
            | augur curate apply-record-annotations \
                --annotations {input.annotations} \
                --id-field {params.annotations_id} \
                --output-fasta {output.sequences} \
                --output-metadata {output.metadata} \
                --output-id-field {params.id_field} \
                --output-seq-field {params.sequence_field} ) 2>> {log}
        """

rule subset_metadata:
    input:
        metadata = "data/curated_metadata.tsv",
    output:
        subset_metadata="data/metadata.tsv",
    params:
        metadata_fields=",".join(config["curate"]["metadata_columns"]),
    shell:
        """
        tsv-select -H -f {params.metadata_fields} \
            {input.metadata} > {output.subset_metadata}
        """

rule nextclade:
    input:
        sequences = rules.curate.output.sequences
    output:
        nextclade = "data/nextclade.tsv"
    params:
        output_columns = "seqName clade qc.overallScore qc.overallStatus alignmentScore  alignmentStart  alignmentEnd  coverage dynamic"
    threads: 8
    shell:
        """
        nextclade3 run --dataset-name hmpv  -j {threads} \
                          --output-columns-selection {params.output_columns} \
                          --output-tsv {output.nextclade} \
                          {input.sequences}
        """

rule extend_metadata:
    input:
        nextclade = rules.nextclade.output.nextclade,
        metadata = rules.subset_metadata.output.subset_metadata
    output:
        metadata = "data/extended_metadata.tsv"
    shell:
        """
        python3 scripts/extend-metadata.py --metadata {input.metadata} \
                                       --id-field accession \
                                       --nextclade {input.nextclade} \
                                       --output {output.metadata}
        """