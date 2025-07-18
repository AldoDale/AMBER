setGeneric("build_amber", function(x)
  standardGeneric("build_amber"))

setMethod("build_amber",
          signature("phyloseq"),
          function(x){
            x <- phyloseq::psmelt(x)
            tax <- x %>% select(domain:genus)
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
            new("amberobj", df = x, stats = nums)
})


setMethod("build_amber",
          signature("data.frame"),
          function(x){
            tax <- x %>% select(domain:genus)
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
            new("amberobj", df = x, stats = nums)
          })
