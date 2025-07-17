#' Function to remove primers using cutadapt.
#'
#' @param object A "qualityCheck" object.
#' @param cutadaptPath Path where cutadapt is installed. Usually bin/cutadapt.
#' @param FWD Sequence of the forward primer.
#' @param REV Sequence of the reverse primer.
#' @param nproc Number of processors to use for parallelization. For windows set 1.
#'
#' @export
#' @return A cutadapted object.
setGeneric("removePrimersCutadapt", function(object,
                                             cutadaptPath = NULL,
                                             FWD = "CCTACGGGNGGCWGCAG",
                                             REV = "GACTACNVGGGTWTCTAATCC",
                                             nproc = F)
  standardGeneric("removePrimersCutadapt"))

setMethod("removePrimersCutadapt",
          signature("qualityCheck"),
          function(object, cutadaptPath, FWD, REV, nproc = F) {
            allOrients <- function(primer) {
              # Create all orientations of the input sequence
              dna <- Biostrings::DNAString(primer)
              orients <-
                c(
                  Forward = dna,
                  Complement = Biostrings::complement(dna),
                  Reverse = Biostrings::reverse(dna),
                  RevComp = Biostrings::reverseComplement(dna)
                )
              return(sapply(orients, toString))
            }
            FWD.orients <- allOrients(FWD)
            REV.orients <- allOrients(REV)
            path <- unique(dirname(object@samples$fwd))

            fnFs.filtN <-
              file.path(path, "filtN", basename(object@samples$fwd))
            fnRs.filtN <-
              file.path(path, "filtN", basename(object@samples$rev))
            message("Removing ambiguous bases...")
            dada2::filterAndTrim(
              object@samples$fwd,
              fnFs.filtN,
              object@samples$rev,
              fnRs.filtN,
              maxN = 0,
              multithread = nproc
            ) #da cambiare multithread

            primerHits <- function(primer, fn) {
              # Counts number of reads in which the primer is found
              nhits <-
                Biostrings::vcountPattern(primer, ShortRead::sread(ShortRead::readFastq(fn)), fixed = FALSE)
              return(sum(nhits > 0))
            }
            prim <-
              rbind(
                FWD.ForwardReads = sapply(FWD.orients, primerHits, fn = fnFs.filtN[[1]]),
                FWD.ReverseReads = sapply(FWD.orients, primerHits, fn = fnRs.filtN[[1]]),
                REV.ForwardReads = sapply(REV.orients, primerHits, fn = fnFs.filtN[[1]]),
                REV.ReverseReads = sapply(REV.orients, primerHits, fn = fnRs.filtN[[1]])
              )

            cutadapt <- cutadaptPath
            path.cut <- file.path(path, "cutadapt")
            if (!dir.exists(path.cut))
              dir.create(path.cut)
            fnFs.cut <- file.path(path.cut, basename(object@samples$fwd))
            fnRs.cut <- file.path(path.cut, basename(object@samples$rev))

            FWD.RC <- dada2:::rc(FWD)
            REV.RC <- dada2:::rc(REV)
            R1.flags <- paste("-g", FWD, "-a", REV.RC)
            R2.flags <- paste("-G", REV, "-A", FWD.RC)

            for (i in seq_along(object@samples$fwd)) {
              system2(
                cutadapt,
                args = c(
                  R1.flags,
                  R2.flags,
                  "-n",
                  2,
                  # -n 2 required to remove FWD and REV from reads
                  "-o",
                  fnFs.cut[i],
                  "-p",
                  fnRs.cut[i],
                  # output files
                  fnFs.filtN[i],
                  fnRs.filtN[i]
                )
              ) # input files
            }

            prim1 <-
              rbind(
                FWD.ForwardReads = sapply(FWD.orients, primerHits, fn = fnFs.cut[[1]]),
                FWD.ReverseReads = sapply(FWD.orients, primerHits, fn = fnRs.cut[[1]]),
                REV.ForwardReads = sapply(REV.orients, primerHits, fn = fnFs.cut[[1]]),
                REV.ReverseReads = sapply(REV.orients, primerHits, fn = fnRs.cut[[1]])
              )
            samps <-
              data.frame(
                sample_name = sapply(strsplit(basename(
                  file.path(path.cut, basename(object@samples$fwd))
                ), "_"), `[`, 1),
                fwd = file.path(path.cut, basename(object@samples$fwd)),
                rev = file.path(path.cut, basename(object@samples$rev))
              )

            cutadapted <-
              new("qualityCheck",
                  samples = samps,
                  pattern = object@pattern)
            return(cutadapted)
          })
