#' Title
#'
#' @param object Meltps of an Aldo object.
#'
#' @return dataframe
simpsonsCalc <- function(object) {
  divlist <- lapply(parent.frame()$path, function(object) {
    path1 <- object  %>%
      dplyr::group_by(OTU) %>%
      dplyr::summarise(n = sum(Abundance)) %>%
      dplyr::filter(., n > 0)
    path1[, "n(n-1)"] <- sapply(path1$n, function(object) {
      object * (object - 1)
    })
    path1$pi <- sapply(path1$n, function(object) {
      (object / sum(path1$n)) ^ 2
    })
    gamma <- sum(path1$pi)
    numer <- sum(path1[, "n(n-1)"])
    N <- sum(path1$n)
    div <- N * (N - 1)
    path1$div <- sapply(path1$n, function(object) {
      (object / N) ^ 2
    })
    Simpson.gamma <- round(numer / div, digits = 4)
    Gini.Simpson <- round(1 - Simpson.gamma, digits = 4)
    inverse.Simpson <- round(1 / Simpson.gamma, digits = 4)
    simp.divs <- cbind(Simpson.gamma, Gini.Simpson, inverse.Simpson)

  })
  divdf <- as.data.frame(do.call(rbind, divlist))
  rownames(divdf) <- names(divlist)
  return(divdf)

}
