# nc = normalized counts
# plotSmear requires library(edgeR) 

ncBoxPlot <- function(nc, labels) {
  png(
    file = "./results/boxplot_normalized.png",
    width     = 1200,
    height    = 800,
    pointsize = 24
  )
  op <- par(no.readonly = TRUE)
  m <- op$mar
  m[1] = 12
  par(mar=m)
  par(las=3)
  boxplot(log2(nc), names = labels)
  dev.off()
}

ncScatterPlot <- function(nc, x, y) {
  png(
    file = paste("./results/scatter_plot_", x, "_", y, ".png", sep=""),
    width     = 800,
    height    = 800,
    pointsize = 24
  )
  plot(
    log2(nc[, c(x, y)]),
    xlab = x,
    ylab = y,
    main = paste(x, "vs", y, sep=" ")
  )
  dev.off()
}

ncMaPlot <- function(nc, x, y) {
  png(
    file = paste("./results/ncMA_plot", x, "_", y, ".png", sep=""),
    width     = 800,
    height    = 800,
    pointsize = 24
  )
  M <- log2(nc[, y] / nc[, x])
  A <- (log2(nc[, y]) + log2(nc[, x])) / 2
  plot(A, M, ylim = c(-10, 10))
  dev.off()
}

myPlotSmear <- function(et, xlabel, ylabel) {
  png(
    file = paste("./results/MA_plot_", xlabel, "_", ylabel, ".png", sep=""),
    width     = 800,
    height    = 800,
    pointsize = 24
  )
  plotSmear(et)
  dev.off()
}
