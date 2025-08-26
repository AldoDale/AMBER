#' Title
#'
#' @param x asvs matrix
#' @param meta metadata
#' @param sampletip metadata column to color sample tips
#' @param pal.samples palette to use
#' @param ...
#'
#' @return a tree.
do.tree.samples <- function(x, meta,sampletip = sampletip, pal.samples, ...){
  hcr <- stats::hclust(dist(t(x)))
  ddr <- stats::as.dendrogram(hcr)

  dist.f <- stats::as.dist(cor(x, method = "spearman", use = "everything")-1)^2
  cl.f <- cluster::diana(dist.f, diss = T)
  x.cl.f <- stats::as.hclust(cl.f)
  x.cl.f$labels

  tree.s <- ggtree::ggtree(x.cl.f, branch.length="none")
  tree.s <- tree.s+
    ggplot2::coord_flip() +
    ggplot2::scale_x_reverse()

  sans <- meta[,c("Sample", sampletip)] #da cambiare per pacchetto
  colnames(sans)[2] <- "sampletips"

  treedata <- dplyr::left_join(tree.s$data, sans, by=c('label'='Sample'))

  pname <- if (is.character(pal.samples)) as.character(pal.samples)[1L] else NULL
  persPal <- if (is.character(pal.samples) && length(pal.samples) > 1 &&
                 all(vapply(pal.samples, function(cl) tryCatch({col2rgb(cl); TRUE}, error=function(e) FALSE), logical(1))))
    unname(pal.samples) else palettes[[pname]]
  if (is.null(persPal)) { obj <- get0(pname, inherits = TRUE); persPal <- if (is.character(obj) && length(obj)>0) unname(obj) else palettes[[1]] }

  if(length(unique(treedata$sampletips)) > length(persPal)){
    persPal <- get.pal(treedata$sampletips, pal = persPal)
  }


  if(!is.null(sampletip)){
    tree.s <- tree.s +  ggtree::geom_tippoint(data = treedata, aes(color = sampletips))+
      ggplot2::scale_color_manual(values = persPal)
  }

  return(tree.s)
}
