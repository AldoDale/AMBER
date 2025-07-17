#' A function to save the last obtained plot. Images are saved in the "figures" subfolder of the parent directory. Each image is saved as .png, .svg, and .ps.
#'
#' @param name Name to use for the image.
#' @param w Width.
#' @param h Height.
#'
#' @return Nothing
#' @export
save.graph <- function(name = NULL, w = 8, h = 8) {
  parent_wd <- getwd()
  if(!dir.exists("figures")){
    dir.create("figures")
  }
  path <- paste0(getwd(), "/figures")
  setwd(path)
  if(file.exists(paste0(name, ".png"))){
    warning("The file already exists, overwriting it!")
  }
  name <- name
  ggsave(
    paste0(name, ".png"),
    device = "png",
    path = path,
    width = w,
    height = h,
    dpi = 600,
    units = "cm"
  )
  ggsave(
    paste0(name,".svg"),
    device = svglite::svglite,
    path = path,
    width = w,
    height = h,
    dpi = 600,
    units = "cm",
    fix_text_size = F
  )


  ggsave(
    paste0(name, ".ps"),
    device = "ps",
    path = path,
    width = w,
    height = h,
    dpi = 600,
    units = "cm"
  )
  on.exit(setwd(parent_wd))
}
