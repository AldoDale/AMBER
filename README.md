
# AMBER: Analysis of Microbial Barcodes for Ecological Research

AMBER provides a series of functions to pre-process NGS-derived
sequences and to obtain information about microbial communities
composition and statistics.

## Installation

``` r
remotes::install_github("AldoDale/AMBER")
```

------------------------------------------------------------------------

## How to use

An example dataset is available at
\#<https://github.com/AldoDale/MarKUS/tree/main/MarKUS/man/example_dataset>.

### Merge paired files

If the sequencing data is split in strand 1 and 2 (or forward and
reverse strand), the files should be first merged

``` r

samples_quality <- sample_setup("../../projects/neptune/fastq", patternF = "_L001_R1_001.fastq.gz", patternR = "_L001_R2_001.fastq.gz", nplots = 3)


#arguments

#  - path = path to the directory containing the files.

#  - pattern_s1 = pattern to recognize the first (or forward) strand files.

#  - pattern_s2 = pattern to recognize the second (or reverse) strand files.

#  -output_ext = the desired output extension (the same extension of input files is recommended).
```

An object of class “qualityCheck” Slot “fwd_qplot”:

Slot “rev_qplot”:

Slot “samples”: fwd rev 1 ./man/example_dataset/Sample1_R1_001.fastq.gz
./man/example_dataset/Sample1_R2_001.fastq.gz 2
./man/example_dataset/Sample2_R1_001.fastq.gz
./man/example_dataset/Sample2_R2_001.fastq.gz 3
./man/example_dataset/Sample3_R1_001.fastq.gz
./man/example_dataset/Sample3_R2_001.fastq.gz 4
./man/example_dataset/Sample4_R1_001.fastq.gz
./man/example_dataset/Sample4_R2_001.fastq.gz 5
./man/example_dataset/Sample5_R1_001.fastq.gz
./man/example_dataset/Sample5_R2_001.fastq.gz 6
./man/example_dataset/Sample6_R1_001.fastq.gz
./man/example_dataset/Sample6_R2_001.fastq.gz 7
./man/example_dataset/Sample7_R1_001.fastq.gz
./man/example_dataset/Sample7_R2_001.fastq.gz

Slot “pattern”: \[1\] “\_R1_001.fastq.gz” “\_R2_001.fastq.gz”

<p align="center">

<img src="AMBER/man/example_figures/fwd_plot.png" width="400" />
<img src="AMBER/man/example_figures/rev_plot.png" width="400" />
</p>

#### Returns: a data.frame

``` r

merged_files <- merge_pairs(path = "./example_dataset", pattern_s1 = "*_R1.fastq", "*_R2.fastq", output_ext = "fastq")

merged_files

#>       sample                              merged_path
#>1     Malta_1    ./example_dataset/Malta_1_merged.fastq
#>2     Malta_2    ./example_dataset/Malta_2_merged.fastq
#>3     Malta_3    ./example_dataset/Malta_3_merged.fastq
#>4     Malta_4    ./example_dataset/Malta_4_merged.fastq
#>5     Malta_5    ./example_dataset/Malta_5_merged.fastq
#>6  Portugal_1 ./example_dataset/Portugal_1_merged.fastq
#>7  Portugal_2 ./example_dataset/Portugal_2_merged.fastq
#>8  Portugal_3 ./example_dataset/Portugal_3_merged.fastq
#>9  Portugal_4 ./example_dataset/Portugal_4_merged.fastq
#>10 Portugal_5 ./example_dataset/Portugal_5_merged.fastq
#>11    Spain_1    ./example_dataset/Spain_1_merged.fastq
#>12    Spain_2    ./example_dataset/Spain_2_merged.fastq
#>13    Spain_3    ./example_dataset/Spain_3_merged.fastq
#>14    Spain_4    ./example_dataset/Spain_4_merged.fastq
#>15    Spain_5    ./example_dataset/Spain_5_merged.fastq
```

------------------------------------------------------------------------
