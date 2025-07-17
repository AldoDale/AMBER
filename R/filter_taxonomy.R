#' A function to count the total number of reads in each sample.
#'
#' @param object An object of class Aldo.
#'
#' @return A reads count and a barplot.
#' @export
setGeneric("filter_taxonomy", function(object, ...) standardGeneric("filter_taxonomy"))

setMethod("filter_taxonomy",
            signature = "amberobj",
            function(object, ...) {

              exprs <- enquos(...)

              df <- object@df

              df_filtered <- df %>%
                filter(!!!exprs)

              tax <- df_filtered %>% select(domain:genus)
              nums <- vector()
              for(i in colnames(tax)){
                nums[[i]] <- tax[,i] %>%
                  unique() %>%
                  length()
              }
              nums <- unlist(nums)

              nums[7] <- df_filtered$OTU %>%
                unique() %>%
                length()

              nums[8] <- df_filtered$Sample %>%
                unique() %>%
                length()
              names(nums) <- c("domains", "phyla", "classes", "orders", "families", "genera", "ASVs", "samples")
              amberobj <- new("amberobj", df = df_filtered, stats = nums)
              return(amberobj)
            }
  )

