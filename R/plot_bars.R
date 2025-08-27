#' Function to make barplots.
#'
#' @param object An Aldo object.
#' @param taxLevel Taxonomic level to plot.
#' @param topx The number of most abundant taxa to plot.
#' @param comp If to plot relative abundance or not.
#' @param group Metadata column for sample merging to use as x axis.
#' @param facet Metadata column to use to split plots.
#' @param pal Palette
#' @param ... Other.
#'
#' @return ggplot object
#' @export

setGeneric("plot_bars", function(object,
                                 taxLevel = NULL,
                                 comp     = TRUE,
                                 group    = NULL,
                                 facet    = NULL,
                                 facet1   = NULL,
                                 topx     = NULL,
                                 fill_others = F,
                                 pal = NULL) standardGeneric("plot_bars"))
setMethod("plot_bars",
          signature = "amberobj",
          function(object,
                   taxLevel = NULL,
                   comp     = TRUE,
                   group    = NULL,
                   facet    = NULL,
                   facet1   = NULL,
                   topx     = NULL,
                   fill_others = F,
                   pal      = NULL) {

            x <- object@df
            taxVar    <- taxLevel %||% "ASV"
            value_col <- if (comp) "rel_abundance" else "Abundance"
            grp       <- group %||% "Sample"

            grouping_vars <- c(grp, taxVar, facet, facet1)
            grouping_vars <- grouping_vars[!vapply(grouping_vars, is.null, logical(1))]
            grouping_vars <- grouping_vars[grouping_vars %in% names(x)]

            sample_taxon_means <- x %>%
              group_by(Sample, !!sym(taxVar)) %>%
              summarise(value = sum(.data[[value_col]], na.rm = TRUE), .groups = "drop")

            group_vars_no_tax <- setdiff(grouping_vars, taxVar)
            sample_to_group <- x %>%
              select(Sample, all_of(group_vars_no_tax)) %>%
              distinct()

            if (any(duplicated(sample_to_group$Sample))) {
              stop("Samples have multiple group/facet assignments — fix your data!")
            }

            df1 <- sample_taxon_means %>%
              left_join(sample_to_group, by = "Sample") %>%
              group_by(across(all_of(grouping_vars))) %>%
              summarise(value = mean(value, na.rm = TRUE), .groups = "drop")


            if (!is.null(topx)) {
              higher_group <- setdiff(grouping_vars, taxVar)

              # compute totals per higher_group from df1 (the pre-topx df)
              group_totals <- df1 %>%
                group_by(across(all_of(higher_group))) %>%
                summarise(total = if (comp) 1 else sum(value, na.rm = TRUE), .groups = "drop")

              # select top-x taxa per higher_group
              df_top <- df1 %>%
                group_by(across(all_of(higher_group))) %>%
                filter(!is.na(.data[[taxVar]])) %>%
                slice_max(order_by = value, n = topx, with_ties = FALSE) %>%
                ungroup()

              if (fill_others) {
                if (length(higher_group) == 0) {
                  # single global group (no additional grouping columns)
                  total_val <- group_totals$total[1]
                  sum_top <- sum(df_top$value, na.rm = TRUE)
                  others_val <- total_val - sum_top
                  if (others_val > 0) {
                    others <- tibble::tibble(value = others_val) %>%
                      mutate(!!taxVar := "Others")
                    df1 <- bind_rows(df_top, others)
                  } else {
                    df1 <- df_top
                  }
                } else {
                  # compute sum of top taxa per group
                  sum_top <- df_top %>%
                    group_by(across(all_of(higher_group))) %>%
                    summarise(sum_top = sum(value, na.rm = TRUE), .groups = "drop")

                  # create Others = total - sum_top per group
                  others <- group_totals %>%
                    left_join(sum_top, by = higher_group) %>%
                    mutate(sum_top = ifelse(is.na(sum_top), 0, sum_top),
                           value = total - sum_top) %>%
                    filter(value > 0) %>%
                    mutate(!!taxVar := "Others")

                  df1 <- bind_rows(df_top, others)
                }
              } else {
                df1 <- df_top
              }
            }

            facet_formula <- if (!is.null(facet) || !is.null(facet1)) {
              facet_row <- facet1 %||% "."
              facet_col <- facet  %||% "."
              as.formula(paste(facet_row, "~", facet_col))
            } else {
              NULL
            }

            if (taxVar %in% names(df1)) {
              taxa_levels <- df1 %>%
                filter(.data[[taxVar]] != "Others") %>%
                group_by(.data[[taxVar]]) %>%
                summarise(total = sum(value, na.rm = TRUE), .groups = "drop") %>%
                arrange(total) %>%
                pull(!!taxVar)

              taxa_levels <- c("Others", taxa_levels)

              df1[[taxVar]] <- factor(df1[[taxVar]], levels = taxa_levels)
            }


            p <- ggplot(df1, aes(x = .data[[grp]], y = value, fill = .data[[taxVar]])) +
              geom_bar(stat = "identity", position = "stack")

            if (!is.null(facet_formula)) {
              p <- p + facet_grid(facet_formula, scales = "free_x", space = "free_x")
            }
            if(!is.null(pal)) {
              pal <- match.arg(pal, names(palettes))
              persPal <- palettes[[pal]]
              if (length(unique(df1[[taxVar]])) > length(persPal)) {
                ncolors <- length(unique(df1[[taxVar]]))
                persPal <- ggpubr::get_palette(palette = persPal, ncolors)
              }

              persPal[1] <- "grey"
              p <- p + scale_fill_manual(values = persPal)
            }

            p + theme_Aldo
          }
)

