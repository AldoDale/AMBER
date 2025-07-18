<p align="center">
  <img src="https://github.com/AldoDale/AMBER/blob/main/man/example_figures/logo.png" width="600" />
</p>

# AMBER: Analysis of Microbial Barcodes for Ecological Research

AMBER provides a series of functions to pre-process NGS-derived sequences and to obtain information about microbial communities composition and statistics.

## Installation

```r
remotes::install_github("AldoDale/AMBER")
```
---

## How to use

An example dataset is available at https://github.com/AldoDale/AMBER/tree/main/man/example_dataset.

---

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

---

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

---

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

#### Returns: an amberobj

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

---

### Cleaning of the dataset and creation of the amberobj

```r
cleanObj <- makeitshiny(x = final,kd = "Bacteria",renameasvs = T,renamesamples = T,comp = T,rmSingletons = F,min_abun = 0.001)

# arguments

# - x = a finalObj
# - kd = the domain the user whishes to keep (NULL if no filtering is required)
# - renameasvs = whether to rename the ASVs as "ASV-1", "ASV-2", etc.
# - renamesamples = whether to rename the samples as "Sample 1", "Sample 2", etc.
# - comp = whether to calculate the relative abundance of ASVs.
# - rmSingletons = whether to remove singletons
# - min_abun = whether to filter the dataset based on the abundance.

```

#### Returns: an amberobj

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

---

### Check the number of sequences per sample

```r
readsNum <- count_reads(cleanObj)

```
#### Returns: a list of a named vector, containing the number of reads per sample, and a plot.

```r
#>readsNum$data
#>
#>Sample 7 Sample 3 Sample 6 Sample 2 Sample 5 Sample 1 Sample 4 
#>     108    28754    42544    42547    43117    51128    60420 

#>readsNum$plot
```

<p align="center">
  <img src="https://github.com/AldoDale/AMBER/blob/main/man/example_figures/readsNum.png" width="600" />
</p>

---

### Filter the dataset

#### Reads number and/or sample name-based filtering

```r
cleanObj <- filter_dataset(object = cleanObj, sampnames = F, min_reads = 5000)


# arguments

# - x = an amberobj
# - sampnames = a string or vector of strings with sample names to remove from the dataset.
# - min_reads = numeric. The minimum number of reads a sample must have to be kept.
```

we can see that we filtered out one sample (Sample 7)
```r
#> cleanObj@stats
#>
#> domains    phyla  classes   orders families   genera     ASVs  samples 
#>       1       17       24       62      103      158      652        6 
```


#### Taxonomy-based filtering

```r

filter_taxonomy(x, ...)


# arguments

# - x = an amberobj
# - ... = a formula to be used (e.g., 'genus == "Bifidobacterium"')
```

#### Example

