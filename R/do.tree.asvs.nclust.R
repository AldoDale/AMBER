#' Title
#'
#' @param x asvs matrix
#' @param nclust number of clusters to create
#' @param pal.highlight palette
#'
#' @return a tree
do.tree.asvs.nclust <- function(x, nclust, pal.highlight) {
  distance <- stats::as.dist(cor(t(x),
                                 method = "spearman",
                                 use = "everything") - 1) ^ 2

  clust.dia <- cluster::diana(distance, diss = T)
  x.clust.dia <- stats::as.hclust(clust.dia)

  if(is.numeric(nclust)){
  clusters <- stats::cutree(x.clust.dia, k = nclust)
  } else if (nclust == "auto"){
  clusters <- cutree(x.clust.dia, h = clust.dia$dc)
  } else {
    stop("Either choose nclust or leave it as `auto` ")
  }
  g <- split(names(clusters), clusters)
  p <- ggtree::ggtree(x.clust.dia)
  clade <- sapply(g, function(n) ggtree::MRCA(p, n))

  dendro <- ggtree::ggtree(x.clust.dia)
  dendro <- ggtree::groupClade(dendro, clade)
  dendro$data$group <- as.factor(dendro$data$group)
  dendro$data$subs <- dendro$data$node %in% clade

  pal.highlight1 <- match.arg(pal.highlight, names(palettes))
  persPal <- palettes[[pal.highlight1]]

  if(length(unique(dendro$data$group)) > length(persPal)){
    persPal <- get.pal(dendro$data$group, pal = persPal)
  } else {
    persPal <- head(palettes[[pal.highlight1]], n = length(unique(dendro$data$group)))
  }
  g2 <- dendro +
    ggplot2::theme(
      axis.ticks.y = element_blank(),
      axis.title.y = element_blank(),
      legend.position = "left"
    ) +
    ggtree::geom_hilight(
      mapping = aes(subset = subs,
                    fill = group),
      alpha = .5,
      type = c("gradient"),
      gradient.direction = 'rt',
      gradient.length.out = 2,
      to.bottom = F,
      align = "left"
    ) +
    ggplot2::scale_fill_manual(values = persPal, name = "Clusters")
  return(list(g2, ggtree::get_taxa_name(g2)))
}

