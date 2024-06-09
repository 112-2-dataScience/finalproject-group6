## EDA
# install.packages("ggplot2")
# install.packages("ggpubr")
# install.packages("patchwork")
# install.packages("scales")
# install.packages("RColorBrewer")
# install.packages("dplyr")
library(RColorBrewer)
library(ggplot2)
library(ggpubr)
library(patchwork)
library(scales)
library(dplyr)

train_df <- read.csv('archive/Fraudulent_E-Commerce_Transaction_Data.csv')
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
data <- clean_data(train_df)

# 創建圓餅圖Function
create_pie_chart <- function(data, column_name) {
  # 計算每個類別數量
  category_count <- data %>%
    count(!!sym(column_name)) %>%
    arrange(desc(n))
  
  pie_chart <- ggplot(category_count, aes(x = "", y = n, fill = factor(!!sym(column_name)))) +
    geom_bar(stat = "identity", width = 1) +
    coord_polar("y", start = 0) +
    theme_void() +
    theme(plot.title = element_text(hjust = 0.5),  # 置中
          legend.position = "right") +
    geom_text(aes(label = paste0(sprintf("%.1f%%", n/sum(n) * 100), "\n", !!sym(column_name))), 
              position = position_stack(vjust = 0.5)) +
    scale_fill_brewer(palette = "Pastel1") +
    labs(title = column_name, fill = column_name) +
    guides(fill = FALSE)
  
  return(pie_chart)
}

# 創建長條圖Function
create_bar_chart <- function(data, column_name) {
  bar_chart <- ggplot(data, aes(x = factor(!!sym(column_name)), fill = factor(!!sym(column_name)))) +
    geom_bar() +
    geom_text(stat = "count", aes(label = stat(count)), vjust = -0.5) +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5),  # 置中
          panel.border = element_rect(color = "black", fill = NA, linewidth = 0.5),
          axis.title.x = element_blank()
          # 如果需要旋转 x 轴文本，可以取消下一行的注释
          # axis.text.x = element_text(angle = 45, hjust = 1)
    ) + 
    scale_fill_brewer(palette = "Pastel1") + #顏色統一
    scale_y_continuous(n.breaks = 8, labels = scales::comma) +
    ggtitle(column_name) +
    guides(fill = FALSE)
  
  return(bar_chart)
}

# 建立Hist圖表Function
create_hist_chart <- function(data, column_name, peak = 1) {
  # Create the plot
  plot <- ggplot(data, aes(x = !!sym(column_name), y = ..count..)) +
    geom_histogram(stat="bin", bins = 20, fill = "orange", color = "black", alpha = 0.5, aes(y=..count..)) +
    geom_density(aes(y = ..density.. * mean(..count..) **peak), color = "orange", alpha = 1, linewidth = 1) +
    scale_fill_brewer(palette = "Pastel1") +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5),  # 置中
          panel.border = element_rect(color = "black", fill = NA, linewidth = 0.5)) +  # 添加邊匡線
    ggtitle(column_name)+
    scale_x_continuous(n.breaks = 8) 
  
  # Return the plot
  return(plot)
}

# 保存圖像Function
save_plots <- function(charts, width = 8, height = 6, path = getwd()) {
  plot_names <- names(plots)
  for (plot_name in plot_names) {
    ggsave(filename = file.path(path, paste0(plot_name, ".png")), 
           plot = plots[[plot_name]], 
           width = width, 
           height = height)
  }
}

