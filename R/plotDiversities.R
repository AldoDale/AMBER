#' Function to plot diversity indices
#'
#' @param object Object.
#' @param group Group for boxplot coloring.
#' @param facet Group for faceting.
#'
#' @return plot.
plotDiversities <- function(object, group = NULL, facet = NULL){
  plt <- ggplot(object, aes(x = Group, y = as.numeric(value)))
  if(!is.null(group)){
    plt <- plt +
      geom_boxplot(
        aes(fill = Group),
        size = .2,
        alpha = 1,
        shape = 21,
        color = "black",
        outlier.size = .2
      )
  } else {
    plt <- plt +
      geom_point(aes(color = "black"))
  }
  if(is.null(facet)){
    plt <- plt +
      theme_Aldo+
      facet_wrap(~Description, scales = "free_y")+
      labs(y = "value") +
      scale_fill_manual(values = parent.frame()$persPal)
  } else {
    plt <- plt +
      theme_Aldo+
      facet_grid(Facet~Description, scales = "free_y")+
      labs(y = "value") +
      scale_fill_manual(values = parent.frame()$persPal)
  }
}

