#' Title plot_anova
#'
#' @param x an amberobj
#' @param taxlevel taxonomic level to which agglomerate the object
#' @param group metadata group
#' @param method vegdist method
#'
#' @return a list
#' @export
#'
setGeneric("plot_anova", function(x, taxlevel, group, method) standardGeneric("plot_anova"))

setMethod("plot_anova",
          signature = "amberobj",function(x, taxlevel, group, method){
  results <- list("distmat" = matrix(), "anova" = data.frame(), "plot" = NULL)
  x <- x@df
  value_cols <- c("Abundance", "rel_abundance")
  value_col <- if (is.null(x$rel_abundance)) "Abundance" else "rel_abundance"
  taxlevs <- c("domain", "phylum", "class", "order", "family", "genus", "ASV")
  taxx <- x[,colnames(x) %in% taxlevs]
  taxlevel <- ifelse(is.null(taxlevel), "ASV", taxlevel)
  metass <- x[,!colnames(x) %in% c(taxlevs, "OTU", "refseq", value_cols)]
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

    taxx <- taxx[,1:which(colnames(taxx) == taxlevel)]
    taxx <- distinct(taxx)
    taxx <- taxx[!is.na(taxx[,taxlevel]),]
    rownames(taxx) <- taxx[,taxlevel]


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
  dists <- vegan::vegdist(t(otts), method=method, weighted=F)
  pwad <- pairwiseAdonis::pairwise.adonis(dists,metass[,group])
  pwad$pair1 <- gsub(" vs.*", "",pwad$pairs)
  pwad$pair2 <- gsub(".*vs ", "",pwad$pairs)
  pwad$sign <- ifelse(pwad$p.adjusted <= 0.05, "sign (*)", "ns")
  plt <- ggplot2::ggplot(pwad, ggplot2::aes(x = pair1, y = pair2, fill = p.adjusted, label = sign))+
    ggplot2::geom_tile(color = "black", linewidth = .2)+
    ggplot2::geom_text(color = "white", size =5)+
    ggplot2::scale_fill_gradient(low = "#9c2d2d", high = "grey")+
    ggplot2::theme(panel.background = ggplot2::element_blank(),
                   panel.border = ggplot2::element_rect(color = "black", fill = NA),
                   panel.grid.major = ggplot2::element_line())+
    ggplot2::scale_x_discrete(expand = c(0, 0)) +
    ggplot2::scale_y_discrete(expand = c(0, 0))
  results[[1]] <- dists
  results[[2]] <- pwad
  results[[3]] <- plt
  return(results)
          }
)
