#' Function to trim and quality-filter sequences.
#'
#' @param x A qualityCheck object.
#' @param maxEE Maxium error. Standard is c(2,3)
#' @param fwd Sequence of the forward primer.
#' @param rev Sequence of the reverse primer.
#' @param truncLen Length for truncation.
#' @param truncQ Quality threshold for truncation.
#' @param nplots Number of quality plots to generate. Two is enough to check if primers were removed.
#' @param ncores Number of cores to use for parallelization. For windows is 1.
#' @param primerRemovalMethod Method to use for primer removal. Can be "cutadapt" or "dada2".
#' @param cutadaptPath Path where cutadapt is installed. Usually bin/cutadapt.
#'
#' @include removePrimersCutadapt.R
#' @return A filteredSample object.
#' @export
setGeneric("el_trimmador", function(x,
                                    maxEE = c(2, 3),
                                    fwd = "CCTACGGGNGGCWGCAG",
                                    rev = "GACTACNVGGGTWTCTAATCC",
                                    truncLen = c(280, 220),
                                    truncQ = 2,
                                    nplots = NULL,
                                    ncores = NULL,
                                    primerRemovalMethod = c("cutadapt", "dada2"),
                                    cutadaptPath = "/usr/bin/cutadapt") standardGeneric("el_trimmador"))

setMethod("el_trimmador",
          signature("qualityCheck"),
          function(x,
                   maxEE = c(2, 3),
                   fwd = "CCTACGGGNGGCWGCAG",
                   rev = "GACTACNVGGGTWTCTAATCC",
                   truncLen = c(280, 220),
                   truncQ = 2,
                   nplots = NULL,
                   ncores = NULL,
                   primerRemovalMethod = c("cutadapt", "dada2"),
                   cutadaptPath = "/usr/bin/cutadapt") {
            fwdsamples <- basename(x@samples$fwd)
            revsamples <-  basename(x@samples$rev)

            message("Filtering and trimming...")
            if (is.null(ncores)) {
              nproc <- 1
            } else {
              nproc <- ncores
            }
            path <- dirname(x@samples[1, 1])
            filtpath <- file.path(path, "filtered_reads")

            fwdLength <- nchar(fwd)
            revLength <- nchar(rev)
            if (primerRemovalMethod == "dada") {
              trimming <- c(nchar(fwd), nchar(rev))
            } else {
              trimming = 0
            }
            if (primerRemovalMethod == "cutadapt") {
              message("Running Cutadapt...")
              x <-
                removePrimersCutadapt(
                  x,
                  cutadaptPath = cutadaptPath ,
                  FWD = fwd,
                  REV = rev,
                  nproc = nproc
                )
            }
            message("Trimming reads...")

            out <- dada2::filterAndTrim(
              fwd = x@samples$fwd,
              filt = file.path(filtpath, fwdsamples),
              rev = x@samples$rev,
              filt.rev = file.path(filtpath, revsamples),
              truncLen = truncLen,
              maxEE = maxEE,
              truncQ = truncQ,
              maxN = 0,
              rm.phix = TRUE,
              trimLeft = trimming,
              compress = TRUE,
              verbose = TRUE,
              multithread = nproc
            )
            message("Trimming done!")
            samps <-
              data.frame(
                sample_name = sapply(strsplit(basename(
                  file.path(filtpath, fwdsamples)
                ), "_"), `[`, 1),
                fwd = file.path(filtpath, fwdsamples),
                rev = file.path(filtpath, revsamples)
              )
            message("samps done!")
            if (!identical(sapply(strsplit(basename(samps$fwd), "_"), `[`, 1),
                           sapply(strsplit(basename(samps$rev), "_"), `[`, 1)))
              stop("Forward and reverse files do not match.")
            if (!is.null(nplots)) {
              message("plots")
              fwdqp <-
                dada2::plotQualityProfile(sort(list.files(
                  filtpath,
                  pattern = x@pattern[1],
                  full.names = T
                ))[1:nplots])
              revqp <-
                dada2::plotQualityProfile(sort(list.files(
                  filtpath,
                  pattern = x@pattern[2],
                  full.names = T
                ))[1:nplots])
              message("plots done")
              filteredSample <-
                new(
                  "filteredSamples",
                  samples = samps,
                  stats = out,
                  fwd_qplot = fwdqp,
                  rev_qplot = revqp
                )
            } else {
              filteredSample <-
                new("filteredSamples", samples = samps, stats = out)
            }
            return(filteredSample)
          }
)