```r

onlybifido <- filter_taxonomy(cleanObj, genus == "Bifidobacterium")

#> head(onlybifido@df)
#>                                                                                                                                                                                                                                                                                                                                                                                                                           OTU
#>1 TGGGGAATATTGCACAATGGGCGCAAGCCTGATGCAGCGACGCCGCGTGAGGGATGGAGGCCTTCGGGTTGTAAACCTCTTTTGTTAGGGAGCAAGGCACTTTGTGTTGAGTGTACCTTTCGAATAAGCACCGGCTAACTACGTGCCAGCAGCCGCGGTAATACGTAGGGTGCAAGCGTTATCCGGAATTATTGGGCGTAAAGGGCTCGTAGGCGGTTCGTCGCGTCCGGTGTGAAAGTCCATCGCTTAACGGTGGATCCGCGCCGGGTACGGGCGGGCTTGAGTGCGGTAGGGGAGACTGGAATTCCCGGTGTAACGGTGGAATGTGTAGATATCGGGAAGAACACCAATGGCGAAGGCAGGTCTCTGGGCCGTTACTGACGCTGAGGAGCGAAAGCGTGGGGAGCGAACA
#>2 TGGGGAATATTGCACAATGGGCGCAAGCCTGATGCAGCGACGCCGCGTGAGGGATGGAGGCCTTCGGGTTGTAAACCTCTTTTGTTAGGGAGCAAGGCACTTTGTGTTGAGTGTACCTTTCGAATAAGCACCGGCTAACTACGTGCCAGCAGCCGCGGTAATACGTAGGGTGCAAGCGTTATCCGGAATTATTGGGCGTAAAGGGCTCGTAGGCGGTTCGTCGCGTCCGGTGTGAAAGTCCATCGCTTAACGGTGGATCCGCGCCGGGTACGGGCGGGCTTGAGTGCGGTAGGGGAGACTGGAATTCCCGGTGTAACGGTGGAATGTGTAGATATCGGGAAGAACACCAATGGCGAAGGCAGGTCTCTGGGCCGTTACTGACGCTGAGGAGCGAAAGCGTGGGGAGCGAACA
#>3 TGGGGAATATTGCACAATGGGCGCAAGCCTGATGCAGCGACGCCGCGTGAGGGATGGAGGCCTTCGGGTTGTAAACCTCTTTTGTTAGGGAGCAAGGCACTTTGTGTTGAGTGTACCTTTCGAATAAGCACCGGCTAACTACGTGCCAGCAGCCGCGGTAATACGTAGGGTGCAAGCGTTATCCGGAATTATTGGGCGTAAAGGGCTCGTAGGCGGTTCGTCGCGTCCGGTGTGAAAGTCCATCGCTTAACGGTGGATCCGCGCCGGGTACGGGCGGGCTTGAGTGCGGTAGGGGAGACTGGAATTCCCGGTGTAACGGTGGAATGTGTAGATATCGGGAAGAACACCAATGGCGAAGGCAGGTCTCTGGGCCGTTACTGACGCTGAGGAGCGAAAGCGTGGGGAGCGAACA
#>4 TGGGGAATATTGCACAATGGGCGCAAGCCTGATGCAGCGACGCCGCGTGAGGGATGGAGGCCTTCGGGTTGTAAACCTCTTTTGTTAGGGAGCAAGGCACTTTGTGTTGAGTGTACCTTTCGAATAAGCACCGGCTAACTACGTGCCAGCAGCCGCGGTAATACGTAGGGTGCAAGCGTTATCCGGAATTATTGGGCGTAAAGGGCTCGTAGGCGGTTCGTCGCGTCCGGTGTGAAAGTCCATCGCTTAACGGTGGATCCGCGCCGGGTACGGGCGGGCTTGAGTGCGGTAGGGGAGACTGGAATTCCCGGTGTAACGGTGGAATGTGTAGATATCGGGAAGAACACCAATGGCGAAGGCAGGTCTCTGGGCCGTTACTGACGCTGAGGAGCGAAAGCGTGGGGAGCGAACA
#>5 TGGGGAATATTGCACAATGGGCGCAAGCCTGATGCAGCGACGCCGCGTGAGGGATGGAGGCCTTCGGGTTGTAAACCTCTTTTGTTAGGGAGCAAGGCACTTTGTGTTGAGTGTACCTTTCGAATAAGCACCGGCTAACTACGTGCCAGCAGCCGCGGTAATACGTAGGGTGCAAGCGTTATCCGGAATTATTGGGCGTAAAGGGCTCGTAGGCGGTTCGTCGCGTCCGGTGTGAATGTCCATCGCTTAACGGTGGATCCGCGCCGGGTACGGGCGGGCTTGAGTGCGGTAGGGGAGACTGGAATTCCCGGTGTAACGGTGGAATGTGTAGATATCGGGAAGAACACCAATGGCGAAGGCAGGTCTCTGGGCCGTTACTGACGCTGAGGAGCGAAAGCGTGGGGAGCGAACA
#>6 TGGGGAATATTGCACAATGGGCGCAAGCCTGATGCAGCGACGCCGCGTGAGGGATGGAGGCCTTCGGGTTGTAAACCTCTTTTGTTAGGGAGCAAGGCACTTTGTGTTGAGTGTACCTTTCGAATAAGCACCGGCTAACTACGTGCCAGCAGCCGCGGTAATACGTAGGGTGCAAGCGTTATCCGGAATTATTGGGCGTAAAGGGCTCGTAGGCGGTTCGTCGCGTCCGGTGTGAAAGTCCATCGCTTAACGGTGGATCCGCGCCGGGTACGGGCGGGCTTGAGTGCGGTAGGGGAGACTGGAATTCCCGGTGTAACGGTGGAATGTGTAGATATCGGGAAGAACACCAATGGCGAAGGCAGGTCTCTGGGCCGTTACTGACGCTGAGGAGCGAAAGCGTGGGGAGCGAACA
#>    Sample Abundance   domain           phylum          class             order             family           genus    ASV sample_total
#>1 Sample 1      6195 Bacteria Actinobacteriota Actinobacteria Bifidobacteriales Bifidobacteriaceae Bifidobacterium  ASV-4        51128
#>2 Sample 3      3761 Bacteria Actinobacteriota Actinobacteria Bifidobacteriales Bifidobacteriaceae Bifidobacterium  ASV-4        28754
#>3 Sample 4      3627 Bacteria Actinobacteriota Actinobacteria Bifidobacteriales Bifidobacteriaceae Bifidobacterium  ASV-4        60420
#>4 Sample 2       911 Bacteria Actinobacteriota Actinobacteria Bifidobacteriales Bifidobacteriaceae Bifidobacterium  ASV-4        42547
#>5 Sample 5       432 Bacteria Actinobacteriota Actinobacteria Bifidobacteriales Bifidobacteriaceae Bifidobacterium ASV-79        43117
#>6 Sample 6       276 Bacteria Actinobacteriota Actinobacteria Bifidobacteriales Bifidobacteriaceae Bifidobacterium  ASV-4        42544
#>  rel_abundance
#>1   0.121166484
#>2   0.130799193
#>3   0.060029791
#>4   0.021411615
#>5   0.010019250
#>6   0.006487401



#>onlybifido@stats
#>
#> domains    phyla  classes   orders families   genera     ASVs  samples 
#>       1        1        1        1        1        1        4        6 
```

