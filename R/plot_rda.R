setGeneric("plot_rda", function(x,
                                group,
                                condition = F,
                                comp = F,
                                showtoptaxa = NULL,
                                rm.uncl = F,
                                plotfill = NULL,
                                taxlevel = NULL,
                                nperm = 999) standardGeneric("plot_rda"))

setMethod("plot_rda",
          signature = "amberobj",
          function(x,
                   group,
                   condition = F,
                   comp = F,
                   showtoptaxa = NULL,
                   rm.uncl = F,
                   plotfill = NULL,
                   taxlevel = NULL,
                   nperm = 999){
  x <- x@df
  value_cols <- c("Abundance", "rel_abundance")
  value_col <- if (comp) "rel_abundance" else "Abundance"
  taxlevs <- c("domain", "phylum", "class", "order", "family", "genus", "ASV")
  taxx <- x[,colnames(x) %in% taxlevs]
  taxlevel <- ifelse(is.null(taxlevel), "ASV", taxlevel)

  if(!is.null(taxlevel)){
    otts <- x %>%
      select(all_of(c("Sample", taxlevel, value_col))) %>%
      group_by(!!sym(taxlevel), Sample) %>%
      summarise(abundance = sum(.data[[value_col]])) %>%
      filter_at(vars(1), all_vars(!is.na(.)))%>%
      pivot_wider(
        names_from   = all_of("Sample"),
        values_from  = all_of("abundance"),
        values_fill  = 0       # fills *all* missing combinations with 0
      ) %>%
      tibble::column_to_rownames(taxlevel)

    taxx <- taxx[,1:which(colnames(taxx) == taxlevel)]
    taxx <- distinct(taxx)
    taxx <- taxx[!is.na(taxx[,taxlevel]),]
    rownames(taxx) <- taxx[,taxlevel]


  } else {
    otts <- x %>%
      select(all_of(c("Sample", "ASV", value_col))) %>%
      pivot_wider(
        names_from   = all_of("Sample"),
        values_from  = all_of(value_col),
        values_fill  = 0       # fills *all* missing combinations with 0
      ) %>%
      tibble::column_to_rownames("ASV")

    taxx <- distinct(taxx)
    rownames(taxx) <- taxx$ASV
  }
  otus_clr <- t(compositions::clr(otts))
  metass <- x[,!colnames(x) %in% c(taxlevs, "OTU", "refseq", value_cols )]
  metass <- distinct(metass)
  form1 <- formula(paste0("otus_clr ~ ", group,
                          " + Condition(", condition, ")"))
  form2 <- formula(paste("otus_clr ~", group))
  if(!isFALSE(condition)) {
    res.rda <- vegan::rda(form1, data = metass, scale = FALSE)
  } else {
    res.rda <- vegan::rda(form2, data = metass, scale = FALSE)
  }
  coorddf <- as.data.frame(vegan::scores(res.rda)$sites)

  metass$sample <- metass[, colnames(metass)[sapply(metass, function(col) {
    all(rownames(coorddf) %in% as.character(col))
  })][1]]

  coorddf$sample <- rownames(coorddf)

  coorddf <- merge(coorddf, metass, by = "sample")

  if (isTRUE(condition)) {
    rda.aov <- vegan::anova.cca(
      res.rda,
      permutations = how(blocks = metass[, group], nperm = nperm),
      by = "terms"
    )
  } else {
    rda.aov <- vegan::anova.cca(res.rda, permutations = nperm, by = "terms")
  }

  anovaz <- rda.aov
  s <- summary(res.rda)
  tot <- s$tot.chi
  cd <- round(s$partial.chi/tot, digits = 3)
  cs <- round(s$constr.chi/tot, digits = 3)
  uc <- round(s$unconst.chi/tot, digits = 3)
  signif <- NULL
  signif <- ifelse(anovaz$`Pr(>F)`[1] < 0.001, "***",
                   ifelse(anovaz$`Pr(>F)`[1] < 0.01, "**",
                          ifelse(anovaz$`Pr(>F)`[1] < 0.05, "*",
                                 "ns")))

  if(is.null(condition)){
    plt <- ggplot(coorddf, aes(x = RDA1, y = RDA2))+
      geom_point(shape = 21, color = "white", size = 3, aes(fill = .data[[plotfill]])) +
      theme(panel.background = element_rect(fill = NA, color = "black"),
            panel.grid = element_blank(),
            legend.key = element_rect(color = NA))+
      geom_vline(xintercept = 0, linetype = "dotted", color = "azure4")+
      geom_hline(yintercept = 0, linetype = "dotted", color = "azure4")+
      labs(subtitle = paste0("MODEL SUMMARY: ", "cs = ", cs, ", uc = ", uc,
                             "\nANOVA: variance = ", round(anovaz$Variance[1], digits = 3), ", F = ",
                             round(anovaz$F[1], digits = 3), ", p-value = ", round(anovaz$`Pr(>F)`[1], digits = 3),
                             " (",signif, ")"))

  } else {
    plt <- ggplot(coorddf, aes(x = RDA1, y = RDA2))+
      geom_point(shape = 21, color = "white", size = 3, aes(fill = .data[[plotfill]])) +
      theme(panel.background = element_rect(fill = NA, color = "black"),
            panel.grid = element_blank(),
            legend.key = element_rect(color = NA))+
      geom_vline(xintercept = 0, linetype = "dotted", color = "azure4")+
      geom_hline(yintercept = 0, linetype = "dotted", color = "azure4")+
      labs(subtitle = paste0("MODEL SUMMARY: cd = ", cd, ", cs = ", cs, ", uc = ", uc,
                             "\nANOVA: variance = ", round(anovaz$Variance[1], digits = 3), ", F = ",
                             round(anovaz$F[1], digits = 3), ", p-value = ", round(anovaz$`Pr(>F)`[1], digits = 3),
                             " (",signif, ")"))
  }
  if(!is.null(showtoptaxa)){
    spec <- as.data.frame(vegan::scores(res.rda)$species)
    spec$tot <- rowSums(abs(spec))

    if(!is.null(showtoptaxa[2])){
    spec$taxon <- unique(taxx[taxx[,taxlevel] %in% rownames(spec),]) %>%
      pull(!!sym(showtoptaxa[2]))
    spec$taxon[is.na(spec$taxon)] <- "unclassified"
    if(rm.uncl){
      spec <- spec[spec$taxon != "unclassified",]
    }
    spec <- spec %>%
      arrange(desc(tot)) %>%  # arrange in descending order
      slice(1:as.numeric(showtoptaxa[1]))

    } else {

    spec$taxon <- rownames(spec)
    }
    plt <- plt +
      geom_segment(data=spec,
                   aes(x = 0, xend = RDA1*5, y = 0, yend = RDA2*5),
                   arrow = arrow(length = unit(0.25, "cm")),
                   colour="azure3") +
      ggrepel::geom_text_repel(data = spec, aes(x = RDA1*5, y = RDA2*5, label = taxon), color = "azure4", force_pull = T)
  }
  return(plt)
          }
)
