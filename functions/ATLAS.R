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

if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv")
}

# Package versions were set with
#renv::init()

# Use renv::restore() to install all required packages as per renv.lock
renv::restore()

# Load the packages
suppressPackageStartupMessages({
  library(readr)
  library(xgboost)
  library(dplyr)
  library(tidyr)
  library(purrr)
  library(bestNormalize)
  library(recipes)
  library(shapviz)
})

# ------------------------------------------------------------------------------
# ATLAS AI Function
# ------------------------------------------------------------------------------

ATLAS <- function(samples = NULL) {
  
  #Load data
  ATLAS_models <- read_rds("data/ATLAS.RDS") 
  
  ATLAS_models$xgboost_model_fit[[1]] <- xgboost::xgb.load("data/origin_model.xgb")
  ATLAS_models$xgboost_model_fit[[2]] <- xgboost::xgb.load("data/lineage_model.xgb")
  
  SITE_FEATURES <- read_rds("data/SITE_FEATURES.RDS")
  LINEAGE_FEATURES <- read_rds("data/LINEAGE_FEATURES.RDS")
  SITE_FEATURES_GENES <- SITE_FEATURES[SITE_FEATURES != "SEX_MF"]
  
  adjust_cols <- function(df, cols, classes) {
    
    for (i in seq_along(cols)) {
      if (!cols[i] %in% colnames(df)) {
        if (cols[i] == "SEX_MF") {
          warning("SEX_MF not included in the provided sample, please add if available (model will impute all missing values)")
          df[[cols[i]]] <- factor(NA)
        } else if (classes[i] == "numeric") {
          df[[cols[i]]] <- rep(NA_real_, nrow(df))
        } else {
          stop("Unknown class")
        }
      } else if (cols[i] == "SEX_MF") {
        # If SEX_MF is present, handle its transformation
        if (!all(df[[cols[i]]] %in% c("Male", "Female", "M", "F", "m", "f", "male", "female", NA))) {
          stop("SEX_MF should have factor levels of Male, Female or NA")
        }
        
        # Track if a value was changed to issue a single warning
        changed_value <- FALSE
        
        # Loop through all rows of SEX_MF and apply transformations
        for (j in seq_len(nrow(df))) {
          if (tolower(df[j, cols[i]]) %in% c("m", "male")) {
            df[j, cols[i]] <- "Male"
            changed_value <- TRUE
          } else if (tolower(df[j, cols[i]]) %in% c("f", "female")) {
            df[j, cols[i]] <- "Female"
            changed_value <- TRUE
          }
        }
        
        # Issue warning if a value was changed
        if (changed_value) {
          warning("SEX_MF values were adjusted to match the expected format (Male, Female, NA)")
        }
        
        # Check that the final format is a factor of Male, Female, or NA
        if (!all(df[[cols[i]]] %in% c("Male", "Female", NA))) {
          stop("SEX_MF should have factor levels of Male, Female or NA")
        }
        
        # Convert SEX_MF column to a factor
        df[[cols[i]]] <- factor(df[[cols[i]]], levels = c("Female", "Male"))
      }
    }
    
    #NKX3_1 variation of gene name
    # Check if a column exists in a dataframe
    column_exists <- function(df, colname) {
      colname %in% names(df)
    }
    
    # Define columns to be potentially RNA2validate
    cols_to_remove <- c("NKX3.1", "NKX3-1")
    
    # Filter out non-existing columns from the removal list
    cols_to_remove <- cols_to_remove[sapply(cols_to_remove, column_exists, df = df)]
    
    # Update RNA2validate dataframe
    df <- df %>%
      mutate(
        NKX3_1 = ifelse(is.na(NKX3_1) & column_exists(., "NKX3.1"), NKX3.1, NKX3_1),
        NKX3_1 = ifelse(is.na(NKX3_1) & column_exists(., "NKX3-1"), `NKX3-1`, NKX3_1)
      ) %>%
      dplyr::select(-all_of(cols_to_remove))
    
    
    return(df)
  }
  
  
  # specify the columns you want to add (if they don't exist)
  cols_site <- c("SEX_MF", SITE_FEATURES_GENES)  
  
  # specify the classes for the new columns
  classes_site <- c("factor", rep("numeric", length(SITE_FEATURES_GENES)))
  
  # apply the function
  samples_site <- adjust_cols(samples, cols_site, classes_site) %>%
    mutate(row_id = row_number())
  
  suppressMessages(samples_site <- samples_site %>%
                     dplyr::select(row_id, all_of(SITE_FEATURES_GENES)) %>%
                     group_by(row_id) %>%
                     nest() %>%
                     ungroup() %>%
                     mutate(data = map(data, ~ {
                       gene_data <- .x %>% as.numeric()
                       gene_names <- colnames(.x)
                       transformed_data <- yeojohnson(gene_data) %>%
                         pluck("x.t") %>%
                         scale() %>%
                         t()
                       colnames(transformed_data) <- gene_names
                       as_tibble(transformed_data)
                     })) %>%
                     unnest(cols = c(data)) %>%
                     inner_join(samples_site %>% dplyr::select(row_id, SEX_MF)) %>%
                     dplyr::select(-row_id))
  
  
  # specify the classes for the new columns
  classes_lineage <- c(rep("numeric", length(LINEAGE_FEATURES)))
  
  # apply the function
  samples_lineage <- adjust_cols(samples, LINEAGE_FEATURES, classes_lineage) %>%
    mutate(row_id = row_number())
  
  samples_lineage <- samples_lineage %>%
    dplyr::select(row_id, all_of(LINEAGE_FEATURES)) %>%
    group_by(row_id) %>%
    nest() %>%
    ungroup() %>%
    mutate(data = map(data, ~ {
      gene_data <- .x %>% as.numeric()
      gene_names <- colnames(.x)
      transformed_data <- yeojohnson(gene_data) %>%
        pluck("x.t") %>%
        scale() %>%
        t()
      colnames(transformed_data) <- gene_names
      as_tibble(transformed_data)
    })) %>%
    unnest(cols = c(data)) %>%
    dplyr::select(-row_id)
  
  
  model_predict <- function(data, model_preprocess, model_fit, model_levels) {
    
    # Initialize an empty list to store the predictions
    pred_probs_list <- list()
    
    # Loop over each row in the data
    for(i in 1:nrow(data)){
      # Generate predictions for each row
      pred_probs <- suppressWarnings({
        data[i, ] %>% 
          bake(model_preprocess, .) %>%
          as.matrix() %>%
          predict(model_fit, ., type = "prob") %>%
          t() %>%
          as_tibble()
      })
      
      # Set column names and add the tibble to the list
      colnames(pred_probs) <- model_levels
      pred_probs_list[[i]] <- pred_probs
    }
    
    # Combine all the tibbles in the list into one tibble
    pred_probs_tibble <- bind_rows(pred_probs_list)
    
    # Return the tibble
    pred_probs_tibble
  }
  
  get_max_values <- function(data) {
    # Create a tibble with 'Predicted Class' and 'Class Probability'
    max_values <- tibble(
      'Predicted Class' = map_chr(1:nrow(data), ~ colnames(data)[which.max(data[.x, ])]),
      'Max Probability' = map_dbl(1:nrow(data), ~ max(data[.x, ], na.rm = TRUE))
    )
    
    # Return the tibble
    max_values
  }
  
  
  get_max_values <- function(data) {
    # Create a tibble with 'Predicted Class' and 'Class Probability'
    max_values <- tibble(
      'Predicted Class' = map_chr(1:nrow(data), ~ colnames(data)[which.max(data[.x, ])]),
      'Max Probability' = map_dbl(1:nrow(data), ~ max(data[.x, ], na.rm = TRUE))
    )
    
    # Return the tibble
    max_values
  }
  
  grab_shapley <- function(model_fit, processed_data, prediction_classes) {
    
    processed_data_matrix <- processed_data %>% 
      dplyr::select(-SAMPLE_ID) %>%
      as.matrix
    
    # Add a row of zeros if there's only one row in the matrix to get it to work with shapviz
    if (nrow(processed_data_matrix) == 1) {
      zero_row <- matrix(rep(0, ncol(processed_data_matrix)), nrow = 1)
      processed_data_matrix <- rbind(processed_data_matrix, zero_row)
    }
    
    shapley_data <- shapviz(model_fit, 
                            X_pred = processed_data_matrix)
    
    names(shapley_data) <- prediction_classes
    
    # List to store results for each class
    results_list <- list()
    
    # Loop through each class in shap_values
    for (class_name in names(shapley_data)) {
      # Process the SHAP values for each class
      processed_df <- shapley_data[[class_name]]$S %>%
        as_tibble() %>%
        { if (nrow(processed_data) == 1) .[1, ] else . } %>% # check for if only one row in input
        bind_cols(processed_data %>% dplyr::select(SAMPLE_ID)) %>%
        pivot_longer(cols = -SAMPLE_ID) %>%
        group_by(name) %>%
        nest() %>%
        ungroup() %>%
        mutate(sum = map_dbl(data, ~ sum(.x$value))) %>%
        filter(sum != 0) %>%
        dplyr::select(-sum) %>%
        unnest(data) %>%
        mutate(class = class_name) %>%
        mutate(absolute_value = abs(value)) %>%
        dplyr::select(SAMPLE_ID, gene = name, class, value, absolute_value)
      
      # Store the result in the list
      results_list[[class_name]] <- processed_df
    }
    bind_rows(results_list)
  }
  
  ATLAS_models %>%
    bind_cols(tibble(data_input = list(samples, samples),
                     data_processed = list(samples_site, samples_lineage))) %>% 
    mutate(class_prob = pmap(list(data_processed, model_preprocess, xgboost_model_fit, model_levels), model_predict),
           pred_class = map(class_prob, get_max_values),
           data_input = map(data_input, ~ {
             if ("SAMPLE_ID" %in% names(..1)) ..1 
             else ..1 %>% mutate(SAMPLE_ID = paste0("sample_", row_number())) %>% dplyr::select(SAMPLE_ID, everything())
           }),
           data_processed = pmap(list(data_input, model_preprocess, data_processed), ~ {
             bind_cols(..1 %>% dplyr::select(SAMPLE_ID), suppressWarnings(bake(..2, ..3)))
           }),
           Predictions = pmap(list(data_input, pred_class, class_prob), ~ {
             bind_cols(..1 %>% dplyr::select(SAMPLE_ID), ..2, ..3)
           })) %>%
    dplyr::select(`Model Class` = model_class,
                  `XGBoost Model` = xgboost_model_fit,
                  `Model Processing` = model_preprocess,
                  `Prediction Classes` = model_levels,
                  `Input Data` = data_input,
                  `Processed Data` = data_processed,
                  Predictions) %>%
    mutate(Predictions = map2(`Model Class`, Predictions, 
                              ~ {
                                if (.x == "Site of Origin") {
                                  .y <- .y %>% rename_with(~ifelse(. == "Max Probability", "Origin Score (Max Probability)", .), everything())
                                } else {
                                  .y <- .y %>% rename_with(~ifelse(. == "Max Probability", "Lineage Score (Max Probability)", .), everything())
                                }
                                .y
                              }),
           `Shapley Values` = pmap(list(`XGBoost Model`, `Processed Data`, `Prediction Classes`), grab_shapley))
}