---

### To test the next functions we will need dummy metadata

```r

cleanObj@df[cleanObj@df$Sample %in% c("Sample 1", "Sample 2", "Sample 3"),"treatment"] <- "treatment_1"
cleanObj@df[cleanObj@df$Sample %in% c("Sample 4", "Sample 5", "Sample 6"),"treatment"] <- "treatment_2"

cleanObj@df[cleanObj@df$Sample %in% c("Sample 1", "Sample 2"),"site"] <- "site_1"
cleanObj@df[cleanObj@df$Sample %in% c("Sample 3", "Sample 4"),"site"] <- "site_2"
cleanObj@df[cleanObj@df$Sample %in% c("Sample 5", "Sample 6"),"site"] <- "site_3"

```

---

### Alpha-diversity calculation

```r
calculate_diversities(object, group, indices, save.csv, facet, pal)

# arguments

# - object = an amberobj.

# - group = column to use to group samples (if NULL single samples will be taken into account).

# - indices = indices to calculate (if NULL all indices will be output).

# - save.csv = whether to save a csv with diversity values (T or F).

# - facet = column to use to split the plot.

# -pal = palette to use. Available palettes are: "pal.neon", "pal.scrubs", "pal.wwdits", "pal.wwdits2", "pal.pokemon", "pal.pokemon2", "pal.pokemon.legendaries"

```

#### example

