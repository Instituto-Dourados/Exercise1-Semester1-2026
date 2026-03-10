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
# Date: 30 May 2024
#


library(dplyr)
library(ggplot2)
library(lubridate)
library(readxl)

mytheme <- theme(axis.line = element_line(), legend.key=element_rect(fill = NA),
                 text = element_text(size=16),# family = 'PT Sans'),
                 legend.key.width = unit(1, 'cm'),
                 legend.key.size = unit(2.5, 'lines'),
                 panel.background = element_rect(fill = "white"))

# Load variant table 
variant_tbl <- 
  read_excel("data/supp table- GISAID.xlsx", skip = 2) %>% 
  rename(Variant = `SARS-CoV-2 variants (Pangolin classification)`, 
         Village = `Indigenous village`,
         Ethnicity = `Indigenous ethnicity`,
         Date = `Collecting date (yyyy-MM-dd)`)

variant_tbl$Date <- lubridate::date(variant_tbl$Date)
variant_tbl$case <- 1

plot_variant_cases_by_village <- 
  function(variants = c("B.1.1", "Gamma (P.1)", "Zeta (P.2)"),
           savepath = "plots/variant_by_village_series.pdf") {

  # Create plot of cumulative cases for different variants by village.
  p <- 
    # Make time series data grouped by variant and village by first...
    variant_tbl %>%
      # ...selecting desired variants and villages...
      filter(Variant %in% variants, Village %in% c("BORORÓ", "JAGUAPIRÚ")) %>%
      # ...grouping as desired,...
      group_by(Variant, Village) %>%
      # ...sort by ascending date,...
      arrange(Date) %>%
      # ...and aggregate over dummy `case` column, passing result to plotting.
      mutate(`Cumulative cases` = cumsum(case)) %>%
    
      # Plot the cumulative cases using village for linetype, variant for color.
      ggplot(aes(x = Date, y = `Cumulative cases`, shape = Village, linetype = Village, color = Variant)) +
        geom_line(size=1.05) + geom_point(size = 2.2) +
        # Customize Date x-axis ticks.
        scale_x_date(date_breaks = "months" , date_labels = "%b-%y") +
        mytheme
  
  ggsave(savepath, width=10, height=4.5)
  
  return (p)
}

# 
plot_variant_cases_by_ethnicity <- 
  function(variants = c("B.1.1", "Gamma (P.1)", "Zeta (P.2)"),
           savepath = "plots/variant_by_ethnicity_series.pdf") {
    
  # Create plot of cumulative cases for different variants by village.
  p <- 
    # Make time series data grouped by variant and village by first...
    variant_tbl %>%
    # ...selecting desired variants and villages...
    filter(Variant %in% variants, Village %in% c("BORORÓ", "JAGUAPIRÚ")) %>%
    # ...grouping as desired,...
    group_by(Variant, Ethnicity) %>%
    # ...sort by ascending date,...
    arrange(Date) %>%
    # ...and aggregate over dummy `case` column, passing result to plotting.
    mutate(`Cumulative cases` = cumsum(case)) %>%
    
    # Plot the cumulative cases using village for linetype, variant for color.
    ggplot(aes(x = Date, y = `Cumulative cases`, shape = Ethnicity, linetype = Ethnicity, color = Variant)) +
    geom_line(size=1.05) + geom_point(size = 2.2) +
    # Customize Date x-axis ticks.
    scale_x_date(date_breaks = "months" , date_labels = "%b-%y") +
    mytheme
  
  ggsave(savepath, width=10.5, height=4.5)
  
  return (p)
}


# Make the plot for these two variants. There was only one Gamma case in Bororó.
p <- plot_variant_cases_by_village(variants = c("B.1.1", "Zeta (P.2)"))
p <- plot_variant_cases_by_ethnicity(variants = c("B.1.1", "Zeta (P.2)"))
print(p)