library(tidyverse)
library(ggrepel)
library(RColorBrewer)

up_col       <- brewer.pal(9, "Reds")[4]
down_col     <- brewer.pal(9, "Blues")[4]
markup_col   <- brewer.pal(9, "Reds")[7]
markdown_col <- brewer.pal(9, "Blues")[7]
non_col      <- brewer.pal(9, "Greys")[3]
mark_col     <- "black"

create_MAplot_data <- function(de_results, gene_list, logfc_threshold){

  colnames(de_results) <- colnames(de_results) %>% str_replace("comp.*_", "")

  plot_data <- de_results %>%
    left_join(gene_list) %>%
    select(GeneSymbol, PValue, logFC, logCPM, marker) %>%
    mutate("marker_symbol" = if_else(marker == "yes" ,
                                     GeneSymbol, NA_character_)) %>%
    mutate(deg = case_when(marker == "yes" & PValue < 0.05 & logFC >  logfc_threshold ~ "markup",
                           marker == "yes" & PValue < 0.05 & logFC < -logfc_threshold ~ "markdown",
                                             PValue < 0.05 & logFC >  logfc_threshold ~ "up",
                                             PValue < 0.05 & logFC < -logfc_threshold ~ "down",
                           marker == "yes"               ~ "mark",
                                                   TRUE  ~ "none"))
  return(plot_data)
}

create_MAplot <- function(plot_data, comp_name, logfc_threshold){
  dir.create("./results", showWarnings = FALSE)

  e <- ggplot(plot_data, aes(logCPM, logFC, label = marker_symbol)) +
    geom_point(data = plot_data %>% filter(deg == "none"), color = non_col)  +
    geom_point(data = plot_data %>% filter(deg == "mark"), color = mark_col) +
    geom_point(data = plot_data %>% filter(deg == "up"),   color = up_col)   +
    geom_point(data = plot_data %>% filter(deg == "down"), color = down_col) +
    geom_point(data = plot_data %>% filter(deg == "markup"),   color = markup_col)   +
    geom_point(data = plot_data %>% filter(deg == "markdown"), color = markdown_col) +
    geom_text_repel(data = plot_data %>% filter(!is.na(marker_symbol)),
                    max.overlaps = Inf, color = mark_col)

  e + theme_light(base_size = 16) +
    theme(legend.position = "none") +
    scale_color_manual(values = c(down_col, mark_col, markdown_col, markup_col, non_col, up_col)) +
    labs(title = comp_name)

  plot_file <- paste("./results/MA_plot_", comp_name, ".png", sep = "")
  ggsave(plot_file, width= 7, height = 7, unit = "in")
}
