#' Title
#'
#' @param object Meltps of an Aldo object.
#'
#' @return dataframe
aceCalc <- function(object){
  lapply(parent.frame()$path, function(object){
    path1 <- object  %>%
      dplyr::group_by(OTU) %>%
      dplyr::summarise(totabn = sum(Abundance))%>%
      dplyr::filter(., totabn > 0)
    f1 <- path1 %>%
      filter(., totabn == 1) %>%
      nrow()
    count.i <- sapply(1:10, function(i, counts) {
      length(counts[counts == i])
    }, path1)
    sabun <- nrow(filter(path1, totabn > 10))
    srare <- sum(count.i)
    cace <- 1 - (f1/srare)
    numer <- srare *(1:10) * ((1:10) - 1) * count.i
    denom <- cace*(srare)*(srare - 1)
    coeffvar <- max((numer/denom) -1)
    sace <- sabun + srare/cace + (f1/cace) * coeffvar
  })
}
