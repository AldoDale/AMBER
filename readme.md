
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

#### Returns: a qualityCheck object

```r
#An object of class "qualityCheck"
#Slot "fwd_qplot":
#
#Slot "rev_qplot":
#
#Slot "samples":
#                                            fwd                                           rev
#>1 ./man/example_dataset/Sample1_R1_001.fastq.gz ./man/example_dataset/Sample1_R2_001.fastq.gz
#>2 ./man/example_dataset/Sample2_R1_001.fastq.gz ./man/example_dataset/Sample2_R2_001.fastq.gz
#>3 ./man/example_dataset/Sample3_R1_001.fastq.gz ./man/example_dataset/Sample3_R2_001.fastq.gz
#>4 ./man/example_dataset/Sample4_R1_001.fastq.gz ./man/example_dataset/Sample4_R2_001.fastq.gz
#>5 ./man/example_dataset/Sample5_R1_001.fastq.gz ./man/example_dataset/Sample5_R2_001.fastq.gz
#>6 ./man/example_dataset/Sample6_R1_001.fastq.gz ./man/example_dataset/Sample6_R2_001.fastq.gz
#>7 ./man/example_dataset/Sample7_R1_001.fastq.gz ./man/example_dataset/Sample7_R2_001.fastq.gz
#
#Slot "pattern":
#[1] "_R1_001.fastq.gz" "_R2_001.fastq.gz"
```

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

#### Returns: a filteredSamples object

```r
#An object of class "filteredSamples"
#Slot "samples":
#  sample_name                                                          fwd                                                          rev
#>1     Sample1 ./man/example_dataset/filtered_reads/Sample1_R1_001.fastq.gz ./man/example_dataset/filtered_reads/Sample1_R2_001.fastq.gz
#>2     Sample2 ./man/example_dataset/filtered_reads/Sample2_R1_001.fastq.gz ./man/example_dataset/filtered_reads/Sample2_R2_001.fastq.gz
#>3     Sample3 ./man/example_dataset/filtered_reads/Sample3_R1_001.fastq.gz ./man/example_dataset/filtered_reads/Sample3_R2_001.fastq.gz
#>4     Sample4 ./man/example_dataset/filtered_reads/Sample4_R1_001.fastq.gz ./man/example_dataset/filtered_reads/Sample4_R2_001.fastq.gz
#>5     Sample5 ./man/example_dataset/filtered_reads/Sample5_R1_001.fastq.gz ./man/example_dataset/filtered_reads/Sample5_R2_001.fastq.gz
#>6     Sample6 ./man/example_dataset/filtered_reads/Sample6_R1_001.fastq.gz ./man/example_dataset/filtered_reads/Sample6_R2_001.fastq.gz
#>7     Sample7 ./man/example_dataset/filtered_reads/Sample7_R1_001.fastq.gz ./man/example_dataset/filtered_reads/Sample7_R2_001.fastq.gz
#
#Slot "stats":
#                        reads.in reads.out
#Sample1_R1_001.fastq.gz    96584     65208
#Sample2_R1_001.fastq.gz    56704     36015
#Sample3_R1_001.fastq.gz   148093     98695
#Sample4_R1_001.fastq.gz   121245     82491
#Sample5_R1_001.fastq.gz     1208       240
#Sample6_R1_001.fastq.gz    76151     52338
#Sample7_R1_001.fastq.gz    79085     49271

Slot "fwd_qplot":

Slot "rev_qplot":
```

<p align="center">
  <img src="https://github.com/AldoDale/AMBER/blob/main/man/example_figures/fwd_plot_trimmed.png" width="600" />
  <p align="center">
  <img src="https://github.com/AldoDale/AMBER/blob/main/man/example_figures/rev_plot_trimmed.png" width="600" />
</p>

By looking at the plots, we can see that the primers were correctly removed



### Merge reads and assign taxonomy

```

final <- mergeAndTaxonomy(x = trimmed, 
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

#### Returns: an finalObj

```r
An finalObj is a list of 3 data.frame: @df is a data.frame with ASVs information (sequence, taxonomy and abundance); @stats is a data.frame with information about taxonomic ranks; @clusteringstats is a data.frame with information of sequences filtering statistics.

