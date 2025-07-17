#' Function to get a palette of a certain number of colors
#'
#' @param x object.
#' @param pal palette.
#'
#' @return palette.
get.pal <- function(x, pal = NA) {
  ncolors = length(unique(x))
  persPal = get_palette(palette = pal, ncolors)
  return(persPal)
}

pal.neon <- c("#783EC1", "#C13E46", "#87C13E", "#3EC1B9",
              "#C46F3B", "#307e26", "#347fad", "#B33BC4")

pal.scrubs <- c("#C99260","#7F868E","#C13E46","#EACD4E","#0B4565",
                "#177FB8","#E9C0A1","#062F5A","#899DB7","#103F4F")

pal.wwdits <- c("#A7E886", "#2D0E37", "#6B4BAC",
                "#7AC753", "#1B076D", "#573474")



pal.wwdits2 <- c("#86100f", "darkorange", "#2e1d13", "#c97f36", "#863a34", "#725948",
                 "#b08169","#543823", "#1f1917", "#ebded5", "#744327",
                 "#d5b49f", "#961603","#413125", "#c06548")


pal.pokemon <- c("#67aa3e","#f68842", "#7b9bba", "#f9de4e", "#eb576f", "#08686f", "#492c4d", "#be9bab", "#42615a",
                 "#bb9426", "#90464b", "#78bee1", "#db93c0", "#b5c6bc", "#f2dea6", "#9a6437", "#82ac4f")

pal.pokemon2 <- c("#83c378", "#ecd7a4", "#67c9e4", "#ad8473", "#ee8258", "#ad505a", "#8771a7", "#689597",
                  "#f5cec7", "#eaca60", "#c15354","#449ccb", "#f293ad", "#708cc7", "#355a71", "#ab909c",
                  "#464d53","#e16c5a" ,"#336b74", "#e5945d", "#df5c74", "#8d7363", "#444d57",
                  "#ea4f33", "#d8e9c4", "#92aadd", "#e6c14e","#995b31", "#7ab5c0")

pal.pokemon.legendaries <- c("#96bcdf", "#f5de7a", "#f0a373", "#987693", "#f6d0dd",
                             "#cdac47", "#945b38", "#83afba", "#9eb5d6","#b64033", "#97b87f",
                             "#aea3a1", "#b8dcf0", "#6d7072", "#a06983", "#7499b3", "#195e9e",
                             "#ab3322","#4d866e", "#f2e08c", "#c58075","#d5ba81", "#b597a9",
                             "#6ea3ba", "#687998", "#99819d", "#744431", "#b7d1c4", "#8d6464",
                             "#afbace", "#76baca", "#98c16c", "#3c3b39", "#a79757",
                             "#eee5b5", "#3194ad", "#75665c", "#9cc25d", "#877191","#7fa5bf",
                             "#da8a4d", "#bec5de", "#454749", "#9d9da0", "#485281", "#bad8b6", "#73537a")


#palettes <- list(pal.pokemon, pal.pokemon2, pal.pokemon.legendaries, pal.scrubs, pal.wwdits, pal.wwdits2, pal.neon)
#names(palettes) <- c("pokemon", "pokemon2", "pokemonLegendaries", "scrubs", "wwdits", "wwdits2", "neon")

palettes <- list("pokemon" = pal.pokemon, "pokemon2" = pal.pokemon2, "pokemonLegendaries" = pal.pokemon.legendaries,
                 "scrubs" = pal.scrubs, "wwdits" = pal.wwdits, "wwdits2" = pal.wwdits2, "neon" = pal.neon)


theme_Aldo <- ggplot2::theme(
  legend.key.size = ggplot2::unit(.6, "lines"),
  legend.position = "right",
  legend.title = ggplot2::element_blank(),
  panel.grid = ggplot2::element_blank(),
  panel.border = ggplot2::element_rect(fill = NA, color = "black"),
  panel.background = ggplot2::element_blank(),
  strip.background = ggplot2::element_rect(color = "black", fill = NA),
  axis.text.x = ggplot2::element_text(angle = 90, vjust = 0.5, hjust=1)
)
