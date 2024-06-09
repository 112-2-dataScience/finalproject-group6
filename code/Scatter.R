data$Transaction_Amount <-
  cut(
    data$Transaction.Amount,
    breaks = c(0, 500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, Inf),
    labels = c(
      "0-0.5k",
      "0.5k-1k",
      "1k-1.5k",
      "1.5k-2k",
      "2k-2.5k",
      "2.5k-3k",
      "3k-3.5k",
      "3.5k-4k",
      "4k+"
    )
  )
data$Account_Age_Days_Period <- cut(data$Account.Age.Days, breaks = pretty(range(data$Account.Age.Days), n = 10))
columns <-c('Customer.Age', 'Account_Age_Days_Period', 'Quantity')

for (col in columns) {
  heatmap <-
    ggplot(data,
           aes(x = Transaction_Amount, y = Account_Age_Days_Period, fill = Is.Fraudulent)) +
    geom_tile(color = "grey", alpha = 0.5) +
    scale_fill_manual(values = c("blue", "orange"))  # 自定義填充顏色
  plot_title <-
    paste("Transaction Amount vs.", col)
  ggsave(
    filename = paste0("./image/", "heatmap_", gsub(" ", "_", col), ".png"),
    plot = heatmap,
    width = 8,
    height = 6
  )
}