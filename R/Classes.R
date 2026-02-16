setOldClass("gg")
setOldClass("ggplot")
setClassUnion("plotOrNULL", members = c("gg", "NULL"))

setClassUnion("data.frameOrNULL", c("data.frame", "data.frame"))


setClass("amberobj",
         slots = list(
           df = "data.frame",
           stats = "vector",
           clusteringstats = "data.frameOrNULL"
         )
)


setClass("Diversity",
         slots = list(
           data = "data.frame",
           plot = "ANY"
         )
)

setClass("readscounter",
         slots = list(data = "numeric",
                      plot = "ANY"))


setClass("betaDiversity",
         slots = list(
           data = "data.frame",
           plot = "ANY"
         )
)


setClass("filteredSamples",
         slots = list(
           samples = "data.frame",
           stats = "matrix",
           fwd_qplot = "ANY",
           rev_qplot = "ANY"
         )
)


setClass("qualityCheck",
         slots = list(
           fwd_qplot = "ANY",
           rev_qplot = "ANY",
           samples = "data.frame",
           pattern = "character"
         )
)







