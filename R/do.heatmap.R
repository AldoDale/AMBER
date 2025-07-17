#' Title
#'
#' @param x a matrix
#' @param sampdata sample data
#' @param noclust choose if no clustering
#' @param taxorder taxon order
#' @param showtaxanames whether to show taxa names
#'
#' @returns a heatmap
do.heatmap <- function(x, sampdata, noclust = F, taxorder, showtaxanames){
  otz.scaled.f <- scale(t(x), scale = T) %>%
    t()
  otz.scaled.f <- data.frame(
    asv = rep(rownames(otz.scaled.f), ncol(otz.scaled.f)),
    Sample = rep(colnames(otz.scaled.f), each = nrow(otz.scaled.f)),
    abundance = as.vector(otz.scaled.f)
  )
  samps.f <- as.data.frame(as.matrix(sampdata))

  otz.scaled.f <- merge(samps.f, otz.scaled.f, by = "Sample")

  col.range <- max(abs(range(otz.scaled.f$abundance))) * c(-1,1)

  otz.scaled.f$asv <- factor(otz.scaled.f$asv, levels = taxorder)


  heatm.f <- ggplot2::ggplot(otz.scaled.f, aes(x = Sample, y = asv)) +
    geom_tile(aes(fill = abundance),color = "black")  +
    ggplot2::theme(
      axis.text.x = element_blank(),
      panel.background = element_rect(fill = "white",
                                      color = "white",
                                      linewidth = 0.5, linetype = "solid"),
      axis.title.y = element_blank(),
      axis.ticks.x = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      legend.position = "right")+
    ggplot2::labs(x = "") +
    scale_fill_gradient2(limits = col.range, high = "red", low = "blue", mid = "white")+
    ggplot2::labs(fill="Scaled Abundance")
  if(noclust){
    heatm.f <- heatm.f + ggplot2::theme(axis.text.x = element_text(angle = 90,
                                                                   vjust = .5,
                                                                   hjust = 1))
  }
  if(showtaxanames){
    heatm.f <- heatm.f +
      ggplot2::scale_y_discrete(position = "right") +
      ggplot2::theme(axis.text.y = element_text(),
                     axis.ticks.y = element_line())
  }
  return(heatm.f)
}

