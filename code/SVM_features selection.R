library(kernlab)
library(caret)
library(ROCit)
library(tidyverse)
library(magrittr)
library(tidymodels)

features <- c("Transaction.Amount", "Account.Age.Days", "Transaction.Hour", "Quantity", "Customer.Age")
train_df$Is.Fraudulent <- as.factor(train_df$Is.Fraudulent)
test_df <- clean_data(test_df)
test_df$Is.Fraudulent <- as.factor(test_df$Is.Fraudulent)

preproc <- preProcess(train_df[, features], method = c("center", "scale"))
train_df[, features] <- predict(preproc, train_df[, features])
test_df[, features] <- predict(preproc, test_df[, features])

overall_training_start_time <- Sys.time()
f1_vec <- accuracy_vec <- sensitivity_vec <- specificity_vec <- auc_vec <- training_time_vec <- numeric(length(features))

for (i in seq_along(features)) {
  training_start_time <- Sys.time()
  
  formula_str <- paste("Is.Fraudulent ~ ", paste(features[1:i], collapse = " + "))
  formula_obj <- as.formula(formula_str)
  
  svm_rbf_kernlab_spec <- 
    svm_rbf(cost = 1, rbf_sigma = 0.1) %>%  
    set_engine('kernlab') %>%
    set_mode('classification')
  
  kernlab_workflow <- 
    workflow() %>% 
    add_formula(formula = formula_obj) %>% 
    add_model(svm_rbf_kernlab_spec)
  
  fitted_kernlab <- fit(kernlab_workflow, data = train_df)
  
  training_end_time <- Sys.time()
  
  training_time <- training_end_time - training_start_time
  training_time_vec[i] <- training_time
  
  svm_predict_value <- predict(fitted_kernlab, test_df, type = "prob")
  svm_predict_value %<>% mutate(`.pred_class` = as.factor(ifelse(.pred_1 > .pred_0, 1, 0)))

  confusion_matrix_test <- confusionMatrix(data = svm_predict_value$.pred_class, reference = test_df$Is.Fraudulent, positive = "0", mode = "everything")
  accuracy_vec[i] <- confusion_matrix_test$overall['Accuracy']
  sensitivity_vec[i] <- confusion_matrix_test$byClass['Sensitivity']
  specificity_vec[i] <- confusion_matrix_test$byClass['Specificity']
  f1_vec[i] <- confusion_matrix_test$byClass['F1']
  
  ROCit_obj_test <- rocit(score = svm_predict_value$.pred_1, class = test_df$Is.Fraudulent)
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