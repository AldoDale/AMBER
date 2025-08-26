#' Function to clean and prepare the dataset.
#'
#' @param x the phyloseq object.
#' @param kd kingdom/domain to keep.
#' @param renameasvs if the function should rename ASVs (ASV1, ASV2, etc...).
#' @param comp if it should also create a compositional dataset.
#' @param tax_clean if it should clean the taxonomy. If a taxonomic level is NA it is changed to the name of taxonomic level + 1. If family is "Rhizobiaceae" and genus is NA the genus becomes "Rhizobiaceae (Family)"
#'
#' @return an object of class Aldo
#' @export
setGeneric("makeitshiny", function(x, kd = NULL, renameasvs = F,renamesamples = F, comp = F, rmSingletons = F, min_abun = F) standardGeneric("makeitshiny"))

setMethod("makeitshiny",
          signature("amberobj"),
          function(x,
                   kd = NULL,
                   renameasvs = F,
                   renamesamples = F,
                   comp = F,
                   rmSingletons = F,
                   min_abun = F){
            x <- x@df
            if (!is.null(kd)){
              kdcol <- if ("domain" %in% names(x)) "domain" else "kingdom"
              if (identical(grep(as.character(paste0("(?i)", kd)), x[, kdcol]), integer(0)))
                stop("The kingdom/domanin of your choice is not present in the dataset",
                     call. = FALSE)
              x <- x[grepl(as.character(paste0("(?i)", kd)), x[,kdcol]),]
            }
            if(renameasvs){
              x$ASV <- paste0(
                "ASV-",
                as.integer( factor(x$OTU, levels = unique(x$OTU)) )
              )
            }
            if(renamesamples){
              x$Sample <- paste0(
                "Sample ",
                as.integer( factor(x$Sample, levels = unique(x$Sample)) )
              )
            }
            if(rmSingletons){
              x <- x[x$Abundance > 1,]
            }

            if(comp){
              xrel <- x %>%
                group_by(Sample) %>%
                mutate(sample_total = sum(Abundance)) %>%
                ungroup() %>%
                mutate(rel_abundance = Abundance / sample_total) %>%
                as.data.frame()
              x <- xrel
            }
            if(!is.null(min_abun)){
              if(min_abun < 1){
                p <- x[x$rel_abundance > min_abun,]
                x <- x[x$ASV %in% p$ASV,]
                x <-  x %>%
                  group_by(Sample) %>%
                  mutate(sample_total = sum(Abundance)) %>%
                  ungroup() %>%
                  mutate(rel_abundance = Abundance / sample_total) %>%
                  as.data.frame()
              } else {
                x <- x[x$Abundance > min_abun,]
              }
            } else if (is.null(min_abun)){
              x <- x
            }

            start_col <- if ("domain" %in% names(x)) "domain" else "kingdom"
            index1 <- match(start_col, names(x))
            index2 <- match("genus", names(x))
            cols <- names(x)[index1:index2]
            tax <- x %>% select(all_of(cols))

            nums <- vector()
            for(i in colnames(tax)){
              nums[[i]] <- tax[,i] %>%
                unique() %>%
                length()
            }
            nums <- unlist(nums)

            nums[7] <- x$ASV %>%
              unique() %>%
              length()

            nums[8] <- x$Sample %>%
              unique() %>%
              length()
            names(nums) <- c("domains", "phyla", "classes", "orders", "families", "genera", "ASVs", "samples")

            amberobj <- new("amberobj", df = x, stats = nums)
            return(amberobj)
          }
)


