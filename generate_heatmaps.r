library("gplots")

remove_Inf <- function(x) {
  ifelse(is.infinite(x), 0, x)
}

generate_heatmaps <- function(counts, title, size="small") {
  # size = "large" or "small"
  safe_data <- apply(log2(counts[,-1]), 2, remove_Inf)
  distance_from_median <- sweep(safe_data, 1, apply(safe_data, 1, median))
  data <- data.frame(GeneSymbol = counts[,1], distance_from_median)

  # calculate margins
  mtrx <- as.matrix(data[,-1])
  nr   <- nrow(mtrx)
  nc   <- ncol(mtrx)
  name.len.col <- max(sapply(unlist(colnames(mtrx)), nchar))
  name.len.row <- max(sapply(unlist(as.character(data[,1])), nchar))
  mrgn <- c(12, ifelse(size == "small", 2, 8))
  mrgn[1] <- (name.len.col)
  mrgn[2] <- (name.len.row)/2+2
  
  if (nr < 100) nr <- 90
  width <- 800
  lwid  <- NULL
  
  if (nc > 26) {
    width <- (nc * 30)
    lwid  <- c(0.1, 1)
  }
  lhei <- c(1/(log10(nr)^4), log10(nr)/3)

  # clustering row
  Rowv <- rowMeans(mtrx)
  hr   <- hclust(as.dist(1-cor(t(mtrx), method="pearson")), method="average")
  ddr  <- as.dendrogram(hr)
  ddr  <- reorder(ddr, Rowv) # ddr was passed to heatmap.2

  if(size == "small") {
    # small heatmap
    png(paste("./heatmap/", title, "_GS_", size, ".png", sep = ""),
        width  = width, height = 900
    )
    heatmap.2(
      mtrx, col = greenred(75), breaks = c(seq(-2, 2, length.out = 76)),
      labRow = '',     key    = TRUE,  key.xlab  = "distance from median",
      scale  = "none", symkey = FALSE, symbreaks = TRUE,
      trace  = "none", density.info = "none",
      cexRow = 0.75 + (1/(2*log10(nr+200))),
      cexCol = 0.75 + (1/(2*log10(nc))),
      distfun   = function(c) as.dist(1-cor(t(c), method="pearson")),
      hclustfun = function(c, method="average") hclust(c, method=method),
      Rowv = ddr, lhei = c(0.1, 1), lwid = lwid,
      Colv = TRUE, margins = mrgn, main = paste(title)
    )
    dev.off();
  
    png(paste("./heatmap/", title, "_G_", size, ".png", sep = ""),
        width  = width, height = 900
    )
    heatmap.2(
      mtrx, col = greenred(75), breaks = c(seq(-2, 2, length.out = 76)),
      labRow = '',     key    = TRUE,  key.xlab  = "distance from median",
      scale  = "none", symkey = FALSE, symbreaks = TRUE,
      trace  = "none", density.info = "none",
      cexRow = 0.75 + (1/(2*log10(nr+200))),
      cexCol = 0.75 + (1/(2*log10(nc))),
      distfun   = function(c) as.dist(1-cor(t(c), method="pearson")),
      hclustfun = function(c, method="average") hclust(c, method=method),
      Rowv = ddr, lhei = c(0.1, 1), lwid = lwid,
      Colv = FALSE, margins = mrgn, main = paste(title)
    )
    dev.off();
  } else {
    # large heatmap
    png(paste("./heatmap/", title, "_GS_", size, ".png", sep = ""),
        width  = width, height = nr*10
    )
    heatmap.2(
      mtrx, col = greenred(75), breaks = c(seq(-2, 2, length.out = 76)),
      labRow = data[,1], key  = TRUE,  key.xlab  = "distance from median",
      scale  = "none", symkey = FALSE, symbreaks = TRUE,
      trace  = "none", density.info = "none",
      cexRow = 0.75 + (1/(2*log10(nr+200))),
      cexCol = 0.75 + (1/(2*log10(nc))),
      distfun   = function(c) as.dist(1-cor(t(c), method="pearson")),
      hclustfun = function(c, method="average") hclust(c, method=method),
      Rowv = ddr, lhei = c(1/(log10(nr)^4), log10(nr)/3), lwid = lwid,
      Colv = TRUE, margins = mrgn, main = paste(title)
    )
    dev.off();
  
    png(paste("./heatmap/", title, "_G_", size, ".png", sep = ""),
        width  = width, height = nr*10
    )
    heatmap.2(
      mtrx, col = greenred(75), breaks = c(seq(-2, 2, length.out = 76)),
      labRow = data[,1], key  = TRUE,  key.xlab  = "distance from median",
      scale  = "none", symkey = FALSE, symbreaks = TRUE,
      trace  = "none", density.info = "none",
      cexRow = 0.75 + (1/(2*log10(nr+200))),
      cexCol = 0.75 + (1/(2*log10(nc))),
      distfun   = function(c) as.dist(1-cor(t(c), method="pearson")),
      hclustfun = function(c, method="average") hclust(c, method=method),
      Rowv = ddr, lhei = c(1/(log10(nr)^4), log10(nr)/3), lwid = lwid,
      Colv = FALSE, margins = mrgn, main = paste(title)
    )
    dev.off();
  }
}
