library(dplyr)
library(here)
library(arrow)
library(lubridate)
library(survival)
library(broom)
library(readr)

## create output directories ----
fs::dir_create(here("analysis"))

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
  ##Use Poisson regression for outcomes looking first at ethnicity 
  
  #rsv primary by ethnicity
  rsv_mild_ethnicity <- glm(rsv_primary_inf ~ latest_ethnicity_group + 
                              age + sex + 
                              rurality_classification + 
                              offset(log(time_rsv_primary)), 
                            data = df_input, family = poisson)
  rsv_mild_ethnicity_output <- tidy(rsv_mild_ethnicity)
  
  #rsv secondary by ethnicity
  rsv_severe_ethnicity <- glm(rsv_secondary_inf ~ latest_ethnicity_group +
                                age + sex + 
                                rurality_classification + 
                                offset(log(time_rsv_secondary)),
                              data = df_input, family = poisson)
  rsv_severe_ethnicity_output <- tidy(rsv_severe_ethnicity)
  
  #rsv mortality by ethnicity
  rsv_mortality_ethnicity <- glm(rsv_mortality ~ latest_ethnicity_group + 
                                   age + sex + 
                                   rurality_classification + 
                                   offset(log(time_rsv_mortality)),
                                 data = df_input, family = poisson)
  rsv_mortality_ethnicity_output <- tidy(rsv_mortality_ethnicity)
  
  #flu primary by ethnicity
  flu_mild_ethnicity <- glm(flu_primary_inf ~ latest_ethnicity_group + 
                              age + sex + 
                              rurality_classification + 
                              offset(log(time_flu_primary)),
                            data = df_input, family = poisson)
  flu_mild_ethnicity_output <- tidy(flu_mild_ethnicity)
  
  #flu secondary by ethnicity
  flu_severe_ethnicity <- glm(flu_secondary_inf ~ latest_ethnicity_group + 
                                age + sex + 
                                rurality_classification + 
                                offset(log(time_flu_secondary)),
                              data = df_input, family = poisson)
  flu_severe_ethnicity_output <- tidy(flu_severe_ethnicity)
  
  #flu mortality by ethnicity
  flu_mortality_ethnicity <- glm(flu_mortality ~ latest_ethnicity_group + 
                                   age + sex + 
                                   rurality_classification + 
                                   offset(log(time_flu_mortality)),
                                 data = df_input, family = poisson)
  flu_mortality_ethnicity_output <- tidy(flu_mortality_ethnicity)
  
  if (study_start_date >= covid_season_min) {
    #covid primary by ethnicity
    covid_mild_ethnicity <- glm(covid_primary_inf ~ latest_ethnicity_group + 
                                  age + sex + 
                                  rurality_classification + 
                                  offset(log(time_covid_primary)),
                                data = df_input, family = poisson)
    covid_mild_ethnicity_output <- tidy(covid_mild_ethnicity)
    
    #covid secondary by ethnicity
    covid_severe_ethnicity <- glm(covid_secondary_inf ~ latest_ethnicity_group + 
                                    age + sex + 
                                    rurality_classification + 
                                    offset(log(time_covid_secondary)),
                                  data = df_input, family = poisson)
    covid_severe_ethnicity_output <- tidy(covid_severe_ethnicity)
    
    #covid mortality by ethnicity
    covid_mortality_ethnicity <- glm(covid_mortality ~ latest_ethnicity_group + 
                                       age + sex + 
                                       rurality_classification + 
                                       offset(log(time_covid_mortality)),
                                     data = df_input, family = poisson)
    covid_mortality_ethnicity_output <- tidy(covid_mortality_ethnicity)
  }
  
  if (codelist_type == "sensitive") {
    #overall_resp primary by ethnicity
    overall_resp_mild_ethnicity <- glm(overall_resp_primary_inf ~ latest_ethnicity_group + 
                                         age + sex + 
                                         rurality_classification + 
                                         offset(log(time_overall_resp_primary)),
                                       data = df_input, family = poisson)
    overall_resp_mild_ethnicity_output <- tidy(overall_resp_mild_ethnicity)
    
    #overall_resp secondary by ethnicity
    overall_resp_severe_ethnicity <- glm(overall_resp_secondary_inf ~ latest_ethnicity_group + 
                                           age + sex + 
                                           rurality_classification + 
                                           offset(log(time_overall_resp_secondary)),
                                         data = df_input, family = poisson)
    overall_resp_severe_ethnicity_output <- tidy(overall_resp_severe_ethnicity)
    
    #overall_resp mortality by ethnicity
    overall_resp_mortality_ethnicity <- glm(overall_resp_mortality ~ latest_ethnicity_group + 
                                              age + sex + 
                                              rurality_classification + 
                                              offset(log(time_overall_resp_mortality)),
                                            data = df_input, family = poisson)
    overall_resp_mortality_ethnicity_output <- tidy(overall_resp_mortality_ethnicity)
  }
  
  #all cause mortality by ethnicity
  all_cause_mortality_ethnicity <- glm(all_cause_mortality ~ latest_ethnicity_group + 
                                         age + sex + 
                                         rurality_classification + 
                                         offset(log(time_all_cause_mortality)),
                                       data = df_input, family = poisson)
  all_cause_mortality_ethnicity_output <- tidy(all_cause_mortality_ethnicity)