eda_plot <- function(data) {
  ## Transaction.Amount
  filtered_data <- data[data$Transaction.Amount < 1500, ]
  transaction_chart <- ggplot(filtered_data, aes(x = Transaction.Amount)) +
    geom_histogram(bins = 50, fill = "orange", color = "black", alpha = 0.5) +
    theme_minimal()+
    scale_fill_brewer(palette = "Pastel1") +  #顏色樣式統一
    theme(plot.title = element_text(hjust = 0.5),  # 置中
          panel.border = element_rect(color = "black", fill = NA, linewidth = 0.5)) +  # 添加邊匡線
    ggtitle("Transaction Amount") +
    scale_x_continuous(breaks = c(seq(0, 400, by = 100), seq(500, max(filtered_data$Transaction.Amount), by = 200))) +  # Combine custom and default breaks
    scale_y_continuous(n.breaks = 8, labels = comma)
  
  ## Payment.Method
  payment_pie_chart <- create_pie_chart(data, "Payment.Method")
  payment_bar_chart <- create_bar_chart(data, "Payment.Method")
  
  ## Product.Category
  category_pie_chart <- create_pie_chart(data, "Product.Category")
  category_bar_chart <- create_bar_chart(data, "Product.Category")
  
  ## Quantity
  quantity_pie_chart <- create_pie_chart(data, "Quantity")
  quantity_bar_chart <- create_bar_chart(data, "Quantity")
  
  ## Device Used
  device_pie_chart <- create_pie_chart(data, "Device.Used")
  device_bar_chart <- create_bar_chart(data, "Device.Used")
  
  ## Account.Age.Days
  account_hist_chart <- create_hist_chart(data, "Account.Age.Days", peak = 2)
  
  ## Customer.Age
  customer_hist_chart <- create_hist_chart(data, "Customer.Age", peak = 1.5)
  
  ## Transaction.Hour
  hour_count <- data %>%
    count(Transaction.Hour) %>%
    arrange(desc(n)) %>%
    head(15)
  
  colors <- colorRampPalette(brewer.pal(8, "Pastel1"))(15)
  
  transaction_hour_chart <- ggplot(hour_count, aes(x = factor(Transaction.Hour, levels = Transaction.Hour), y = n, fill = factor(Transaction.Hour))) +
    geom_bar(stat = "identity") +
    geom_text(aes(label = n), vjust = -0.5) +
    scale_fill_manual(values = colors) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 80, hjust = 1),
          plot.title = element_text(hjust = 0.5),  # 置中
          panel.border = element_rect(color = "black", fill = NA, linewidth = 0.5)) +  # 添加邊匡線
    labs(x = "Transaction Hour", y = "Count", title = "Top 15 Transaction Hours") +
    guides(fill=FALSE)  # 移除圖例
  
  ## Is.Fraudulent
  fraudulent_violin_chart <- ggplot(data, aes(x = factor(Is.Fraudulent), y = Transaction.Amount)) +
    geom_violin(aes(fill = factor(Is.Fraudulent))) +  # 使用 fill 參數設置填充顏色
    theme_minimal() +
    scale_fill_manual(values=colors) +
    theme(plot.title = element_text(hjust = 0.5),  # 置中
          panel.border = element_rect(color = "black", fill = NA, linewidth = 0.5)) +  # 添加邊匡線
    labs(x = "Is Fraudulent", y = "Transaction Amount", title = "Transaction Amount by Fraudulent Status") +
    guides(fill=FALSE)  # 移除圖例
  
  # 收集所有圖像並返回
  charts <- mget(ls(pattern = "_chart$"))
  return(charts)
}

plots <- eda_plot(data)
# print(plots$customer_hist_chart)
# print(plots$transaction_chart)

# 保存圖像到本地端
save_plots(plots, path = "./image")
save_plots(plots$transaction_hour_chart, width = 10, height = 6, path = "./image")

# ggsave("transaction_chart.png", plot = plots$transaction_chart, width = 8, height = 6)

#-----------------------------------
## is_fraudulent_plots
is_fraudulent_plots <- function(data, path = "./image/") {
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE)
  }
  
  data$`Is.Fraudulent` <- as.factor(data$`Is.Fraudulent`)
  
  columns <- c('Payment.Method', 'Product.Category', 
               'Quantity', 'Device.Used', 'Transaction.DOW', 
               'Transaction.Month', 'Is.Address.Match')
  
  for (col in columns) {
    p <- ggplot(data, aes_string(x = col, fill = "Is.Fraudulent")) +
      geom_bar(position = "dodge") +
      theme(axis.text.x = element_text(angle = 90, hjust = 1),
            plot.title = element_text(hjust = 0.5),  
            panel.border = element_rect(color = "black", fill = NA, linewidth = 0.5),
            legend.position = c(0.92, 0.9)) +
      scale_y_continuous(labels = comma) + 
      labs(title = col, fill = "Is.Fraudulent")
    # print(p)
    
    ggsave(filename = paste0(path, "plot_", gsub(" ", "_", col), ".png"), plot = p, width = 10, height = 8)
  }
  
  p1 <- ggplot(data, aes(x = `Is.Fraudulent`, y = `Transaction.Amount`)) +
    geom_boxplot() +
    theme_minimal() +
    labs(title = "Transaction Amount by Is Fraudulent", x = "Is Fraudulent", y = "Transaction Amount")
  
  p2 <- ggplot(data, aes(x = `Is.Fraudulent`, y = `Transaction.Day`)) +
    geom_boxplot() +
    scale_y_continuous(breaks = seq(0, 31, by = 1)) +
    theme_minimal() +
    labs(title = "Transaction Day by Is Fraudulent", x = "Is Fraudulent", y = "Transaction Day")
  
  combined_plot <- grid.arrange(p1, p2, ncol = 2)
  ggsave(filename = paste0(path, "boxenplots.png"), plot = combined_plot, width = 16, height = 8)
}

is_fraudulent_plots(data)
