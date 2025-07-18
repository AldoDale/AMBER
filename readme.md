
# AMBER: Analysis of Microbial Barcodes for Ecological Research

AMBER provides a series of functions to pre-process NGS-derived sequences and to obtain information about microbial communities composition and statistics.


## Installation

```r
remotes::install_github("AldoDale/AMBER")
```
---

## How to use

An example dataset is available at #https://github.com/AldoDale/MarKUS/tree/main/MarKUS/man/example_dataset.


### Setup the samples

```r

samples_quality <- sample_setup(path = "./man/example_dataset", patternF = "_L001_R1_001.fastq.gz", patternR = "_L001_R2_001.fastq.gz", nplots = 3)


#arguments

#  - path = path to the directory containing the files.

#  - patternR = pattern to recognize the first (or forward) strand files.

#  - patternR = pattern to recognize the second (or reverse) strand files.

#  -nplots = the number of quality plots (for forward and reverse files) to display. This task is slow, a reduced number of plots (e.g., 3) is recommended.
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


### Trim sequences

```r

trimmed <- el_trimmador(x = samples_quality,
                        maxEE = c(2, 3),
                        fwd = "CCTACGGGNGGCWGCAG",
                        rev = "GACTACNVGGGTWTCTAATCC",
                        truncLen = c(280, 220),
                        truncQ = 2,
                        nplots = 2,
                        ncores = 1,
                        primerRemovalMethod = "cutadapt", 
                        cutadaptPath = "/usr/bin/cutadapt")


#arguments

#  - x = a qualityCheck object.

#  - maxEE = maximum number of expected errors allowed in a read.

#  - fwd = the sequence of the forward primer.

#  - rev = the sequence of the reverse primer.

#  - truncLen = the base number to truncate the sequence.

#  - truncQ = DADA2 truncQ.

#  - nplots = the number of quality plots to display.

#  - ncores = the number of cores to use. For Windows is 1.

#  - primerRemovalMethod = the method to use to remove primers (one between "dada" and "cutadapt").

#  - cutadaptPath = the path to cutadapt (it usually is "/usr/bin/cutadapt").

```

An object of class "filteredSamples"
Slot "samples":
  sample_name                                                          fwd                                                          rev
1     Sample1 ./man/example_dataset/filtered_reads/Sample1_R1_001.fastq.gz ./man/example_dataset/filtered_reads/Sample1_R2_001.fastq.gz
2     Sample2 ./man/example_dataset/filtered_reads/Sample2_R1_001.fastq.gz ./man/example_dataset/filtered_reads/Sample2_R2_001.fastq.gz
3     Sample3 ./man/example_dataset/filtered_reads/Sample3_R1_001.fastq.gz ./man/example_dataset/filtered_reads/Sample3_R2_001.fastq.gz
4     Sample4 ./man/example_dataset/filtered_reads/Sample4_R1_001.fastq.gz ./man/example_dataset/filtered_reads/Sample4_R2_001.fastq.gz
5     Sample5 ./man/example_dataset/filtered_reads/Sample5_R1_001.fastq.gz ./man/example_dataset/filtered_reads/Sample5_R2_001.fastq.gz
6     Sample6 ./man/example_dataset/filtered_reads/Sample6_R1_001.fastq.gz ./man/example_dataset/filtered_reads/Sample6_R2_001.fastq.gz
7     Sample7 ./man/example_dataset/filtered_reads/Sample7_R1_001.fastq.gz ./man/example_dataset/filtered_reads/Sample7_R2_001.fastq.gz

Slot "stats":
                        reads.in reads.out
Sample1_R1_001.fastq.gz    96584     65208
Sample2_R1_001.fastq.gz    56704     36015
Sample3_R1_001.fastq.gz   148093     98695
Sample4_R1_001.fastq.gz   121245     82491
Sample5_R1_001.fastq.gz     1208       240
Sample6_R1_001.fastq.gz    76151     52338
Sample7_R1_001.fastq.gz    79085     49271

Slot "fwd_qplot":

Slot "rev_qplot":


<p align="center">
  <img src="https://github.com/AldoDale/AMBER/blob/main/man/example_figures/fwd_plot_trimmed.png" width="600" />
  <p align="center">
  <img src="https://github.com/AldoDale/AMBER/blob/main/man/example_figures/rev_plot_trimmed.png" width="600" />
</p>

By looking at the plots, we can see that the primers were correctly removed



### Merge reads and assign taxonomy

```

finalObject <- mergeAndTaxonomy(x = trimmed, 
                          taxAssignment = "decipher",
                          taxonomy_file = "~/path/to/database",
                          metadataFile = NULL, ncores = 3)
                          
#arguments

#  - x = a filteredSamples object.

#  - taxAssignment = method to assign the taxonomy. At the moment only "decipher" is implemented. 

#  - taxonomy_file = The path to the taxonomy database (e.g., "SILVA_SSU_r138_2019.RData").

#  - metadataFile = path to the metadata file. It is recommended to use NULL and merge merge the metadata file later.

# - ncores = number of cores to use. For Windows is 1.
                          
```

