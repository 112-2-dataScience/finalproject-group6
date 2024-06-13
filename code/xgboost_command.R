library(xgboost)
library(caret)
library(ROCit)
library(tidyverse)
library(magrittr)
library(tidymodels)
library(ggplot2)
library(pROC)

train_df <- read.csv('archive/Fraudulent_E-Commerce_Transaction_Data.csv')
test_df <- read.csv('archive/Fraudulent_E-Commerce_Transaction_Data_2.csv')
clean_data <- function(df) {
  # 將Transaction Date轉為datetime
  df$Transaction.Date <- as.Date(df$Transaction.Date)
  
  # 每個月幾號、星期幾、月份
  df$Transaction.Day <- as.numeric(format(df$Transaction.Date, "%d"))
  df$Transaction.DOW <- as.numeric(format(df$Transaction.Date, "%u"))
  df$Transaction.Month <- as.numeric(format(df$Transaction.Date, "%m"))
  
  # 修正Customer Age中的異常值
  mean_value <- round(mean(df$Customer.Age, na.rm = TRUE), 0)
  df$Customer.Age <- ifelse(df$Customer.Age <= -9,
                            abs(df$Customer.Age),
                            df$Customer.Age)
  df$Customer.Age <- ifelse(df$Customer.Age < 9,
                            mean_value,
                            df$Customer.Age)
  
  # Shipping Address與Billing Address的異同（異=0，同=1）
  df$Is.Address.Match <- as.integer(df$Shipping.Address == df$Billing.Address)
  
  # 除去不相關的features
  df <- df[, !names(df) %in% c("Transaction.ID", "Customer.ID", "Customer.Location",
                               "IP.Address", "Transaction.Date", "Shipping.Address", "Billing.Address")]
  
  # downcast datatype
  int_col <- sapply(df, is.integer)
  num_col <- sapply(df, is.numeric) & !int_col
  df[int_col] <- lapply(df[int_col], as.integer)
  df[num_col] <- lapply(df[num_col], as.numeric)
  
  return(df)
}

train_df <- clean_data(train_df)
n2 <- sum(train_df$Is.Fraudulent == 1)
train_df  <-ovun.sample(Is.Fraudulent ~ ., data = train_df, method = "under", N = n2*2, seed = 5)$data
test_df <- clean_data(test_df)
train_df$Is.Fraudulent <- as.factor(train_df$Is.Fraudulent)
test_df$Is.Fraudulent <- as.factor(test_df$Is.Fraudulent)

boost_tree_xgboost_spec <- 
  boost_tree() %>%
  set_engine('xgboost') %>%
  set_mode('classification')

xgboost <- workflow() %>% 
  add_model(boost_tree_xgboost_spec) %>% 
  add_formula(Is.Fraudulent ~ .)

fitted_xgboost <- fit(xgboost, data = train_df)

xgboost_predict_value <- predict(fitted_xgboost, train_df, type = "prob")
xgboost_predict_value %<>% mutate(`.pred_class` = as.factor(ifelse(.pred_1 > .pred_0, 1, 0)))

(ROCit_obj <- rocit(score = xgboost_predict_value$.pred_1, class = train_df$Is.Fraudulent))
plot(ROCit_obj)

auc_value <- ciAUC(ROCit_obj)$AUC
print(paste("AUC:", auc_value))
roc_data <- data.frame(
  FPR = ROCit_obj$FPR,
  TPR = ROCit_obj$TPR
)

ggroc <- ggplot(roc_data, aes(x = FPR, y = TPR)) +
  geom_line(color = "blue", size = 1) +
  geom_ribbon(aes(ymin = 0, ymax = TPR), fill = "blue", alpha = 0.2) +
  geom_abline(linetype = "dashed") +
  labs(title = "ROC Curve", x = "False Positive Rate", y = "True Positive Rate") +
  annotate("text", x = 0.75, y = 0.25, label = paste("AUC =", round(auc_value, 2)), size = 5, color = "red") +
  theme_minimal()

print(ggroc)

caret::confusionMatrix(data = xgboost_predict_value$.pred_class, reference = train_df$Is.Fraudulent, positive = "0", mode = "everything")


xgboost_predict_value <- predict(fitted_xgboost, test_df, type = "prob")
xgboost_predict_value <- xgboost_predict_value %>% mutate(`.pred_class` = as.factor(ifelse(.pred_1 > .pred_0, 1, 0)))
(ROCit_obj <- rocit(score = xgboost_predict_value$.pred_1, class = test_df$Is.Fraudulent))
plot(ROCit_obj)

auc_value <- ciAUC(ROCit_obj)$AUC
print(paste("AUC:", auc_value))
roc_data <- data.frame(
  FPR = ROCit_obj$FPR,
  TPR = ROCit_obj$TPR
)

ggroc <- ggplot(roc_data, aes(x = FPR, y = TPR)) +
  geom_line(color = "blue", size = 1) +
  geom_ribbon(aes(ymin = 0, ymax = TPR), fill = "blue", alpha = 0.2) +
  geom_abline(linetype = "dashed") +
  labs(title = "ROC Curve", x = "False Positive Rate", y = "True Positive Rate") +
  annotate("text", x = 0.75, y = 0.25, label = paste("AUC =", round(auc_value, 2)), size = 5, color = "red") +
  theme_minimal()

print(ggroc)

caret::confusionMatrix(data = xgboost_predict_value$.pred_class, reference = test_df$Is.Fraudulent, positive = "0", mode = "everything")