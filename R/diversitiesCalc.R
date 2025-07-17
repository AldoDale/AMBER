#' diversitiesCalc
#'
#' @param object Meltps of an Aldo object.
#'
#' @return dataframe
diversitiesCalc <- function(object){
  path <- split(object, object[, "Sample"])
  Observed <- observedCalc(object)
  observed <- cbind(Observed)
  shannon <- shannonCalc(object)
  shannon <- cbind(shannon)
  chao1 <- chao1Calc(object)
  chao1 <- cbind(chao1)
  ace <- aceCalc(object)
  ace <- cbind(ace)
  simp.ind <- simpsonsCalc(object)
  #simp.ind1 <- lapply(simp.ind, function(object){as.data.frame(object)})
  #simp.DF <- t(sapply(simp.ind1, function(object){rbind(object)}))

  diversities <-data.frame(
    "Sample" = rownames(observed),
    "Observed" = unlist(observed),
    "Shannon" = unlist(shannon),
    "Chao1" = unlist(chao1),
    "ACE" = unlist(ace),
    simp.ind
  )
  diversities <- diversities %>%
    mutate_if(is.numeric, round, digits=4)
  return(diversities)
}
