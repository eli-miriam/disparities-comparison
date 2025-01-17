library(tidyverse)
library(here)
library(arrow)
library(ggplot2)

#define cohort
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  cohort <- "adults"
} else {
  cohort <- args[[1]]
}

## create output directories ----
fs::dir_create(here("output", "collated", "descriptive"))

##table 1

# import table 1 by cohort
collated_table1 = rbind(
  read_csv(here::here("output", "table1", paste0("table1_", cohort, 
           "_2016_2017.csv"))) %>% rename(N = 2) %>% 
    mutate(N = ifelse(row_number() == 1, .[2, 2], N)) %>%
    slice(-2) %>% mutate(subset = "2016_17") ,
  read_csv(here::here("output", "table1", paste0("table1_", cohort, 
           "_2017_2018.csv"))) %>% rename(N = 2) %>% 
    mutate(N = ifelse(row_number() == 1, .[2, 2], N)) %>%
    slice(-2) %>%  mutate(subset = "2017_18"),
  read_csv(here::here("output", "table1", paste0("table1_", cohort,
           "_2018_2019.csv"))) %>% rename(N = 2) %>% 
    mutate(N = ifelse(row_number() == 1, .[2, 2], N)) %>%
    slice(-2) %>%  mutate(subset = "2018_19"),
  read_csv(here::here("output", "table1", paste0("table1_", cohort, 
           "_2019_2020.csv"))) %>% rename(N = 2) %>% 
    mutate(N = ifelse(row_number() == 1, .[2, 2], N)) %>%
    slice(-2) %>%  mutate(subset = "2019_20"),
  read_csv(here::here("output", "table1", paste0("table1_", cohort, 
           "_2020_2021.csv"))) %>% rename(N = 2) %>% 
    mutate(N = ifelse(row_number() == 1, .[2, 2], N)) %>%
    slice(-2) %>%  mutate(subset = "2020_21"),
  read_csv(here::here("output", "table1", paste0("table1_", cohort, 
           "_2021_2022.csv"))) %>% rename(N = 2) %>% 
    mutate(N = ifelse(row_number() == 1, .[2, 2], N)) %>%
    slice(-2) %>%  mutate(subset = "2021_22"),
  read_csv(here::here("output", "table1", paste0("table1_", cohort, 
           "_2022_2023.csv"))) %>% rename(N = 2) %>% 
    mutate(N = ifelse(row_number() == 1, .[2, 2], N)) %>%
    slice(-2) %>%  mutate(subset = "2022_23")
)

#save as csv
write_csv(collated_table1, paste0(here::here("output", "collated", "descriptive"), 
          "/", cohort, "_table1_collated.csv"))
