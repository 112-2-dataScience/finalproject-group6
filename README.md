# [Group6] 電子商務交易詐欺預測
With the rapid advancement of electronic payments, the incidence of e-commerce fraud has escalated, leading to substantial financial losses for businesses and creating a negative experience for customers. Fraudsters employ various tactics, such as using stolen credit cards, taking over accounts, and engaging in friendly fraud. These activities result in financial chargebacks, disrupt operations, and damage the reputation of businesses. This growing issue poses a significant threat not only to individuals but also to financial institutions and the overall market stability.

Given the increasing prevalence and complexity of e-commerce fraud, our objective is to develop an advanced detection system. This project aims to build a fraudulent transaction detection system utilizing machine learning techniques. By analyzing customer data, transaction details, and historical patterns, we strive to identify suspicious activities with high accuracy, thereby mitigating the impact of fraud.

## Contributors
|組員|系級|學號|工作分配|
|-|-|-|-|
|蘇芷儀|經濟三|110208040|團隊中的吉祥物🦒，負責增進團隊氣氛| 
|賴威博|資科碩一|112753101|EDA相關圖表、Feature相關性分析、開會號招人|
|藍璟誠|資管四|109306059|團隊的中流砥柱，一個人打十個|
|劉育佑|資科碩二|111753145|Data Over/Undersampling、建立模型(Decision Tree、Random Forest、Logistic Regression)、特徵篩選(Features Selection)|
|趙駖翰|地政土管四|109207343|Data Over/Undersampling、建立模型(KNN、SVM、XGBoost)、特徵篩選(Features Selection)、交叉驗證&超參數調整(Grid Search)|

## Quick start
Please provide an example command or a few commands to reproduce your analysis, such as the following R script:
```R
Rscript code/your_script.R --input data/training --output results/performance.tsv
```

## Folder organization and its related description
idea by Noble WS (2009) [A Quick Guide to Organizing Computational Biology Projects.](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1000424) PLoS Comput Biol 5(7): e1000424.

### docs
* Your presentation, 1122_DS-FP_groupID.ppt/pptx/pdf (i.e.,1122_DS-FP_group1.ppt), by **06.13**
* Any related document for the project, i.e.,
  * discussion log
  * software user guide

### data
* Input
  * File 1 (檔案太大沒辦法上傳到 github)(Train Data): 
    * Source：[Kaggle](https://www.kaggle.com/datasets/shriyashjagtap/fraudulent-e-commerce-transactions?select=Fraudulent_E-Commerce_Transaction_Data.csv)
    * Format：CSV
    * Size：393 MB
  * [File 2](data/Fraudulent_E-Commerce_Transaction_Data.csv) (Test Data) :
    * Source : [Kaggle](https://www.kaggle.com/datasets/shriyashjagtap/fraudulent-e-commerce-transactions?select=Fraudulent_E-Commerce_Transaction_Data_2.csv)
    * Format : CSV
    * Size : 6.3 MB

### code
* Analysis steps
    * EDA 
* Which method or package do you use?
* How do you perform training and evaluation?
  * Cross-validation, or extra separated data
* What is a null model for comparison?
  * 因為是分類問題

### results
* What is your performance?
* Is the improvement significant?

## References
* This project uses the following R packages:
  - **[dplyr](https://cran.r-project.org/web/packages/dplyr/index.html)**: A grammar of data manipulation, providing a consistent set of verbs to help you solve the most common data manipulation challenges.
  - **[ggplot2](https://cran.r-project.org/web/packages/ggplot2/index.html)**: A system for 'declaratively' creating graphics, based on "The Grammar of Graphics".
  - **[caret](https://cran.r-project.org/web/packages/caret/index.html)**: Classification and regression training, a set of functions that attempt to streamline the process for creating predictive models.
  - **[xgboost](https://cran.r-project.org/web/packages/xgboost/index.html)**: Extreme Gradient Boosting, which is an efficient and scalable implementation of gradient boosting framework.
  - **[optparse](https://cran.r-project.org/web/packages/optparse/index.html)**: A command line option parser to be used with Rscript to write "#!" shebang scripts that accept short and long flag/options.
  - **[tidyr](https://cran.r-project.org/web/packages/tidyr/index.html)**: Tidy Messy Data, providing tools to help you clean your data.
  - **[readr](https://cran.r-project.org/web/packages/readr/index.html)**: Read Rectangular Text Data, making it easy to read many types of rectangular data including csv, tsv, and fwf.
  - **[purrr](https://cran.r-project.org/web/packages/purrr/index.html)**: Functional Programming Tools, enhancing R's functional programming toolkit by providing a complete and consistent set of tools for working with functions and vectors.
  - **[parallel](https://cran.r-project.org/web/views/HighPerformanceComputing.html)**: Support for parallel computation in R.
  - **[ggpubr](https://cran.r-project.org/web/packages/ggpubr/index.html)**: 'ggplot2' Based Publication Ready Plots.
  - **[pROC](https://cran.r-project.org/web/packages/pROC/index.html)**: Display and Analyze ROC Curves.
  - **[ROSE](https://cran.r-project.org/web/packages/ROSE/index.html)**: Provides functions to deal with binary classification problems in the presence of imbalanced classes.

* Related publications
