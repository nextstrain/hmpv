We gratefully acknowledge the authors, originating and submitting laboratories of the genetic sequences and metadata for sharing their work via INSDC or Pathoplexus. Please note that data from Pathoplexus comes with specific data use terms that need to be abided by. If data are shared under RESTRICTED terms, you can not use these data in publications without collaborating with the group that generated the data, please consult the [Data Use Terms of Pathoplexus](https://pathoplexus.org/about/terms-of-use/restricted-data) for details. Even if data are shared without restrictions, that does not mean there should be free license to publish on this data. Data generators should be cited where possible and collaborations should be sought in some circumstances. Please try to avoid scooping someone else's work. Reach out if uncertain.

#### Analysis

Our bioinformatic processing workflow can be found at [github.com/nextstrain/hmpv](https://github.com/nextstrain/hmpv) and includes:

- sequence alignment by a combination of [Nextclade](https://docs.nextstrain.org/projects/nextclade/en/stable/user/nextclade-cli.html) and [MAFFT](https://mafft.cbrc.jp/alignment/software/).
- phylogenetic reconstruction using [IQTREE](http://www.iqtree.org/)
- ancestral state reconstruction and temporal inference using [TreeTime](https://github.com/neherlab/treetime)
- reconstruction of amino acid mutations in the [F protein epitopes](https://pmc.ncbi.nlm.nih.gov/articles/PMC10421620/#R12)
- clade assignment via clade definitions derived from the literature.

#### Underlying data

We source sequence data and metadata from [Pathoplexus](https://pathoplexus.org) which ingests data from INSDC and provides data from INSDC together with data that were submitted directly to Pathoplexus. See our [ingest configuration file](https://github.com/nextstrain/hmpv/blob/master/ingest/config/config.yaml).
Curated sequences and metadata are available as flat files at the links below.
The data in the files provided below is the subset of data from Pathoplexus under the OPEN [data use terms](https://pathoplexus.org/about/terms-of-use/data-use-terms). In the metadata files below, each sequence contains a field specifying the data use terms of this sequence and a link to the data use terms.

- [sequences](https://data.nextstrain.org/files/workflows/hmpv/sequences.fasta.xz)
- [metadata](https://data.nextstrain.org/files/workflows/hmpv/metadata.tsv.gz)

 If you are interested in the RESTRICTED USE data, we ask you to obtain those directly from Pathoplexus.
