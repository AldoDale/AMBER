#' Function to organize the Fastq files and check the quality profiles.
#'
#' @param path Path to the folder containing the Fatsq files.
#' @param patternF Pattern to recognize the forward files.
#' @param patternR Pattern to recognize the reverse files.
#' @param nplots Number of quality plots for forward and reverse. Two is usually enough.
#'
#' @return A qualityCheck object.
#'
#' @export
setGeneric("sample_setup", function(path, patternF, patternR, nplots)
  standardGeneric("sample_setup"))

setMethod("sample_setup",
          signature("character"),
          function(path, patternF, patternR, nplots) {
            fastqFs <- sort(list.files(path, pattern = patternF))
            fastqRs <- sort(list.files(path, pattern = patternR))
            filteredsamples <- data.frame(fwd = paste0(path, "/", fastqFs),
                                          rev = paste0(path, "/", fastqRs))

            if (length(fastqFs) != length(fastqRs))
              stop("Forward and reverse files do not match.")
            if(!is.null(nplots)){
              fwdqp <-
                dada2::plotQualityProfile(sort(list.files(
                  path, pattern = patternF, full.names = T
                ))[1:nplots])
              revqp <-
                dada2::plotQualityProfile(sort(list.files(
                  path, pattern = patternR, full.names = T
                ))[1:nplots])
              new(
                "qualityCheck",
                fwd_qplot = fwdqp,
                rev_qplot = revqp,
                samples = filteredsamples,
                pattern = c(patternF, patternR)
              )
            } else {
              new(
                "qualityCheck",
                samples = filteredsamples,
                pattern = c(patternF, patternR)
              )
            }
          })

