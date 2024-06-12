library(xgboost)
library(caret)
library(ROCit)
library(tidyverse)
library(magrittr)
library(tidymodels)
library(ggplot2)
library(pROC)

features <- c("Transaction.Amount", "Account.Age.Days", "Transaction.Hour", "Quantity", "Customer.Age",
              "Transaction.DOW", "Is.Address.Match", "Transaction.Month",
              "Transaction.Day")
train_df$Is.Fraudulent <- as.factor(train_df$Is.Fraudulent)
test_df <- clean_data(test_df)
test_df$Is.Fraudulent <- as.factor(test_df$Is.Fraudulent)

overall_training_start_time <- Sys.time()
f1_vec <- accuracy_vec <- sensitivity_vec <- specificity_vec <- auc_vec <- training_time_vec <- numeric(length(features))

for (i in seq_along(features)) {
  training_start_time <- Sys.time()
  
  formula_str <- paste("Is.Fraudulent ~ ", paste(features[1:i], collapse = " + "))
  formula_obj <- as.formula(formula_str)
  
  boost_tree_xgboost_spec <- 
    boost_tree() %>%
    set_engine('xgboost') %>%
    set_mode('classification')
  
  xgboost <- workflow() %>% 
    add_model(boost_tree_xgboost_spec) %>% 
    add_formula(formula = formula_obj)
  
  fitted_xgboost <- fit(xgboost, data = train_df)
  training_end_time <- Sys.time()
  
  training_time <- training_end_time - training_start_time
  training_time_vec[i] <- training_time
  
  xgboost_predict_value <- predict(fitted_xgboost, test_df, type = "prob")
  xgboost_predict_value %<>% mutate(`.pred_class` = as.factor(ifelse(.pred_1 > .pred_0, 1, 0)))
  
  confusion_matrix_test <- confusionMatrix(data = xgboost_predict_value$.pred_class, reference = test_df$Is.Fraudulent, positive = "0", mode = "everything")
  accuracy_vec[i] <- confusion_matrix_test$overall['Accuracy']
  sensitivity_vec[i] <- confusion_matrix_test$byClass['Sensitivity']
  specificity_vec[i] <- confusion_matrix_test$byClass['Specificity']
  f1_vec[i] <- confusion_matrix_test$byClass['F1']
  
  ROCit_obj_test <- rocit(score = xgboost_predict_value$.pred_1, class = test_df$Is.Fraudulent)
  auc_vec[i] <- ciAUC(ROCit_obj_test)$AUC
}


result_df <- data.frame(
  Features = features,
  Accuracy = accuracy_vec,
  Sensitivity = sensitivity_vec,
  Specificity = specificity_vec,
  F1 = f1_vec,
  AUC = auc_vec,
  Training_Time = training_time_vec
)

print(result_df)