```r
divs <- calculate_diversities(object = cleanObj, group = "site", indices = NULL, save.csv = F, pal = "pokemon")

#> divs@data
#>
#>     Sample     Description    value  Group
#>1  Sample 1        Observed 138.0000 site_1
#>2  Sample 1             ACE 138.0000 site_1
#>3  Sample 1         Shannon   3.4251 site_1
#>4  Sample 1   Simpson.gamma   0.0760 site_1
#>5  Sample 1    Gini.Simpson   0.9240 site_1
#>6  Sample 1 inverse.Simpson  13.1579 site_1
#>7  Sample 1           Chao1 138.0000 site_1
#>8  Sample 2        Observed 110.0000 site_1
#>9  Sample 2         Shannon   3.0238 site_1
#>10 Sample 2           Chao1 110.0000 site_1
#>11 Sample 2    Gini.Simpson   0.8930 site_1
#>12 Sample 2             ACE 110.0000 site_1
#>13 Sample 2 inverse.Simpson   9.3458 site_1
#>14 Sample 2   Simpson.gamma   0.1070 site_1
#>15 Sample 3        Observed 119.0000 site_2
#>16 Sample 3         Shannon   3.6818 site_2
#>17 Sample 3           Chao1 119.0000 site_2
#>18 Sample 3             ACE 119.0000 site_2
#>19 Sample 3   Simpson.gamma   0.0516 site_2
#>20 Sample 3    Gini.Simpson   0.9484 site_2
#>21 Sample 3 inverse.Simpson  19.3798 site_2
#>22 Sample 4        Observed 280.0000 site_2
#>23 Sample 4         Shannon   4.8011 site_2
#>24 Sample 4           Chao1 280.0000 site_2
#>25 Sample 4             ACE 280.0000 site_2
#>26 Sample 4   Simpson.gamma   0.0164 site_2
#>27 Sample 4    Gini.Simpson   0.9836 site_2
#>28 Sample 4 inverse.Simpson  60.9756 site_2
#>29 Sample 5           Chao1 266.0000 site_3
#>30 Sample 5        Observed 266.0000 site_3
#>31 Sample 5             ACE      NaN site_3
#>32 Sample 5         Shannon   5.1446 site_3
#>33 Sample 5   Simpson.gamma   0.0108 site_3
#>34 Sample 5    Gini.Simpson   0.9892 site_3
#>35 Sample 5 inverse.Simpson  92.5926 site_3
#>36 Sample 6   Simpson.gamma   0.0101 site_3
#>37 Sample 6        Observed 300.0000 site_3
#>38 Sample 6         Shannon   5.1886 site_3
#>39 Sample 6           Chao1 300.0000 site_3
#>40 Sample 6    Gini.Simpson   0.9899 site_3
#>41 Sample 6             ACE 300.0000 site_3
#>42 Sample 6 inverse.Simpson  99.0099 site_3


#>divs@plot
```

<p align="center">
  <img src="https://github.com/AldoDale/AMBER/blob/main/man/example_figures/diversities_plot.png" width="600" />
</p>

---

### Redundancy analysis

This function allows to process the dataset for the Redundancy Analysis. It outputs a plot (either showing samples position or samples and species) together
with the results of the RDA and PERMANOVA tests.

```r

plot_rda(x, group, condition = F, comp = F, showtoptaxa = NULL, rm.uncl = F, plotfill = NULL,taxlevel = NULL, nperm = 999)


# arguments

# - x = an amberobj.

# - group = column with the group to test.

# - condition = the factor to use as a condition for the RDA. It can be either F or a column of the dataframe. 

# - showtoptaxa = whether to show arrows with the RDA results for species. If not F, must be in this format: c(numberOfTaxa, taxonomicLevel)

# - rm.uncl = whether to take into account or not unclassified ASVs when showing species.

# - plotfill = dataframe column to use as factor for the coloring of points.

# - taxLevel = the taxonomic level to which merge the ASVs before the RDA analysis.

# - nperm = number of permutations.


```
##### Example

```r
plot_rda(x = cleanObj, group = "site",condition = "treatment",comp = T,showtoptaxa = c(10, "genus"), rm.uncl = T, plotfill = "site",taxlevel = NULL)

```

<p align="center">
  <img src="https://github.com/AldoDale/AMBER/blob/main/man/example_figures/rda.png" width="600" />
</p>

---

### Produce community composition barplots

```r
plot_bars(object,taxLevel,comp,group,facet, facet1,topx,fill_others,pal)


# arguments

# - x = an amberobj.

# - taxLevel = the taxonomic level to which merge the ASVs before the RDA analysis.

# - comp = whether to plot relative abundances.

# - group = column with the group to test.

# - facet = column to use to facet the plot

# - facet1 = second column to use to facet the plot

# - topx = number of taxa to plot.

# - fill_others = whether to fill remaining space with "others".

# - pal = palette to use.
```

#### Example

```r
plot_bars(object = cleanObj,taxLevel = "genus",comp =T ,
          group = "site",facet = "treatment",
          facet1 = NULL,topx = 25,fill_others = T,pal = "pokemon2")
          
```

<p align="center">
  <img src="https://github.com/AldoDale/AMBER/blob/main/man/example_figures/bars.png" width="600" />
</p>

---

### Plot heatmap and/or cluster analysis