#add models for infants subgroup
#} else if (cohort == "infants_subgroup") {
  
} else {
  ##Use Poisson regression for outcomes looking first at ethnicity 
  #rsv primary by ethnicity
  rsv_mild_ethnicity <- glm(rsv_primary_inf ~ latest_ethnicity_group + 
                              age_band + sex + 
                              rurality_classification + 
                              #prior_flu_vaccination +
                              offset(log(time_rsv_primary)), 
                            data = df_input, family = poisson)
  rsv_mild_ethnicity_output <- tidy(rsv_mild_ethnicity)
  
  #rsv secondary by ethnicity
  rsv_severe_ethnicity <- glm(rsv_secondary_inf ~ latest_ethnicity_group +
                                age_band + sex + 
                                rurality_classification + 
                                #prior_flu_vaccination +
                                offset(log(time_rsv_secondary)),
                              data = df_input, family = poisson)
  rsv_severe_ethnicity_output <- tidy(rsv_severe_ethnicity)
  
  #rsv mortality by ethnicity
  rsv_mortality_ethnicity <- glm(rsv_mortality ~ latest_ethnicity_group + 
                                   age_band + sex + 
                                   rurality_classification + 
                                   #prior_flu_vaccination +
                                   offset(log(time_rsv_mortality)),
                                 data = df_input, family = poisson)
  rsv_mortality_ethnicity_output <- tidy(rsv_mortality_ethnicity)
    
  #flu primary by ethnicity
  flu_mild_ethnicity <- glm(flu_primary_inf ~ latest_ethnicity_group + 
                              age_band + sex + 
                              rurality_classification + 
                              #prior_flu_vaccination +
                              offset(log(time_flu_primary)),
                            data = df_input, family = poisson)
  flu_mild_ethnicity_output <- tidy(flu_mild_ethnicity)
  
  #flu secondary by ethnicity
  flu_severe_ethnicity <- glm(flu_secondary_inf ~ latest_ethnicity_group + 
                                age_band + sex + 
                                rurality_classification + 
                                #prior_flu_vaccination +
                                offset(log(time_flu_secondary)),
                              data = df_input, family = poisson)
  flu_severe_ethnicity_output <- tidy(flu_severe_ethnicity)
  
  #flu mortality by ethnicity
  flu_mortality_ethnicity <- glm(flu_mortality ~ latest_ethnicity_group + 
                                   age_band + sex + 
                                   rurality_classification + 
                                   #prior_flu_vaccination +
                                   offset(log(time_flu_mortality)),
                                 data = df_input, family = poisson)
  flu_mortality_ethnicity_output <- tidy(flu_mortality_ethnicity)

  if (codelist_type == "sensitive") {
    #overall_resp primary by ethnicity
    overall_resp_mild_ethnicity <- glm(overall_resp_primary_inf ~ latest_ethnicity_group + 
                                         age_band + sex + 
                                         rurality_classification + 
                                         #prior_flu_vaccination +
                                         offset(log(time_overall_resp_primary)),
                                       data = df_input, family = poisson)
    overall_resp_mild_ethnicity_output <- tidy(overall_resp_mild_ethnicity)
    
    #overall_resp secondary by ethnicity
    overall_resp_severe_ethnicity <- glm(overall_resp_secondary_inf ~ latest_ethnicity_group + 
                                           age_band + sex + 
                                           rurality_classification + 
                                           #prior_flu_vaccination +
                                           offset(log(time_overall_resp_secondary)),
                                         data = df_input, family = poisson)
    overall_resp_severe_ethnicity_output <- tidy(overall_resp_severe_ethnicity)
    
    #overall_resp mortality by ethnicity
    overall_resp_mortality_ethnicity <- glm(overall_resp_mortality ~ latest_ethnicity_group + 
                                              age_band + sex + 
                                              rurality_classification + 
                                              #prior_flu_vaccination +
                                              offset(log(time_overall_resp_mortality)),
                                            data = df_input, family = poisson)
    overall_resp_mortality_ethnicity_output <- tidy(overall_resp_mortality_ethnicity)
  }
  
  #all cause mortality by ethnicity
  all_cause_mortality_ethnicity <- glm(all_cause_mortality ~ latest_ethnicity_group + 
                                         age_band + sex + 
                                         rurality_classification + 
                                         #prior_flu_vaccination +
                                         offset(log(time_all_cause_mortality)),
                                       data = df_input, family = poisson)
  all_cause_mortality_ethnicity_output <- tidy(all_cause_mortality_ethnicity)
  
  if (study_start_date >= covid_season_min) {
    ##Use Poisson regression for outcomes looking first at ethnicity 
    
    #rsv primary by ethnicity
    rsv_mild_ethnicity <- glm(rsv_primary_inf ~ latest_ethnicity_group +
                                age_band + sex + 
                                rurality_classification + 
                                #prior_flu_vaccination +
                                #time_since_last_covid_vaccination +
                                offset(log(time_rsv_primary)), 
                              data = df_input, family = poisson)
    rsv_mild_ethnicity_output <- tidy(rsv_mild_ethnicity)
    
    #rsv secondary by ethnicity
    rsv_severe_ethnicity <- glm(rsv_secondary_inf ~ latest_ethnicity_group +
                                  age_band + sex + 
                                  rurality_classification + 
                                  #prior_flu_vaccination +
                                  #time_since_last_covid_vaccination +
                                  offset(log(time_rsv_secondary)),
                                data = df_input, family = poisson)
    rsv_severe_ethnicity_output <- tidy(rsv_severe_ethnicity)
    
    #rsv mortality by ethnicity
    rsv_mortality_ethnicity <- glm(rsv_mortality ~ latest_ethnicity_group + 
                                     age_band + sex + 
                                     rurality_classification + 
                                     #prior_flu_vaccination +
                                     #time_since_last_covid_vaccination +
                                     offset(log(time_rsv_mortality)),
                                   data = df_input, family = poisson)
    rsv_mortality_ethnicity_output <- tidy(rsv_mortality_ethnicity)
    
    #flu primary by ethnicity
    flu_mild_ethnicity <- glm(flu_primary_inf ~ latest_ethnicity_group + 
                                age_band + sex + 
                                rurality_classification + 
                                #prior_flu_vaccination +
                                #time_since_last_covid_vaccination +
                                offset(log(time_flu_primary)),
                              data = df_input, family = poisson)
    flu_mild_ethnicity_output <- tidy(flu_mild_ethnicity)
    
    #flu secondary by ethnicity
    flu_severe_ethnicity <- glm(flu_secondary_inf ~ latest_ethnicity_group + 
                                  age_band + sex + 
                                  rurality_classification + 
                                  #prior_flu_vaccination +
                                  #time_since_last_covid_vaccination +
                                  offset(log(time_flu_secondary)),
                                data = df_input, family = poisson)
    flu_severe_ethnicity_output <- tidy(flu_severe_ethnicity)
    
    #flu mortality by ethnicity
    flu_mortality_ethnicity <- glm(flu_mortality ~ latest_ethnicity_group + 
                                     age_band + sex + 
                                     rurality_classification + 
                                     #prior_flu_vaccination +
                                     #time_since_last_covid_vaccination +
                                     offset(log(time_flu_mortality)),
                                   data = df_input, family = poisson)
    flu_mortality_ethnicity_output <- tidy(flu_mortality_ethnicity)
    
    covid_mild_ethnicity <- glm(covid_primary_inf ~ latest_ethnicity_group + 
                                  age_band + sex + 
                                  rurality_classification +
                                  #prior_flu_vaccination +
                                  #time_since_last_covid_vaccination +
                                  offset(log(time_covid_primary)),
                                data = df_input, family = poisson)
    covid_mild_ethnicity_output <- tidy(covid_mild_ethnicity)
    
    #covid secondary by ethnicity
    covid_severe_ethnicity <- glm(covid_secondary_inf ~ latest_ethnicity_group + 
                                    age_band + sex + 
                                    rurality_classification + 
                                    #prior_flu_vaccination +
                                    #time_since_last_covid_vaccination +
                                    offset(log(time_covid_secondary)),
                                  data = df_input, family = poisson)
    covid_severe_ethnicity_output <- tidy(covid_severe_ethnicity)
    
    #covid mortality by ethnicity
    covid_mortality_ethnicity <- glm(covid_mortality ~ latest_ethnicity_group + 
                                      age_band + sex + 
                                      rurality_classification + 
                                      #prior_flu_vaccination +
                                      #time_since_last_covid_vaccination +
                                      offset(log(time_covid_mortality)),
                                    data = df_input, family = poisson)
    covid_mortality_ethnicity_output <- tidy(covid_mortality_ethnicity)
    
    if (codelist_type == "sensitive") {
      #overall_resp primary by ethnicity
      overall_resp_mild_ethnicity <- glm(overall_resp_primary_inf ~ latest_ethnicity_group + 
                                           age_band + sex + 
                                           rurality_classification + 
                                           #prior_flu_vaccination +
                                           #time_since_last_covid_vaccination +
                                           offset(log(time_overall_resp_primary)),
                                         data = df_input, family = poisson)
      overall_resp_mild_ethnicity_output <- tidy(overall_resp_mild_ethnicity)
      
      #overall_resp secondary by ethnicity
      overall_resp_severe_ethnicity <- glm(overall_resp_secondary_inf ~ latest_ethnicity_group + 
                                             age_band + sex + 
                                             rurality_classification + 
                                             #prior_flu_vaccination +
                                             #time_since_last_covid_vaccination +
                                             offset(log(time_overall_resp_secondary)),
                                           data = df_input, family = poisson)
      overall_resp_severe_ethnicity_output <- tidy(overall_resp_severe_ethnicity)
      
      #overall_resp mortality by ethnicity
      overall_resp_mortality_ethnicity <- glm(overall_resp_mortality ~ latest_ethnicity_group + 
                                                age_band + sex + 
                                                rurality_classification + 
                                                #prior_flu_vaccination +
                                                #time_since_last_covid_vaccination +
                                                offset(log(time_overall_resp_mortality)),
                                              data = df_input, family = poisson)
      overall_resp_mortality_ethnicity_output <- tidy(overall_resp_mortality_ethnicity)
    }
    
    #all cause mortality by ethnicity
    all_cause_mortality_ethnicity <- glm(all_cause_mortality ~ latest_ethnicity_group + 
                                           age_band + sex + 
                                           rurality_classification + 
                                           #prior_flu_vaccination +
                                           #time_since_last_covid_vaccination +
                                           offset(log(time_all_cause_mortality)),
                                         data = df_input, family = poisson)
    all_cause_mortality_ethnicity_output <- tidy(all_cause_mortality_ethnicity)
  }
}

