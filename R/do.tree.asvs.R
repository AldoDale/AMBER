#' Title
#'
#' @param x asvs matrix
#' @param ...
#'
#' @return a tree
do.tree.asvs <- function(x, ...){
  dist.f <- as.dist(cor(t(x), method = "spearman", use = "everything")-1)^2
  cl.f <- cluster::diana(dist.f, diss = T)
  x.cl.f <- as.hclust(cl.f)
  tree.f <- ggtree::ggtree(x.cl.f, branch.length="none")

  clusters <- cutree(x.cl.f, h = cl.f$dc)

  g <- split(names(clusters), clusters)
  p <- ggtree::ggtree(x.cl.f, branch.length="none")
  clades <- sapply(g, function(n) ggtree::MRCA(p, n))

  tree.f <- ggtree::ggtree(x.cl.f, branch.length="none")
  tree.f <- ggtree::groupClade(tree.f, clades)
  tree.f$data$group <- as.factor(tree.f$data$group)
  pal <- get.pal(length(unique(tree.f$data$group)), pal ="npg")
  tr <- tree.f +
    theme(
      axis.ticks.y = element_blank(),
      axis.title.y = element_blank(),
      legend.position = "left"
    )
  return(list(tr, ggtree::get_taxa_name(tr)))
}