```r
plot_heatmap(x,taxlevel,ntaxa,sampletip,nclust,cluster,showtaxanames,addTaxaNames,pal.highlight,pal.samples)


# arguments

# - x = an amberobj.

# - taxLevel = the taxonomic level to which merge the ASVs before the RDA analysis.

# - ntaxa = number of top most abundant taxa to plot.

# - sampletip = column to use to color the samples cluster analysis tip.

# - nclust = number of clusters to detect for the cluster analysis of taxa. Either a number or "auto" for automatic detection.

# - cluster = whether to cluste "samples", "asvs", or "all".

# - showtaxanames = whether to show taxa names on the y axis.

# - addTaxaNames = whether to add different taxonomic level information to the shown taxa.

# - pal.highlight = palette to use for taxa clusters.

# - pal.samples = palette to use for samples.
```

#### Examples

```r
plot_heatmap(x = cleanObj,taxlevel = NULL,ntaxa = 80,
             sampletip = "site",nclust = "auto",cluster = "all",showtaxanames = T,
             addTaxaNames = "genus",pal.highlight = "pokemon",pal.samples = "pokemon2")
```

<p align="center">
  <img src="https://github.com/AldoDale/AMBER/blob/main/man/example_figures/heatmap.png" width="600" />
</p>

```r
plot_heatmap(x = cleanObj,taxlevel = NULL,ntaxa = 80,
             sampletip = "site",nclust = 3,cluster = "asvs",showtaxanames = T,
             addTaxaNames = "genus",pal.highlight = "pokemon",pal.samples = "pokemon2")

```

<p align="center">
  <img src="https://github.com/AldoDale/AMBER/blob/main/man/example_figures/heatmapolyasv.png" width="600" />
</p>

```r
plot_heatmap(x = cleanObj,taxlevel = NULL,ntaxa = 80,
             sampletip = "site",nclust = 3,cluster = "all",showtaxanames = F,
             addTaxaNames = "genus",pal.highlight = "pokemon",pal.samples = "neon")
```

<p align="center">
  <img src="https://github.com/AldoDale/AMBER/blob/main/man/example_figures/heatmapolynonames.png" width="600" />
</p>

---

### Permanova and heatmap of results

Returns a list with a plot, a dissimilarity matrix, and the PERMANOVA results

```r
plot_anova(x,taxlevel,group,method)

# arguments

# - x = an amberobj object.

# - taxLevel = whether to agglomerate the dataset to a defined taxonomic level.

# - group = column of the dataframe to compare.

# - method = method to use for the dissimilarity matrix. Any method used in vegan::vegdist.

```

#### Example

```r

plot_anova(x = cleanObj,taxlevel = "phylum",group = "site",method = "gower")

#>$distmat
#>          Sample 1  Sample 2  Sample 3  Sample 4  Sample 5
#>Sample 2 0.3676148                                        
#>Sample 3 0.1890775 0.3389122                              
#>Sample 4 0.2622898 0.3610942 0.2648520                    
#>Sample 5 0.6987458 0.4612596 0.6873956 0.5818475          
#>Sample 6 0.5109374 0.4880023 0.4473122 0.2739819 0.5584089
#>
#>$anova
#>             pairs Df  SumsOfSqs   F.Model        R2   p.value p.adjusted sig  pair1  pair2 sign
#>1 site_1 vs site_2  1 0.03612738 0.7039381 0.2603381 1.0000000          1     site_1 site_2   ns
#>2 site_1 vs site_3  1 0.18831207 1.6852658 0.4572983 0.3333333          1     site_1 site_3   ns
#>3 site_2 vs site_3  1 0.17606160 1.8437358 0.4796729 0.3333333          1     site_2 site_3   ns

#>$plot
```
<p align="center">
  <img src="https://github.com/AldoDale/AMBER/blob/main/man/example_figures/anova plot.png" width="600" />
</p>

---

### Utility

#### Save plots