#define a vector of names for the model outputs
if (study_start_date < covid_season_min) {
  model_names <- c("Mild RSV by Ethnicity", "Severe RSV by Ethnicity",
                   "RSV Mortality By Ethnicity", "Mild Influenza by Ethnicity",
                   "Severe Influenza by Ethnicity", "Influenza Mortality by Ethnicity",
                   "All Cause Mortality by Ethnicity")
} else if (codelist_type == "sensitive") {
  model_names <- c("Mild RSV by Ethnicity", "Severe RSV by Ethnicity",
                   "RSV Mortality By Ethnicity", "Mild Influenza by Ethnicity",
                   "Severe Influenza by Ethnicity", "Influenza Mortality by Ethnicity",
                   "Mild Overall Respiratory Virus by Ethnicity", 
                   "Severe Overall Respiratory Virus by Ethnicity",
                   "Overall Respiratory Virus Mortality by Ethnicity",
                   "All Cause Mortality by Ethnicity")
} else if (study_start_date >= covid_season_min) {
  model_names <- c("Mild RSV by Ethnicity", "Severe RSV by Ethnicity",
                   "RSV Mortality By Ethnicity", "Mild Influenza by Ethnicity",
                   "Severe Influenza by Ethnicity", "Influenza Mortality by Ethnicity",
                   "Mild COVID-19 by Ethnicity", "Severe COVID-19 by Ethnicity",
                   "COVID-19 Mortality by Ethnicity", "All Cause Mortality by Ethnicity")
} else {
  model_names <- c("Mild RSV by Ethnicity", "Severe RSV by Ethnicity",
                   "RSV Mortality By Ethnicity", "Mild Influenza by Ethnicity",
                   "Severe Influenza by Ethnicity", "Influenza Mortality by Ethnicity",
                   "Mild COVID-19 by Ethnicity", "Severe COVID-19 by Ethnicity",
                   "COVID-19 Mortality by Ethnicity", 
                   "Mild Overall Respiratory Virus by Ethnicity",
                   "Severe Overall Respiratory Virus by Ethnicity",
                   "Overall Respiratory Virus Mortality by Ethnicity",
                   "All Cause Mortality by Ethnicity")
}

