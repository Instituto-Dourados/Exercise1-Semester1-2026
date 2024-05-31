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

# Load variant table 
variant_tbl <- 
  read_excel("data/supp table- GISAID.xlsx", skip = 2) %>% 
  rename(Variant = `SARS-CoV-2 variants (Pangolin classification)`, 
         Village = `Indigenous village`,
         Date = `Collecting date (yyyy-MM-dd)`)

variant_tbl$Date <- lubridate::date(variant_tbl$Date)
variant_tbl$case <- 1

plot_variant_cases_by_village <- function(variants = c("B.1.1", "Gamma (P.1)", "Zeta (P.2)")) {

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
      ggplot(aes(x = Date, y = `Cumulative cases`, linetype = Village, color = Variant)) +
        geom_line() + geom_point(size = 0.75) +
        # Customize Date x-axis ticks.
        scale_x_date(date_breaks = "months" , date_labels = "%b-%y")
  
  return (p)
}


# Make the plot for these two variants. There was only one Gamma case in Bororó.
p <- plot_variant_cases_by_village(variants = c("B.1.1", "Zeta (P.2)"))
print(p)