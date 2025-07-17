#' Title
#'
#' @param object Meltps of an Aldo object.
#'
#' @return dataframe
shannonCalc <- function(object) {
  buh <- lapply(parent.frame()$path, function(object) {
    path1 <- object  %>%
      dplyr::group_by(OTU) %>%
      dplyr::summarise(totabn = sum(Abundance))
    path1 <- path1 %>%
      dplyr::filter(., totabn != 0)
    path1$pi <- sapply(path1$totabn, function(object) {
      object / sum(path1$totabn)
    })
    path1$form <- sapply(path1$pi, function(object) {
      -object * log(object)
    })
    path2 <- sum(path1$form)
  })
}
