##
# Script with some tools to analyze data from de Oliveira, de Rezende, et al.
# (2023), "Genomic Characterization of SARS-CoV-2 from an Indigenous Reserve in 
# Mato Grosso do Sul, Brazil" published in _Frontiers in Public Health_.
#
# We are interested in diffusion between groups, and this dataset provided by
# Iza Rezende allows us to evaluate whether the prominent variants first enter in the 
# 
# 
# Author: Matthew A. Turner <maturner@stanford.edu>
# Date: 11 March 2026
#


library(dplyr)
library(ggplot2)
library(lubridate)
library(readxl)

# Custom theme for plots
mytheme <- theme(axis.line = element_line(), legend.key=element_rect(fill = NA),
                 text = element_text(size=16),# family = 'PT Sans'),
                 legend.key.width = unit(1, 'cm'),
                 legend.key.size = unit(2.5, 'lines'),
                 axis.text.x = element_text(angle = 35, hjust = 1),
                 panel.background = element_rect(fill = "white"))

# Create table 
variant_tbl <- 
  # First load variant table from original Excel, piped to next line
  read_excel("data/LaísIzaSimoneEtAl-FrPubHealth2023.xlsx", skip = 2) %>% 
  # Table piped from prev line passed to rename columns for convenience
  dplyr::rename(Variant = `SARS-CoV-2 variants (Pangolin classification)`, 
         Village = `Indigenous village`,
         Ethnicity = `Indigenous ethnicity`,
         Date = `Collecting date (yyyy-MM-dd)`)

# Ensure that the Date column is in most compatible format for ggplot
variant_tbl$Date <- lubridate::date(variant_tbl$Date)
variant_tbl$case <- 1

# Create plot across listed dimensions assumes variant_tbl exists
plot_variant_cases_by_village <- 
  function(variants = c("B.1.1", "Gamma (P.1)", "Zeta (P.2)"),
           savepath = "variant_by_village_series.png") {

  # Create plot of cumulative cases for different variants by village.
  data_tbl <- 
    # Make time series data grouped by variant and village by first...
    variant_tbl %>%
      # ...selecting desired variants and villages...
      filter(Variant %in% variants, Village %in% c("BORORÓ", "JAGUAPIRÚ")) %>%
      # ...grouping as desired,...
      group_by(Variant, Village) %>%
      # ...sort by ascending date,...
      arrange(Date) %>%
      # ...and aggregate over dummy `case` column, passing result to plotting.
      mutate(`Cumulative cases` = cumsum(case))
    
    p <-
      # Plot the cumulative cases using village for linetype, variant for color.
      ggplot(
        data_tbl,
        aes(x = Date, y = `Cumulative cases`, shape = Village, 
            linetype = Village, color = Variant)) +
        geom_line(linewidth = 1.05) + geom_point(size = 2.2) +
        # Customize Date x-axis ticks.
        scale_x_date(date_breaks = "months" , date_labels = "%b %Y") +
        mytheme
  
  # Save the figure to file
  ggsave(savepath, width = 10, height = 5.0)
  
  # The function returns the ggplot in case user wants to do more with it
  return (p)
}

# 
plot_variant_cases_by_ethnicity <- 
  function(variants = c("B.1.1", "Gamma (P.1)", "Zeta (P.2)"),
           savepath = "variant_by_ethnicity_series.png") {
    
  # Create plot of cumulative cases for different variants by village.
  data_tbl <- 
    # Make time series data grouped by variant and village by first...
    variant_tbl %>%
    # ...selecting desired variants and villages...
    filter(Variant %in% variants, Village %in% c("BORORÓ", "JAGUAPIRÚ")) %>%
    # ...grouping as desired,...
    group_by(Variant, Ethnicity) %>%
    # ...sort by ascending date,...
    arrange(Date) %>%
    # ...and aggregate over dummy `case` column, passing result to plotting.
    mutate(`Cumulative cases` = cumsum(case)) 

  p <-
    # Plot the cumulative cases using village for linetype, variant for color.
    ggplot(data_tbl,
      aes(x = Date, y = `Cumulative cases`, shape = Ethnicity, 
          linetype = Ethnicity, color = Variant)) +
    geom_line(linewidth = 1.05) + geom_point(size = 2.2) +
    # Customize Date x-axis ticks.
    scale_x_date(date_breaks = "months" , date_labels = "%b %Y") +
    mytheme 
  
  ggsave(savepath, width = 10.5, height = 5.0)
  
  return (p)
}


# Make the plot for these two variants. There was only one Gamma case in Bororó.
p1 <- plot_variant_cases_by_village(variants = c("B.1.1", "Zeta (P.2)"))
p2 <- plot_variant_cases_by_ethnicity(variants = c("B.1.1", "Zeta (P.2)"))

# What we want to be able to do ("Week's Activities" in the Week 1 Google Doc)
# new_data_path <- "data/new_copied_data.xlsx"
# p1 <- plot_variant_cases_by_village(new_data_path, 
#                                     variants = c("B.1.1", "Zeta (P.2)"))
