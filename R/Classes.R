setOldClass(c("gg", "ggplot"))

setClassUnion("plotOrNULL",members=c("ggplot", "NULL"))
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
           plot = "ggplot"
         )
)

setClass("readscounter",
         slots = list(data = "numeric",
                      plot = "ggplot"))


setClass("betaDiversity",
         slots = list(
           data = "data.frame",
           plot = "ggplot"
         )
)


setClass("filteredSamples",
         slots = list(
           samples = "data.frame",
           stats = "matrix",
           fwd_qplot = "plotOrNULL",
           rev_qplot = "plotOrNULL"
         )
)


setClass("qualityCheck",
         slots = list(
           fwd_qplot = "plotOrNULL",
           rev_qplot = "plotOrNULL",
           samples = "data.frame",
           pattern = "character"
         )
)







