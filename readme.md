
# AMBER: Analysis of Microbial Barcodes for Ecological Research

AMBER provides a series of functions to pre-process NGS-derived sequences and to obtain information about microbial communities composition and statistics.


## Installation

```r
remotes::install_github("AldoDale/AMBER")
```
---

## How to use

An example dataset is available at #https://github.com/AldoDale/MarKUS/tree/main/MarKUS/man/example_dataset.


### Merge paired files

If the sequencing data is split in strand 1 and 2 (or forward and reverse strand), the files should be first merged

```r

samples_quality <- sample_setup("./man/example_dataset", patternF = "_L001_R1_001.fastq.gz", patternR = "_L001_R2_001.fastq.gz", nplots = 3)


#arguments

#  - path = path to the directory containing the files.

#  - pattern_s1 = pattern to recognize the first (or forward) strand files.

#  - pattern_s2 = pattern to recognize the second (or reverse) strand files.

#  -output_ext = the desired output extension (the same extension of input files is recommended).
```

An object of class "qualityCheck"
Slot "fwd_qplot":

Slot "rev_qplot":

Slot "samples":
                                            fwd                                           rev
1 ./man/example_dataset/Sample1_R1_001.fastq.gz ./man/example_dataset/Sample1_R2_001.fastq.gz
2 ./man/example_dataset/Sample2_R1_001.fastq.gz ./man/example_dataset/Sample2_R2_001.fastq.gz
3 ./man/example_dataset/Sample3_R1_001.fastq.gz ./man/example_dataset/Sample3_R2_001.fastq.gz
4 ./man/example_dataset/Sample4_R1_001.fastq.gz ./man/example_dataset/Sample4_R2_001.fastq.gz
5 ./man/example_dataset/Sample5_R1_001.fastq.gz ./man/example_dataset/Sample5_R2_001.fastq.gz
6 ./man/example_dataset/Sample6_R1_001.fastq.gz ./man/example_dataset/Sample6_R2_001.fastq.gz
7 ./man/example_dataset/Sample7_R1_001.fastq.gz ./man/example_dataset/Sample7_R2_001.fastq.gz

Slot "pattern":
[1] "_R1_001.fastq.gz" "_R2_001.fastq.gz"


<p align="center">
  <img src="https://github.com/AldoDale/AMBER/blob/main/man/example_figures/fwd_plot.png" width="600" />
  <p align="center">
  <img src="https://github.com/AldoDale/AMBER/blob/main/man/example_figures/rev_plot.png" width="600" />
</p>
