rule download:
    message: "downloading sequences and metadata from data.nextstrain.org"
    output:
        metadata =  "data/metadata.tsv.gz",
        sequences = "data/sequences.fasta.xz"
    params:
        metadata_url = "http://data.nextstrain.org/files/workflows/hmpv/metadata.tsv.gz",
        sequence_url = "http://data.nextstrain.org/files/workflows/hmpv/sequences.fasta.xz"
    shell:
        """
        curl -fsSL --compressed {params.metadata_url:q} --output {output.metadata}
        curl -fsSL --compressed {params.sequence_url:q} --output {output.sequences}
        """

rule decompress:
    message: "decompressing sequences and metadata"
    input:
        sequences = "data/sequences.fasta.xz",
        metadata = "data/metadata.tsv.gz"
    output:
        sequences = "data/sequences.fasta",
        metadata = "data/metadata.tsv"
    shell:
        """
        gzip --decompress --keep {input.metadata}
        xz --decompress --keep {input.sequences}
        """
