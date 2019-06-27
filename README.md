# x-seq

scripts for high-throuput sequencing data analysis (RNA-seq, miRNA-seq, smallRNA-seq, and etc.)

## Requirements

* ruby > 2.5.1
* R    > 3.4.4
  * Biocoundctor (edgeR)
  * tidyverse
  * gplots (for heatmap.2)
* annotation.txt; The tab delimited annotation list that should have GeneSymbol at first column.
* sample_list.txt; The tab delimited list of sampleId'\t'groupId
* comp_list.txt; The list of control groupId vs sample groupId

### for calculate_deg.rb
* RSEM (v1.3.1) = ~/src/RSEM-1.3.1
  * ./RSEM directory stored sampleId.genes.results

### for gseq_x_seq.rb
* GSEA (v3.0) = ~/src/GSEA/gsea-3.0.jar

## Installation

Git clone to your ~/src directory.

```
$ cd ~/src
$ git clone https://github.com/ash4doi/x-seq
```

## Usage

```
$ ls -1
RSEM
annotation.txt
comp_list.txt
sample_list.txt
$ ruby ~/src/x-seq/calculate_deg.rb
```
