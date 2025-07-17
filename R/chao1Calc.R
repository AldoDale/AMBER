#' Title
#'
#' @param object Meltps of an Aldo object.
#'
#' @return dataframe
chao1Calc <- function(object){
  purrr::map(parent.frame()$path,  function(object){
    path1 <- object  %>%
      dplyr::group_by(OTU) %>%
      dplyr::summarise(totabn = sum(Abundance))
    nsing <- nrow(filter(path1, totabn == 1))
    ndoub <- nrow(filter(path1, totabn == 2))
    ntot <- path1 %>%
      dplyr::filter(., totabn != 0) %>%
      nrow()
    chao1 <- ntot + ((nsing * (nsing - 1))/(2 * (ndoub + 1)))
  })
}
