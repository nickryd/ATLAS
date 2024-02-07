# ------------------------------------------------------------------------------
#                           _______ _                _____   
#                        /\|__   __| |        /\    / ____|
#                       /  \  | |  | |       /  \  | (___  
#                     / /\ \ | |  | |      / /\ \  \___ \  
#                   / ____ \| |  | |____ / ____ \ ____) |
#                 /_/    \_|_|  |______/_/    \_|_____/
# ------------------------------------------------------------------------------
#
# Copyright 2023 University of Wisconsin, Nicholas (Nick) Rydzewski, Shuang (George) Zhao
#
# ------------------------------------------------------------------------------
# Load packages
# ------------------------------------------------------------------------------

#Will download and load: readr, xgboost, dplyr, tidyr, purrr, 
  #bestNormalize, recipes, shapviz and install dependencies)
source("functions/ATLAS.R")

# ------------------------------------------------------------------------------
# Load data
# ------------------------------------------------------------------------------

#Data needs to be in the format of a dataframe/tibble with the following columns:
  #SAMPLE_ID (optional) - if not present a SAMPLE_ID will be created 
  #SEX_MF (Factor with levels Female and Male)
  #Rest of columns are expression values with gene symbols (HGNC)
  #NOTE: Gene expression can be in any format except for a per gene normalization
    #across entire dataset, as every sample is analyzed independently.

samples_example <- read_csv("data/samples_example.csv")
samples_examples_truth <- read_csv("data/samples_examples_truth.csv")

# ------------------------------------------------------------------------------
# Run Model
# ------------------------------------------------------------------------------

#Roughly 20 seconds for 5 samples (time varies based on number of NAs)
samples_output <- ATLAS(samples_example) 

#examples - confirm predictions
samples_output$Predictions[[1]] %>% 
  dplyr::select(SAMPLE_ID, site_predictions = `Predicted Class`) %>%
  inner_join(samples_output$Predictions[[2]] %>% 
               dplyr::select(SAMPLE_ID, lineage_predictions = `Predicted Class`))

samples_examples_truth

#explore columns in output
samples_output$`XGBoost Model` #XGBoost model parameters
samples_output$`Model Processing` #Model pre-processing steps
samples_output$`Prediction Classes` #22 Cancer Site of Origin Classes, 8 Lineage Classes
samples_output$`Input Data` #Unadjusted input data
samples_output$`Processed Data` #Adjusted data for model
samples_output$Predictions #Model Predictions
samples_output$`Shapley Values` #Each sample and the associated feature importance for that sample

#Example - Glioma Sample
samples_output$Predictions[[1]][1,]

#Evaluate what genes contributed to this sample being classified correctly
samples_output$`Shapley Values`[[1]] %>% 
  dplyr::filter(SAMPLE_ID == "TCGA_02_0325_01", class == "CNS Cancer") %>% 
  arrange(-absolute_value)
