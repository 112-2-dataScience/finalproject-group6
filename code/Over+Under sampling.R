install.packages("plotly")
install.packages("dplyr")
library(plotly)
library(dplyr)
library(ROSE)


# 讀取CSV檔
train_df <- read.csv('archive/Fraudulent_E-Commerce_Transaction_Data.csv')
test_df <- read.csv('archive/Fraudulent_E-Commerce_Transaction_Data_2.csv')

# 顯示dataframe前幾行
head(train_df)
# dataframe列數、行數
dim(train_df)
# features的datatype
str(train_df)
# features的非空值個數
colSums(!is.na(train_df))

# features的統計摘要
t(summary(train_df))

# 檢查是否有缺失值
colSums(is.na(train_df))
# 檢查每一行是否重複
sum(duplicated(train_df))
# 顯示dataframe的前兩筆資料
t(head(train_df, 2))
# customer age的box plot
p <- plot_ly(train_df, x = ~Customer.Age, type = "box", width = 500, height = 300)
p


## Data Cleaning
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
head(train_df)
str(train_df)


n1 <- sum(train_df$Is.Fraudulent == 0)
n2 <- sum(train_df$Is.Fraudulent == 1)
n3 <- (n1 + n2)/2

train_df  <-ovun.sample(Is.Fraudulent ~ ., data = train_df, method = "over", N = n3*2, seed = 5)$data

n4 <- sum(train_df$Is.Fraudulent == 1)
train_df  <-ovun.sample(Is.Fraudulent ~ ., data = train_df, method = "under", N = n4*2, seed = 5)$data
table(train_df$Is.Fraudulent)