#' Calculate and plot diversity indices.
#'
#' @param object An object of class Aldo.
#' @param group Metadata group on the base of which to merge samples.
#' @param indices Indices to calculate. Standard is set to NULL to calculate all the available indices.
#' @param save.csv Whether to save a .csv file with the results.
#' @param facet Metadata group on the base of which to split the plot in multiple subplots
#' @param ... Other arguments.
#'
#' @return An Aldo object.
#' @export
setGeneric("calculate_diversities", function(object,
                                             group = NA,
                                             indices = NULL,
                                             save.csv = F,
                                             facet = NULL,
                                             pal = palettes, ...) standardGeneric("calculate_diversities"))

setMethod("calculate_diversities",
          signature("amberobj"),
          function(object,
                   group = NULL,
                   indices = NULL,
                   save.csv = F,
                   facet = NULL,
                   pal = palettes) {
            object <- object@df
            diversities <- diversitiesCalc(object)
            divs <-
              tidyr::gather(diversities, key = "Description", value = "value", Observed:inverse.Simpson)

            if(is.null(indices)){
              divs$Description <- factor(divs$Description,
                                         levels = c("Observed","Shannon","Chao1",
                                                    "ACE","Simpson.gamma",
                                                    "inverse.Simpson",
                                                    "Gini.Simpson"))
            } else {
              divs <- divs %>%
                dplyr::filter(., Description %in% indices)
              divs$Description <- factor(divs$Description, levels = indices)
            }
            divs <- as.data.frame(divs)

            pal <- match.arg(pal, names(palettes))
            persPal <- palettes[[pal]]

            if(length(unique(divs$Group) > length(persPal))){
              persPal <- get.pal(divs$Group, pal = persPal)
            }

            if(!is.null(group)){
              metadata <- object %>%
                dplyr::select("Sample", {group}, {facet})
              colnames(metadata)[2] <- "Group"
              if(!is.null(facet)){
                colnames(metadata)[3] <- "Facet"
              }
              data1 <- merge(divs, distinct(metadata))
              data2 <- merge(distinct(metadata), diversities)
            } else {
              data1 <- divs
              colnames(data1)[1] <- "Group"
              data2 <- diversities
            }
            plt <- plotDiversities(data1, group = group, facet = facet)

            if(save.csv == T){
              file_path <- "diversities.tsv"
              if (file.exists(file_path)) {
                print("Overwriting the existing file...")
              } else {
                print("Creating the .tsv file...")
              }
              write.table(apply(data2, 2, as.character), "diversities.tsv", sep = "\t", row.names = F)
            }

            newobject <- new("Diversity", data = data1, plot = plt)
          })
