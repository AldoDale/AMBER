df_to_phyloseq <- function(melted,
                             sample_col    = "Sample",
                             otu_col       = "OTU",
                             abundance_col = "Abundance",
                             tax_cols      = NULL) {
  library(dplyr)
  library(tidyr)
  library(phyloseq)

  # 1. Identify taxonomic columns if not provided
  if (is.null(tax_cols)) {
    possible <- setdiff(names(melted),
                        c(sample_col, otu_col, abundance_col))
    tax_cols <- possible[vapply(possible, function(col) {
      n_distinct(melted[[col]]) < nrow(melted) * 0.9
    }, logical(1))]
  }

  # 2. Build sample_data: one row per sample
  group_vars_no_tax <- setdiff(names(melted),
                               c(otu_col, abundance_col, tax_cols))
  samp_df <- melted %>%
    select(all_of(c(sample_col, group_vars_no_tax))) %>%
    # keep only the first row per Sample
    distinct(!!sym(sample_col), .keep_all = TRUE)  %>%
    tibble::column_to_rownames(sample_col)

  samp_df[,sample_col] <- rownames(samp_df)

  # 3. OTU table: pivot back to wide
  otu_wide <- melted %>%
    select(all_of(c(sample_col, otu_col, abundance_col))) %>%
    pivot_wider(
      names_from   = all_of(sample_col),
      values_from  = all_of(abundance_col),
      values_fill  = 0       # fills *all* missing combinations with 0
    ) %>%
    tibble::column_to_rownames(otu_col)


  otu_tab <- otu_table(as.matrix(otu_wide), taxa_are_rows = TRUE)

  # 4. Tax table: one row per OTU
  tax_df <- melted %>%
    select(all_of(c(otu_col, tax_cols))) %>%
    distinct() %>%
    tibble::column_to_rownames(otu_col)
  tax_tab <- tax_table(as.matrix(tax_df))

  # 5. Assemble phyloseq object
  ps <- phyloseq(otu_tab, tax_tab, sample_data(samp_df))
  return(ps)
}


