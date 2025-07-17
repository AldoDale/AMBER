#' A function to count the total number of reads in each sample.
#'
#' @param object An object of class Aldo.
#'
#' @return A reads count and a barplot.
#' @export
setGeneric("filter_dataset", function(object, sampnames = F, min_reads = F) standardGeneric("filter_dataset"))

setMethod("filter_dataset",
          signature("amberobj"),
          function(object, sampnames = F, min_reads = F) {
            object <- object@df
            if(!isFALSE(sampnames)){
              object <- object[!object$Sample %in% sampnames,]
            }
            if(min_reads){
              object <- object
              totreads <- aggregate(object$Abundance, by=list(object$Sample), FUN=sum)
              totValues <- totreads$x
              names(totValues) <- totreads$Group.1
              totValues1 <- as.data.frame(totValues)
              totValues1$sample <- rownames(totValues1)

              object <- object[object$Sample %in% totValues1[totValues1$totValues > min_reads, "sample"],]
            }

            tax <- object %>% select(domain:genus)
            nums <- vector()
            for(i in colnames(tax)){
              nums[[i]] <- tax[,i] %>%
                unique() %>%
                length()
            }
            nums <- unlist(nums)

            nums[7] <- object$OTU %>%
              unique() %>%
              length()

            nums[8] <- object$Sample %>%
              unique() %>%
              length()
            names(nums) <- c("domains", "phyla", "classes", "orders", "families", "genera", "ASVs", "samples")
            amberobj <- new("amberobj", df = object, stats = nums)
            return(amberobj)
          })

