train_folds <- vfold_cv(train_df, v = 10)

boost_tree_xgboost_spec <-
  boost_tree(tree_depth = tune(), trees = tune()) %>%
  set_engine('xgboost') %>%
  set_mode('classification')

xgboost_wflow <- workflow() %>%
  add_model(boost_tree_xgboost_spec) %>%
  add_formula(Is.Fraudulent ~ .)

xgboost_tune <- xgboost_wflow %>%
  tune_grid(train_folds, grid = crossing(tree_depth = c(5, 10, 20), trees = c(10, 25, 50, 100, 200)),
            metrics = metric_set(accuracy, f_meas, bal_accuracy))

best_params <- select_best(xgboost_tune, metric = "bal_accuracy")

best_params

xgboost_wflow <- xgboost_wflow %>% finalize_workflow(select_best(xgboost_tune, metric = "bal_accuracy"))

fitted_xgboost <- fit(xgboost_wflow, data = train_df)

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


test_df <- clean_data(test_df)
test_df$Is.Fraudulent <- as.factor(test_df$Is.Fraudulent)

xgboost_predict_value <- predict(fitted_xgboost, test_df, type = "prob")
xgboost_predict_value %<>% mutate(`.pred_class` = as.factor(ifelse(.pred_1 > .pred_0, 1, 0)))

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