#>final@df
#>
#> OTU
#> 1978  TAGGGAATATTCCACAATGGACGAAAGTCTGATGGAGCGACACAGCGTGCAGGATGAAGGCCTTATGGGTTGTAAACTGCTGTGGTAAGGGAATAAAAAATAGCATAGGAAATGATGTTATATTGAATGTACCTTATTAGAAAGCAACGGCTAACTATGTGCCAGCAGCCGCGGTAATACATAGGTTGCAAGCGTTATCCGGAATTATTGGGCGTAAAGCGTCTGTAGGTTGTTTGTTAAGTCTGGCGTTAAATTTTAGGGCTCAACCCTAACACGCGTTGGATACTGGCAAACTAGAGTTATGTAGAGGTTAGCGGAATTCCTTGTGAAGCGGTGAAATGCGTAGATATAAGGAAGAACACCAACATGGCGAAGGCAGCTAACTGGACATATACTGACACTGAGAGACGAAAGCGTGGGGAGCAAACA
#> 15411                            TGGGGAATATTGGACAATGGGCGCAAGCCTGATCCAGCCATGCCGCGTGAGTGATGAAGGCCTTAGGGTTGTAAAGCTCTTTTATCCGGGACGATAATGACGGTACCGGAGGAATAAGCCCCGGCTAACTTCGTGCCAGCAGCCGCGGTAATACGAAGGGGGCTAGCGTTGCTCGGAATCACTGGGCGTAAAGGGCGCGTAGGCGGCGTTTTAAGTCGGGGGTGAAAGCCTGTGGCTCAACCACAGAATGGCCTTCGATACTGGGACGCTTGAGTATGGTAGAGGTTGGTGGAACTGCGAGTGTAGAGGTGAAATTCGTAGATATTCGCAAGAACACCGGTGGCGAAGGCGGCCAACTGGACCATTACTGACGCTGAGGCGCGAAAGCGTGGGGAGCAAACA
#> 5305                             TAGGGAATCTTGCGCAATGGGCGAAAGCCTGACGCAGCCATGCCGCGTGAATGATGAAGGTCTTAGGATTGTAAAATTCTTTCACCGGGGAAGATAATGACGGTACCCGGAGAAGAAGCCCCGGCTAACTTCGTGCCAGCAGCCGCGGTAATACGAAGGGGGCTAGCGTTGCTCGGAATTACTGGGCGTAAAGGGCGCGTAGGCGGATAGTTTAGTCAGAGGTAAAAGCCCAGGGCTCAACCTTGGAACTGCCTTTGATACTGGCTATCTTGAGTTCGGGAGAGGTGAGTGGAATGCCGAGTGTAGAGGTGAAATTCGTAGATATTCGGCGGAACACCAGTGGCGAAGGCGACTCACTGGCCCGATACTGACGCTGAGGCGCGAAAGCGTGGGGAGCAAACA
#> 10837                  TGGGGAATATTGCACAATGGGCGCAAGCCTGATGCAGCGACGCCGCGTGAGGGATGGAGGCCTTCGGGTTGTAAACCTCTTTTGTTAGGGAGCAAGGCACTTTGTGTTGAGTGTACCTTTCGAATAAGCACCGGCTAACTACGTGCCAGCAGCCGCGGTAATACGTAGGGTGCAAGCGTTATCCGGAATTATTGGGCGTAAAGGGCTCGTAGGCGGTTCGTCGCGTCCGGTGTGAAAGTCCATCGCTTAACGGTGGATCCGCGCCGGGTACGGGCGGGCTTGAGTGCGGTAGGGGAGACTGGAATTCCCGGTGTAACGGTGGAATGTGTAGATATCGGGAAGAACACCAATGGCGAAGGCAGGTCTCTGGGCCGTTACTGACGCTGAGGAGCGAAAGCGTGGGGAGCGAACA
#> 4887    TAGGGAATCTTCCGCAATGGGCGAAAGCCTGACGGAGCAACGCCGCGTGAGTGATGAAGGTCTTCGGATCGTAAAGCTCTGTTGTTAGGGAAGAACAAATGTGTAAGTAACTGTGCACATCTTGACGGTACCTAACCAGAAAGCCACGGCTAACTACGTGCCAGCAGCCGCGGTAATACGTAGGTGGCAAGCGTTATCCGGAATTATTGGGCGTAAAGCGCGCGTAGGCGGTTTTTTAAGTCTGATGTGAAAGCCCACGGCTCAACCGTGGAGGGTCATTGGAAACTGGAAAACTTGAGTGCAGAAGAGGAAAGTGGAATTCCATGTGTAGCGGTGAAATGCGCAGAGATATGGAGGAACACCAGTGGCGAAGGCGGCTTTCTGGTCTGCAACTGACGCTGATGTGCGAAAGCGTGGGGATCAAACA
#> 3592    TAGGGAATCTTCCACAATGGACGCAAGTCTGATGGAGCAACGCCGCGTGAGTGAAGAAGGTTTTCGGATCGTAAAGCTCTGTTGTTGGTGAAGAAGGATAGAGGTAGTAACTGGCCTTTATTTGACGGTAATCAACCAGAAAGTCACGGCTAACTACGTGCCAGCAGCCGCGGTAATACGTAGGTGGCAAGCGTTGTCCGGATTTATTGGGCGTAAAGCGAGCGCAGGCGGAAGAATAAGTCTGATGTGAAAGCCCTCGGCTTAACCGAGGAACTGCATCGGAAACTGTTTTTCTTGAGTGCAGAAGAGGAGAGTGGAACTCCATGTGTAGCGGTGGAATGCGTAGATATATGGAAGAACACCAGTGGCGAAGGCGGCTCTCTGGTCTGCAACTGACGCTGAGGCTCGAAAGCATGGGTAGCGAACA
#>        Sample Abundance   domain           phylum               class             order             family                          genus
#> 1978  Sample1     10259 Bacteria       Firmicutes             Bacilli   Mycoplasmatales   Mycoplasmataceae                     Mycoplasma
#> 15411 Sample6     10042 Bacteria   Proteobacteria Alphaproteobacteria       Rhizobiales   Beijerinckiaceae Methylobacterium-Methylorubrum
#> 5305  Sample6      7255 Bacteria   Proteobacteria Alphaproteobacteria   Caulobacterales   Caulobacteraceae               Phenylobacterium
#> 10837 Sample1      6195 Bacteria Actinobacteriota      Actinobacteria Bifidobacteriales Bifidobacteriaceae                Bifidobacterium
#> 4887  Sample6      4430 Bacteria       Firmicutes             Bacilli  Staphylococcales  Staphylococcaceae                 Staphylococcus
#> 3592  Sample1      4219 Bacteria       Firmicutes             Bacilli   Lactobacillales   Lactobacillaceae                  Lactobacillus