This function will create (if it doesen't exist yet) a directory called "figures" and will save the last plot produced in 3 different extensions (png, svg, ps).
```r
save.graph(filename, w, h)

# arguments

# - filename = the name to assign to the new file.

# - w = width of the image.

# - h = height of the image.

```

#### Sample palettes

This function will create a palette of the desired size from a shorter palette.
Can be accessed by using AMBER:::get.pal

```r
get.pal(x, pal)

# arguments

# - x = vector on which calculate the unique occurrences.

# - pal = palette to use.

```

#### Example

```r
#> AMBER:::get.pal(cleanObj@df$family, pal = pal.pokemon.legendaries)
#>
#>  [1] "#96BCDF" "#C0CBB1" "#EBDA83" "#F3C977" "#F0AE74" "#D9977B" "#B18389" "#A6849E" "#D1ACBF" "#F3CDD4" "#E1BD90"
#> [12] "#CEAD4C" "#B58A40" "#9B663A" "#8E7560" "#879B9B" "#88B0C0" "#94B3CC" "#A0A7C2" "#AB7279" "#B54234" "#A77856"
#> [23] "#99AE79" "#9FB08B" "#A9A69B" "#B0B2B6" "#B5CCDA" "#AAC8D9" "#8898A0" "#716F73" "#886C7B" "#9E6982" "#8D7D97"
#> [34] "#7993AD" "#5585AC" "#2C6AA2" "#3B5380" "#7D4048" "#9E3E2C" "#73634E" "#53896F" "#9DB27C" "#E8DA8A" "#E0BA82"
#> [45] "#CC8F78" "#C99178" "#D0AB7D" "#CEB388" "#C0A39A" "#AE98AA" "#8E9DB2" "#6EA3BA" "#6B90AA" "#687D9B" "#797B99"
#> [56] "#8F7F9C" "#8F7181" "#7E5550" "#7E5A48" "#9C998A" "#B4CABE" "#A19993" "#8E6867" "#9B878F" "#AAAEBF" "#9DBACC"
#> [67] "#83BACA" "#7DBBB5" "#8CBE8B" "#8DB165" "#63744E" "#3E3C39" "#6E6647" "#9E8F54" "#C1B47A" "#E1D7A4" "#BACEB2"
#> [78] "#64AAAF" "#3D8B9E" "#5B777A" "#786D5C" "#89965C" "#9BC05C" "#929F73" "#897A8A" "#8482A0" "#8099B5" "#949EA4"
#> [89] "#BD9270" "#D69260" "#C9ACA2" "#B9C0D8" "#828794" "#4C4E51" "#67686B" "#8F8F92" "#838696" "#5D6588" "#5E6C8B"
#>[100] "#91A8A3" "#B3CAB0" "#938E95" "#73537A"
```

---


#### Integration with R and other packages

Function to create an amberobj from a phyloseq or a data.frame (with a similar structure obtained from phyloseq::psmelt().

```r
build_amber(x)

# arguments

# - x = either a phyloseq object or a data.frame.

```

---

##Palettes

Here are shown the available palettes and their colors.

In order:

pal.neon

pal.scrubs (sampled from the tv show "scrubs")

pal.wwdits (sampled from the original poster of "what we do in the shadow")

pal.wwdits2 (sampled from the tv show "what we do in the shadow")

pal.pokemon (sampled from the first generation of pokemon)

pal.pokemon2 (sampled from the second generation of pokemon)

pal.pokemon.legendaries (sampled from the legendary pokemons)

<p align="center">
  <img src="https://github.com/AldoDale/AMBER/blob/main/man/example_figures/pal.neon.png" width="600" />
  <p align="center">
  <img src="https://github.com/AldoDale/AMBER/blob/main/man/example_figures/pal.scrubs.png" width="600" />
  <p align="center">
  <img src="https://github.com/AldoDale/AMBER/blob/main/man/example_figures/pal.wwdits.png" width="600" />
  <p align="center">
  <img src="https://github.com/AldoDale/AMBER/blob/main/man/example_figures/pal.wwdits2.png" width="600" />
  <p align="center">
  <img src="https://github.com/AldoDale/AMBER/blob/main/man/example_figures/pal.pokemon.png" width="600" />
  <p align="center">
  <img src="https://github.com/AldoDale/AMBER/blob/main/man/example_figures/pal.pokemon2.png" width="600" />
  <p align="center">
  <img src="https://github.com/AldoDale/AMBER/blob/main/man/example_figures/pal.pokemon.legendaries.png" width="600" />
</p>
