#' Function to merge reads and assign taxonomy.
#'
#' @param x A "filteredSamples" object.
#' @param taxAssignment The method to assign the taxonomy.
#' @param taxonomy_file The file containing the taxonomy.
#' @param metadataFile The file with metadata.
#' @param ncores Number of processors to use. For Windows is 1.
#'
#' @return A finalObject object.
#' @export
setGeneric("mergeAndTaxonomy", function(x,
                                        taxAssignment = "decipher",
                                        taxonomy_file,
                                        metadataFile = NULL,
                                        ncores = NULL)
  standardGeneric("mergeAndTaxonomy"))

setMethod("mergeAndTaxonomy",
          signature("filteredSamples"),
          function(x,
                   taxAssignment = "decipher",
                   taxonomy_file,
                   metadataFile = NULL,
                   ncores = NULL) {
            if (is.null(ncores)) {
              nproc <- 1
            } else {
              nproc <- ncores
            }
            message("Learning errors...")
            errF <-
              dada2::learnErrors(x@samples$fwd, nbases = 1e8, multithread = nproc)
            errR <-
              dada2::learnErrors(x@samples$rev, nbases = 1e8, multithread = nproc)
            mergers <- vector("list", length(x@samples$sample_name))
            names(mergers) <- x@samples$sample_name

            message("Merging pairs...")
            dadaF <- list()
            dadaR <- list()
            nsam <- 1
            for (sam in x@samples$sample_name) {
              cat("--> Processing:",
                  sam,
                  "(",
                  nsam,
                  "/",
                  length(x@samples$sample_name),
                  ")",
                  "\n")
              nsam <- nsam + 1
              derepF <-
                dada2::derepFastq(x@samples[x@samples$sample_name == sam, "fwd"])
              ddF <- dada2::dada(derepF, err = errF, multithread = nproc)
              dadaF[[sam]] <- ddF
              derepR <-
                dada2::derepFastq(x@samples[x@samples$sample_name == sam, "rev"])
              ddR <- dada2::dada(derepR, err = errR, multithread = nproc)
              dadaR[[sam]] <- ddR
              merger <- dada2::mergePairs(ddF, derepF, ddR, derepR)
              mergers[[sam]] <- merger
            }
            getN <- function(x)
              sum(dada2::getUniques(x))

            seqtab <- dada2::makeSequenceTable(mergers)

            message("Removing chimeras...")
            seqtab.nochim <-
              dada2::removeBimeraDenovo(seqtab, method = "consensus", multithread = nproc)

            message("Assigning taxonomy...")
            dna <-
              Biostrings::DNAStringSet(dada2::getSequences(seqtab.nochim))
            load(taxonomy_file)

            if (is.null(ncores)) {
              nproc <- detectCores() - 1
            } else {
              nproc <- ncores
            }

            ids <-
              DECIPHER::IdTaxa(
                dna,
                trainingSet,
                strand = "top",
                processors = nproc,
                verbose = FALSE
              ) # use all processors
            ranks <-
              c("domain",
                "kingdom",
                "division",
                "phylum",
                "class",
                "order",
                "family",
                "genus",
                "species") # ranks of interest
            # Convert the output object of class "Taxa" to a matrix analogous to the output from assignTaxonomy
            taxid <- t(sapply(ids, function(x) {
              m <- match(ranks, x$rank)
              taxa <- x$taxon[m]
              taxa[startsWith(taxa, "unclassified_")] <- NA
              taxa
            }))
            message("preparing the final object...")
            colnames(taxid) <- ranks
            rownames(taxid) <- dada2::getSequences(seqtab.nochim)
            saveRDS(seqtab.nochim, "seqtab_nochim.RData")
            saveRDS(taxid, "taxonomy.RData")

            if (!is.null(metadataFile)) {
              meta <- as.data.frame(read.csv(metadataFile))
              rownames(meta) <- meta[, "Sample_ID"]
              ps <-
                phyloseq::phyloseq(
                  phyloseq::otu_table(seqtab.nochim, taxa_are_rows = FALSE),
                  phyloseq::sample_data(meta),
                  phyloseq::tax_table(taxid)
                )
            } else {
              ps <-
                phyloseq::phyloseq(
                  phyloseq::otu_table(seqtab.nochim, taxa_are_rows = FALSE),
                  phyloseq::tax_table(taxid)
                )
            }
            message("tracking stats...")
            track <-
              as.data.frame(cbind(
                x@stats,
                sapply(dadaF, getN),
                sapply(dadaR, getN),
                sapply(mergers, getN),
                rowSums(seqtab.nochim)
              ))
            colnames(track) <-
              c("input",
                "filtered",
                "denoisedF",
                "denoisedR",
                "merged",
                "nonchim")
            track$finalPerc <- 100 * track[, "nonchim"] / track[, "input"]
            rownames(track) <- x@samples$sample_name

            x <- phyloseq::psmelt(ps)
            #x$refseq <- phyloseq::taxa_names(ps)
            start <- intersect(c("domain","kingdom"), names(x))[1]

            tax <- x %>%
              select( all_of(start) : genus )
            nums <- vector()
            for(i in colnames(tax)){
              nums[[i]] <- tax[,i] %>%
                unique() %>%
                length()
            }
            nums <- unlist(nums)

            nums[7] <- x$OTU %>%
              unique() %>%
              length()

            nums[8] <- x$Sample %>%
              unique() %>%
              length()
            names(nums) <- c("domains", "phyla", "classes", "orders", "families", "genera", "ASVs", "samples")
            new("amberobj", df = x, stats = nums, clusteringstats = track)
          })