#> final@stats
#> domains    phyla  classes   orders families   genera     ASVs  samples 
#>       2       27       61      138      229      465     3096        7 


#> final@clusteringstats
#>
#>         input filtered denoisedF denoisedR merged nonchim finalPerc
#>Sample1  96584    65208     64186     64473  61142   59665 61.775242
#>Sample2  56704    36015     35258     35517  33170   32728 57.717269
#>Sample3 148093    98695     94832     96526  84228   79874 53.935027
#>Sample4 121245    82491     76251     79268  62740   58742 48.449008
#>Sample5   1208      240       131       116    108     108  8.940397
#>Sample6  76151    52338     51144     51794  49011   48166 63.250647
#>Sample7  79085    49271     48831     49109  47855   47034 59.472719
```

### Cleaning of the dataset and creation of the amberObj

```r
cleanObj <- makeitshiny(x = final,kd = "Bacteria",renameasvs = T,renamesamples = T,comp = T,rmSingletons = F,min_abun = 0.001)

# - x = a finalObj
# - kd = the domain the user whishes to keep (NULL if no filtering is required)
# - renameasvs = whether to rename the ASVs as "ASV-1", "ASV-2", etc.
# - renamesamples = whether to rename the samples as "Sample 1", "Sample 2", etc.
# - comp = whether to calculate the relative abundance of ASVs.
# - rmSingletons = whether to remove singletons
# - min_abun = whether to filter the dataset based on the abundance.

