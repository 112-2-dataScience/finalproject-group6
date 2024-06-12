library(kernlab)
library(caret)
library(ROCit)
library(tidyverse)
library(magrittr)
library(tidymodels)

train_df$Is.Fraudulent <- as.factor(train_df$Is.Fraudulent)

svm_rbf_kernlab_spec <- 
  svm_rbf() %>%  
  set_engine('kernlab') %>%
  set_mode('classification')

kernlab_workflow <- 
  workflow() %>% 
  add_formula(formula = Is.Fraudulent ~ .) %>% 
  add_model(svm_rbf_kernlab_spec)

fitted_kernlab <- fit(kernlab_workflow, data = train_df)

svm_predict_value <- predict(fitted_kernlab, train_df, type = "prob")
svm_predict_value %<>% mutate(`.pred_class` = as.factor(ifelse(.pred_1 > .pred_0, 1, 0)))


(ROCit_obj <- rocit(score = svm_predict_value$.pred_1, class = train_df$Is.Fraudulent))
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

caret::confusionMatrix(data = svm_predict_value$.pred_class, reference = train_df$Is.Fraudulent, positive = "0", mode = "everything")

test_df <- clean_data(test_df)
test_df$Is.Fraudulent <- as.factor(test_df$Is.Fraudulent)

svm_predict_value <- predict(fitted_kernlab, test_df, type = "prob")
svm_predict_value %<>% mutate(`.pred_class` = as.factor(ifelse(.pred_1 > .pred_0, 1, 0)))

(ROCit_obj <- rocit(score = svm_predict_value$.pred_1, class = test_df$Is.Fraudulent))
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

caret::confusionMatrix(data = svm_predict_value$.pred_class, reference = test_df$Is.Fraudulent, positive = "0", mode = "everything")
