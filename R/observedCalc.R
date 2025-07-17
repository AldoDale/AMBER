#' Title
#'
#' @param object Meltps of an Aldo object.
#'
#' @return dataframe
observedCalc <- function(object){
  prova <- lapply(parent.frame()$path, function(object){
    path1 <- object  %>%
      dplyr::filter(., Abundance > 0)%>%
      dplyr::group_by(OTU)
    observed <- length(unique(path1$OTU))
  })
}