```

#### Returns: an amberObj

You can check the effects of the filtering using cleanObj@stats and see how many taxa you filtered out.

```r
#>head(cleanObj@df)
#>
#>OTU
#>1 TAGGGAATATTCCACAATGGACGAAAGTCTGATGGAGCGACACAGCGTGCAGGATGAAGGCCTTATGGGTTGTAAACTGCTGTGGTAAGGGAATAAAAAATAGCATAGGAAATGATGTTATATTGAATGTACCTTATTAGAAAGCAACGGCTAACTATGTGCCAGCAGCCGCGGTAATACATAGGTTGCAAGCGTTATCCGGAATTATTGGGCGTAAAGCGTCTGTAGGTTGTTTGTTAAGTCTGGCGTTAAATTTTAGGGCTCAACCCTAACACGCGTTGGATACTGGCAAACTAGAGTTATGTAGAGGTTAGCGGAATTCCTTGTGAAGCGGTGAAATGCGTAGATATAAGGAAGAACACCAACATGGCGAAGGCAGCTAACTGGACATATACTGACACTGAGAGACGAAAGCGTGGGGAGCAAACA
#>2                            TGGGGAATATTGGACAATGGGCGCAAGCCTGATCCAGCCATGCCGCGTGAGTGATGAAGGCCTTAGGGTTGTAAAGCTCTTTTATCCGGGACGATAATGACGGTACCGGAGGAATAAGCCCCGGCTAACTTCGTGCCAGCAGCCGCGGTAATACGAAGGGGGCTAGCGTTGCTCGGAATCACTGGGCGTAAAGGGCGCGTAGGCGGCGTTTTAAGTCGGGGGTGAAAGCCTGTGGCTCAACCACAGAATGGCCTTCGATACTGGGACGCTTGAGTATGGTAGAGGTTGGTGGAACTGCGAGTGTAGAGGTGAAATTCGTAGATATTCGCAAGAACACCGGTGGCGAAGGCGGCCAACTGGACCATTACTGACGCTGAGGCGCGAAAGCGTGGGGAGCAAACA
#>3                            TAGGGAATCTTGCGCAATGGGCGAAAGCCTGACGCAGCCATGCCGCGTGAATGATGAAGGTCTTAGGATTGTAAAATTCTTTCACCGGGGAAGATAATGACGGTACCCGGAGAAGAAGCCCCGGCTAACTTCGTGCCAGCAGCCGCGGTAATACGAAGGGGGCTAGCGTTGCTCGGAATTACTGGGCGTAAAGGGCGCGTAGGCGGATAGTTTAGTCAGAGGTAAAAGCCCAGGGCTCAACCTTGGAACTGCCTTTGATACTGGCTATCTTGAGTTCGGGAGAGGTGAGTGGAATGCCGAGTGTAGAGGTGAAATTCGTAGATATTCGGCGGAACACCAGTGGCGAAGGCGACTCACTGGCCCGATACTGACGCTGAGGCGCGAAAGCGTGGGGAGCAAACA
#>4                  TGGGGAATATTGCACAATGGGCGCAAGCCTGATGCAGCGACGCCGCGTGAGGGATGGAGGCCTTCGGGTTGTAAACCTCTTTTGTTAGGGAGCAAGGCACTTTGTGTTGAGTGTACCTTTCGAATAAGCACCGGCTAACTACGTGCCAGCAGCCGCGGTAATACGTAGGGTGCAAGCGTTATCCGGAATTATTGGGCGTAAAGGGCTCGTAGGCGGTTCGTCGCGTCCGGTGTGAAAGTCCATCGCTTAACGGTGGATCCGCGCCGGGTACGGGCGGGCTTGAGTGCGGTAGGGGAGACTGGAATTCCCGGTGTAACGGTGGAATGTGTAGATATCGGGAAGAACACCAATGGCGAAGGCAGGTCTCTGGGCCGTTACTGACGCTGAGGAGCGAAAGCGTGGGGAGCGAACA
#>5   TAGGGAATCTTCCGCAATGGGCGAAAGCCTGACGGAGCAACGCCGCGTGAGTGATGAAGGTCTTCGGATCGTAAAGCTCTGTTGTTAGGGAAGAACAAATGTGTAAGTAACTGTGCACATCTTGACGGTACCTAACCAGAAAGCCACGGCTAACTACGTGCCAGCAGCCGCGGTAATACGTAGGTGGCAAGCGTTATCCGGAATTATTGGGCGTAAAGCGCGCGTAGGCGGTTTTTTAAGTCTGATGTGAAAGCCCACGGCTCAACCGTGGAGGGTCATTGGAAACTGGAAAACTTGAGTGCAGAAGAGGAAAGTGGAATTCCATGTGTAGCGGTGAAATGCGCAGAGATATGGAGGAACACCAGTGGCGAAGGCGGCTTTCTGGTCTGCAACTGACGCTGATGTGCGAAAGCGTGGGGATCAAACA
#>6   TAGGGAATCTTCCACAATGGACGCAAGTCTGATGGAGCAACGCCGCGTGAGTGAAGAAGGTTTTCGGATCGTAAAGCTCTGTTGTTGGTGAAGAAGGATAGAGGTAGTAACTGGCCTTTATTTGACGGTAATCAACCAGAAAGTCACGGCTAACTACGTGCCAGCAGCCGCGGTAATACGTAGGTGGCAAGCGTTGTCCGGATTTATTGGGCGTAAAGCGAGCGCAGGCGGAAGAATAAGTCTGATGTGAAAGCCCTCGGCTTAACCGAGGAACTGCATCGGAAACTGTTTTTCTTGAGTGCAGAAGAGGAGAGTGGAACTCCATGTGTAGCGGTGGAATGCGTAGATATATGGAAGAACACCAGTGGCGAAGGCGGCTCTCTGGTCTGCAACTGACGCTGAGGCTCGAAAGCATGGGTAGCGAACA
#>    Sample Abundance   domain           phylum               class             order             family                          genus
#>1 Sample 1     10259 Bacteria       Firmicutes             Bacilli   Mycoplasmatales   Mycoplasmataceae                     Mycoplasma
#>2 Sample 2     10042 Bacteria   Proteobacteria Alphaproteobacteria       Rhizobiales   Beijerinckiaceae Methylobacterium-Methylorubrum
#>3 Sample 2      7255 Bacteria   Proteobacteria Alphaproteobacteria   Caulobacterales   Caulobacteraceae               Phenylobacterium
#>4 Sample 1      6195 Bacteria Actinobacteriota      Actinobacteria Bifidobacteriales Bifidobacteriaceae                Bifidobacterium
#>5 Sample 2      4430 Bacteria       Firmicutes             Bacilli  Staphylococcales  Staphylococcaceae                 Staphylococcus
#>6 Sample 1      4219 Bacteria       Firmicutes             Bacilli   Lactobacillales   Lactobacillaceae                  Lactobacillus
#>    ASV sample_total rel_abundance
#>1 ASV-1        51128    0.20065326
#>2 ASV-2        42547    0.23602134
#>3 ASV-3        42547    0.17051731
#>4 ASV-4        51128    0.12116648
#>5 ASV-5        42547    0.10412015
#>6 ASV-6        51128    0.08251839


#> cleanObj@stats
#>
#> domains    phyla  classes   orders families   genera     ASVs  samples 
#>       1       17       24       62      103      158      652        7 

```

### Check the number of sequences per sample

```r
readsNum <- count_reads(cleanObj)

```
#### Returns: a list of a named vector and a plot

```r
#>readsNum$data
#>
#>Sample 7 Sample 3 Sample 6 Sample 2 Sample 5 Sample 1 Sample 4 
#>     108    28754    42544    42547    43117    51128    60420 

#>readsNum$plot
```
















