library(dplyr)
library(here)
library(arrow)
library(lubridate)
library(survival)
library(broom)
library(readr)

## create output directories ----
fs::dir_create(here("analysis", "outcome_rsv"))

#define study start date and study end date
source(here("analysis", "design", "design.R"))
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  study_start_date <- "2016-09-01"
  study_end_date <- "2017-08-31"
  cohort <- "infants"
  codelist_type <- "sensitive"
  investigation_type <- "primary"
} else {
  study_start_date <- study_dates[[args[[2]]]]
  study_end_date <- study_dates[[args[[3]]]]
  cohort <- args[[1]]
  codelist_type <- args[[4]]
  investigation_type <- args[[5]]
}
covid_season_min <- as.Date("2019-09-01")

df_input <- read_feather(
  here::here("output", "data", paste0("input_processed_", cohort, "_", 
                                      year(study_start_date), "_", year(study_end_date), "_", 
                                      codelist_type, "_", investigation_type,".arrow"))) 

if (cohort == "infants") {
  #rsv primary by ses
  rsv_mild_ses <- glm(rsv_primary_inf ~ imd_quintile + 
                        age + sex + 
                        rurality_classification + 
                        offset(log(time_rsv_primary)),
                      data = df_input, family = poisson)
  rsv_mild_ses_output <- tidy(rsv_mild_ses)
  
  #rsv secondary by ses
  rsv_severe_ses <- glm(rsv_secondary_inf ~ imd_quintile + 
                          age + sex + 
                          rurality_classification + 
                          offset(log(time_rsv_secondary)),
                        data = df_input, family = poisson)
  rsv_severe_ses_output <- tidy(rsv_severe_ses)
  
  #rsv mortality by ses
  rsv_mortality_ses <- glm(rsv_mortality ~ imd_quintile + 
                             age + sex + 
                             rurality_classification + 
                             offset(log(time_rsv_mortality)),
                           data = df_input, family = poisson)
  rsv_mortality_ses_output <- tidy(rsv_mortality_ses)
  
  #add models for infants subgroup
  #} else if (cohort == "infants_subgroup") {
  
} else {
  
  #rsv primary by ses
  rsv_mild_ses <- glm(rsv_primary_inf ~ imd_quintile + 
                        age_band + sex + 
                        rurality_classification + 
                        offset(log(time_rsv_primary)),
                      data = df_input, family = poisson)
  rsv_mild_ses_output <- tidy(rsv_mild_ses)
  
  #rsv secondary by ses
  rsv_severe_ses <- glm(rsv_secondary_inf ~ imd_quintile + 
                          age_band + sex + 
                          rurality_classification + 
                          offset(log(time_rsv_secondary)),
                        data = df_input, family = poisson)
  rsv_severe_ses_output <- tidy(rsv_severe_ses)
  
  #rsv mortality by ses
  rsv_mortality_ses <- glm(rsv_mortality ~ imd_quintile + 
                             age_band + sex + 
                             rurality_classification +
                             offset(log(time_rsv_mortality)),
                           data = df_input, family = poisson)
  rsv_mortality_ses_output <- tidy(rsv_mortality_ses)
 
  if (study_start_date >= covid_season_min) {
    #rsv primary by ses
    rsv_mild_ses <- glm(rsv_primary_inf ~ imd_quintile + 
                          age_band + sex + 
                          rurality_classification + 
                          offset(log(time_rsv_primary)),
                        data = df_input, family = poisson)
    rsv_mild_ses_output <- tidy(rsv_mild_ses)
    
    #rsv secondary by ses
    rsv_severe_ses <- glm(rsv_secondary_inf ~ imd_quintile + 
                            age_band + sex + 
                            rurality_classification +
                            offset(log(time_rsv_secondary)),
                          data = df_input, family = poisson)
    rsv_severe_ses_output <- tidy(rsv_severe_ses)
    
    #rsv mortality by ses
    rsv_mortality_ses <- glm(rsv_mortality ~ imd_quintile + 
                               age_band + sex + 
                               rurality_classification + 
                               offset(log(time_rsv_mortality)),
                             data = df_input, family = poisson)
    rsv_severe_ses_output <- tidy(rsv_mortality_ses)

  }
}

#define a vector of names for the model outputs
if (study_start_date < covid_season_min) {
  model_names <- c("Mild RSV by IMD Quintile",
                   "Severe RSV by IMD Quintile", "RSV Mortality by IMD Quintile")
} else if (codelist_type == "sensitive") {
  model_names <- c("Mild RSV by IMD Quintile", "Severe RSV by IMD Quintile", 
                   "RSV Mortality by IMD Quintile")
} else if (study_start_date >= covid_season_min) {
  model_names <- c("Mild RSV by IMD Quintile", "Severe RSV by IMD Quintile", 
                   "RSV Mortality by IMD Quintile")
} else {
  model_names <- c("Mild RSV by IMD Quintile", "Severe RSV by IMD Quintile", 
                   "RSV Mortality by IMD Quintile")
}

#create the model outputs list
model_outputs_list <- list(rsv_mild_ses_output, rsv_severe_ses_output, 
                           rsv_mortality_ses_output)

#bind model outputs together and add a column with the corresponding names
model_outputs <- do.call(rbind, lapply(seq_along(model_outputs_list), function(i) {
  cbind(model_name = model_names[i], model_outputs_list[[i]])
}))

## create output directories ----
fs::dir_create(here("output", "results", "models"))

#save model output 
if (length(args) == 0) {
  model_outputs %>%
    write_csv(file = paste0(here::here("output", "results", "models",
                            paste0("rsv_", investigation_type)), "/", 
                            "rsv_ses_model_outputs_", cohort, "_", year(study_start_date), 
                            "_", year(study_end_date), "_", codelist_type,
                            "_", investigation_type, ".csv"))
}  else{
  model_outputs %>%
    write_csv(path = paste0(here::here("output", "results", "models",
                            paste0("rsv_", investigation_type)), "/", 
                            "rsv_ses_model_outputs_", cohort, "_", year(study_start_date),
                            "_", year(study_end_date), "_", codelist_type,
                            "_", investigation_type, ".csv"))
}