#create the model outputs list
model_outputs_list <- list(rsv_mild_ethnicity_output, rsv_severe_ethnicity_output,
                           rsv_mortality_ethnicity_output, flu_mild_ethnicity_output,
                           flu_severe_ethnicity_output, flu_mortality_ethnicity_output,
                           all_cause_mortality_ethnicity_output)

#adjust the model outputs list based on the conditions
if (study_start_date >= covid_season_min) {
  model_outputs_list <- c(model_outputs_list, list(covid_mild_ethnicity_output,
                                                   covid_severe_ethnicity_output,
                                                   covid_mortality_ethnicity_output))
}
if (codelist_type == "sensitive") {
  model_outputs_list <- c(model_outputs_list, list(overall_resp_mild_ethnicity_output,
                                                   overall_resp_severe_ethnicity_output,
                                                   overall_resp_mortality_ethnicity_output))
}
if (study_start_date >= covid_season_min & codelist_type == "sensitive") {
  model_outputs_list <- c(model_outputs_list, list(covid_mild_ethnicity_output,
                                                   covid_severe_ethnicity_output,
                                                   covid_mortality_ethnicity_output,
                                                   overall_resp_mild_ethnicity_output,
                                                   overall_resp_severe_ethnicity_output,
                                                   overall_resp_mortality_ethnicity_output))
}

#bind model outputs together and add a column with the corresponding names
model_outputs <- do.call(rbind, lapply(seq_along(model_outputs_list), function(i) {
  cbind(model_name = model_names[i], model_outputs_list[[i]])
}))

## create output directories ----
fs::dir_create(here("output", "results", "models"))

#save model output 
if (length(args) == 0) {
  model_outputs %>%
    write_csv(file = paste0(here::here("output", "results", "models"), "/", 
                            "ethnicity_model_outputs_", cohort, "_", year(study_start_date), 
                            "_", year(study_end_date), "_", codelist_type,
                            "_", investigation_type, ".csv"))
}  else{
  model_outputs %>%
    write_csv(path = paste0(here::here("output", "results", "models"), "/", 
                            "ethnicity_model_outputs_", cohort, "_", year(study_start_date),
                            "_", year(study_end_date), "_", codelist_type, 
                            "_", investigation_type, ".csv"))
}