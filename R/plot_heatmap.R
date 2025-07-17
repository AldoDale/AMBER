#' Title
#'
#' @param x abmerobj
#' @param taxlevel xx
#' @param ntaxa xx
#' @param sampletip xx
#' @param nclust xx
#' @param cluster xx
#' @param showtaxanames xx
#' @param pal.highlight xx
#' @param pal.samples xx
#'
#' @return xx
#' @export

setGeneric("plot_heatmap", function(x,
                                    taxlevel,
                                    ntaxa,
                                    sampletip,
                                    nclust = NULL,
                                    cluster = "all",
                                    showtaxanames = T,
                                    addTaxaNames = F,
                                    pal.highlight = "pokemon",
                                    pal.samples = "pokemon2") standardGeneric("plot_heatmap"))

setMethod("plot_heatmap",
          signature = "amberobj",
          function(x, taxlevel, ntaxa, sampletip, nclust = NULL, cluster = "all", showtaxanames = T, addTaxaNames = F, pal.highlight = "pokemon", pal.samples = "pokemon2"){
  x <- x@df
  value_cols <- c("Abundance", "rel_abundance")
  value_col <- "rel_abundance"
  taxlevs <- c("domain", "phylum", "class", "order", "family", "genus", "ASV")
  taxx <- x[,colnames(x) %in% taxlevs]

  taxlevel <- ifelse(is.null(taxlevel), "ASV", taxlevel)
  metass <- x[,!colnames(x) %in% c(taxlevs, "OTU", value_cols)]
  metass <- distinct(metass)

  if(!is.null(taxlevel)){
    otts <- x %>%
      select(all_of(c("Sample", taxlevel, value_col))) %>%
      group_by(!!sym(taxlevel), Sample) %>%
      summarise(abundance = sum(.data[[value_col]])) %>%
      filter_at(vars(1), all_vars(!is.na(.)))%>%
      pivot_wider(
        names_from   = all_of("Sample"),
        values_from  = all_of("abundance"),
        values_fill  = 0       # fills *all* missing combinations with 0
      ) %>%
      tibble::column_to_rownames(taxlevel)


  } else {
    otts <- x %>%
      select(all_of(c("Sample", "ASV", value_col))) %>%
      pivot_wider(
        names_from   = all_of("Sample"),
        values_from  = all_of(value_col),
        values_fill  = 0       # fills *all* missing combinations with 0
      ) %>%
      tibble::column_to_rownames("ASV")

    taxx <- distinct(taxx)
    rownames(taxx) <- taxx$ASV
  }

  taxx <- taxx[,1:which(colnames(taxx) == taxlevel)]
  taxx <- distinct(taxx)
  taxx <- taxx[!is.na(taxx[,taxlevel]),]
  rownames(taxx) <- taxx[,taxlevel]




  if(!is.null(ntaxa)){
      collapsed <- vapply(split(otts, taxx[,taxlevel]), colSums,
                          FUN.VALUE = numeric(ncol(otts)))
      topX <- names(sort(colSums(collapsed), decreasing = TRUE)[1:ntaxa])
      otts <- otts[rownames(otts) %in% topX,]
  }
  if(!isFALSE(addTaxaNames)){
    rownames(otts) <- paste0(rownames(otts)," (", taxx[which(taxx[,taxlevel] %in% rownames(otts)),addTaxaNames],")")

  }
  if(!is.null(nclust)){
    asvclust <- do.tree.asvs.nclust(otts, nclust = nclust, pal.highlight)
  } else{
    asvclust <- do.tree.asvs(otts)
  }
  sampclust <- do.tree.samples(otts, sampletip = sampletip, pal.samples, meta = metass)
  heatm <- do.heatmap(otts, taxorder = asvclust[[2]], showtaxanames = showtaxanames, sampdata = metass, noclust = ifelse(cluster %in% c("samples", "all"), F, T))
  if(cluster == "all"){
    return(heatm %>% aplot::insert_left(asvclust[[1]], width = .3) %>%  aplot::insert_top(sampclust, height = .3))
  } else if (cluster == "asvs"){
    return(heatm %>% aplot::insert_left(asvclust[[1]], width = .3) )
  } else if (cluster == "samples"){
    return(heatm %>% aplot::insert_top(sampclust, height = .3))
  } else if (cluster == "none"){
    heatm <- do.heatmap(x, noclust = T)
    return(heatm)
  }

          }
)
