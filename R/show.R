setMethod("show", "amberobj", function(object) {
  cat("An object of class 'amberobj'\n")
  slot_names <- slotNames(object)
  for (sn in slot_names) {
    val <- slot(object, sn)
    # decide what “empty” means for each slot
    is_empty <- is.null(val) ||
      (is.data.frame(val) && ncol(val) == 0 && nrow(val) == 0) ||
      (is.vector(val)     && length(val) == 0)
    if (!is_empty) {
      cat("$", sn, ":\n", sep = "")
      # pretty-print the slot
      print(val)
      cat("\n")
    }
  }
})
