# Load required libraries
library(dplyr)
library(ggplot2)
library(caret)
library(xgboost)
library(optparse)
library(tidyr)
library(readr)
library(purrr)
library(parallel)
library(ggpubr)
library(pROC)
library(ROSE)

# Read train and test data
train_df <- read.csv('/Users/leo/Desktop/Master/112-2DataScience/archive_final_project/Fraudulent_E-Commerce_Transaction_Data.csv')
test_df <- read.csv('/Users/leo/Desktop/Master/112-2DataScience/archive_final_project/test.csv')

# Data cleaning function
clean_data <- function(df) {
  df <- df %>%
    mutate(`Transaction.Date` = as.Date(`Transaction.Date`),
           `Transaction.Day` = as.integer(format(`Transaction.Date`, "%d")),
           `Transaction.DOW` = as.integer(format(`Transaction.Date`, "%u")),
           `Transaction.Month` = as.integer(format(`Transaction.Date`, "%m")),
           `Customer.Age` = ifelse(`Customer.Age` <= -9, abs(`Customer.Age`), 
                                   ifelse(`Customer.Age` < 9, round(mean(`Customer.Age`), 0), `Customer.Age`)),
           `Is.Address.Match` = as.integer(`Shipping.Address` == `Billing.Address`)) %>%
    select(-c(`Transaction.ID`, `Customer.ID`, `Customer.Location`, 
              `IP.Address`, `Transaction.Date`, `Shipping.Address`, `Billing.Address`))
  
  df <- df %>%
    mutate_if(is.integer, as.integer) %>%
    mutate_if(is.numeric, as.numeric)
  
  return(df)
}

# Clean the data
train_df <- clean_data(train_df)
test_df <- clean_data(test_df)

# Balance the dataset using undersampling
n2 <- sum(train_df$Is.Fraudulent == 1)
train_df <- ovun.sample(Is.Fraudulent ~ ., data = train_df, method = "under", N = n2 * 2, seed = 5)$data


#over+under
#n1 <- sum(train_df$Is.Fraudulent == 1)
#n0 <- sum(train_df$Is.Fraudulent == 0)
#n_target <- (n1 + n0)
#over_df <- ovun.sample(Is.Fraudulent ~ ., data = train_df, method = "over", N = n_target, seed = 5)$data
#under_df <- ovun.sample(Is.Fraudulent ~ ., data = train_df, method = "under", N = n_target, seed = 5)$data
#balanced_df <- rbind(over_df, under_df)
#set.seed(123)
#train_df <- balanced_df[sample(nrow(balanced_df)),]

# Train and test labels
train_label <- factor(make.names(train_df$`Is.Fraudulent`))
test_label <- factor(make.names(test_df$`Is.Fraudulent`))

# List of classifiers
classifiers <- list(
  #"Logistic Regression" = "glm",
  #"Decision Tree" = "rpart"
  "Random Forest" = "rf"
  #"XGB" = "xgbTree",
  #"SVM" = "svmRadial"
  #"KNN" = "knn"
)

# Features based on importance
features <- c("Transaction.Amount", "Account.Age.Days", "Transaction.Hour", "Quantity", "Customer.Age")

# Function to train and evaluate models
evaluate_models <- function(train_data, train_label, test_data, test_label) {
  results <- data.frame(Classifier = character(), Accuracy = numeric(), AUC = numeric(), 
                        Specificity = numeric(), F1 = numeric(), TrainingTime = numeric(), stringsAsFactors = FALSE)
  train_control <- trainControl(method = "cv", number = 5, classProbs = TRUE, summaryFunction = twoClassSummary)
  
  for (name in names(classifiers)) {
    set.seed(123)  # Set seed for reproducibility
    start_time <- Sys.time()
    model <- train(train_data, train_label, method = classifiers[[name]], trControl = train_control, metric = "ROC")
    training_time <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
    predictions <- predict(model, test_data)
    probs <- predict(model, test_data, type = "prob")
    accuracy <- mean(predictions == test_label)
    
    confusion <- caret::confusionMatrix(data = predictions, reference = test_label, positive = "X0", mode = "everything")
    specificity <- confusion$byClass["Specificity"]
    f1_score <- confusion$byClass["F1"]
    
    roc_curve <- roc(test_label, probs[,2], levels = rev(levels(test_label)))
    auc_value <- auc(roc_curve)
    
    results <- rbind(results, data.frame(Classifier = name, Accuracy = accuracy, AUC = auc_value, 
                                         Specificity = specificity, F1 = f1_score, TrainingTime = training_time))
    
    cat(paste("Classifier:", name, "\n"))
    cat(paste("Accuracy:", accuracy, "\n"))
    cat("Confusion Matrix:\n")
    print(confusion)
    cat(paste("AUC:", auc_value, "\n"))
    cat(paste("Training Time (s):", training_time, "\n"))
    plot(roc_curve, main = paste("ROC Curve -", name))
  }
  
  return(results)
}

# Evaluate models with different numbers of features
results_all <- list()
for (i in 1:length(features)) {
  selected_features <- features[1:i]
  cat(paste("\nEvaluating models with top", i, "features:", paste(selected_features, collapse = ", "), "\n"))
  train_data_subset <- train_df[, selected_features, drop = FALSE]
  test_data_subset <- test_df[, selected_features, drop = FALSE]
  
  results <- evaluate_models(train_data_subset, train_label, test_data_subset, test_label)
  results$Features <- i
  results_all[[i]] <- results
}

# Combine results and print
final_results <- do.call(rbind, results_all)
print(final_results)
