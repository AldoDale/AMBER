#' A function to count the total number of reads in each sample.
#'
#' @param object An object of class amberobj.
#'
#' @return A reads count and a barplot.
#' @export
setGeneric("count_reads", function(object) standardGeneric("count_reads"))

setMethod("count_reads",
          signature("amberobj"),
          function(object) {
            object <- object@df
            totreads <- aggregate(object$Abundance, by=list(object$Sample), FUN=sum)
            totValues <- totreads$x
            names(totValues) <- totreads$Group.1
            totValues1 <- as.data.frame(totValues)
            plt <- ggplot2::ggplot(totValues1, ggplot2::aes(
              x = rownames(totValues1),
              y = totValues
            ))+
              ggplot2::geom_col(fill = "#b08169", color = "black") +
              theme_Aldo+
              ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0.005, .2)))+
              labs(x = "Sample", y = "nReads")


            object <- list(data = sort(totValues, decreasing = F), plot = plt)
          })

