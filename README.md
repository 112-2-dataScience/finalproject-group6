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
  * File 1 (Train Data): 
    * Source：[a link] https://www.kaggle.com/datasets/shriyashjagtap/fraudulent-e-commerce-transactions?select=Fraudulent_E-Commerce_Transaction_Data.csv
    * Format：CSV
    * Size：400MB
  * File 2 (Test Data) :
    * Source : https://www.kaggle.com/datasets/shriyashjagtap/fraudulent-e-commerce-transactions?select=Fraudulent_E-Commerce_Transaction_Data_2.csv
    * Format : 

### code
* Analysis steps
* Which method or package do you use?
* How do you perform training and evaluation?
  * Cross-validation, or extra separated data
* What is a null model for comparison?

### results
* What is your performance?
* Is the improvement significant?

## References
* Packages you use
* Related publications
