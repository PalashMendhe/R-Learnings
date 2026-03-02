'''Loading the necesarry packages, and reading in the data from the csv file.'''
_________________________________________________________________________________________________________

library(tidyverse) # Includes dplyr, ggplot2, readr, and lubridate (for dates).
library(janitor) # for clean_names.
library(scales) # for formatting the y-axis as currency.
library(plotly) # for making the plot interactive.

tech_stocks <- read_csv("01-Tidy-EDA/major-tech-stock-2019-2024.csv") |>
    clean_names() |> # clear the column names and make them more consistent.
    drop_na(close) # drop any rows that have missing values in the "close" column.
_________________________________________________________________________________________________________

'''Create a new data column that show the 3-month moving average of the closing price.'''

indexed_trends <- tech_stocks |>
    group_by(ticker) |> #Group by company so our calculations happen independently for each stock.
    arrange(date) |> #Sort by date to guarantee the oldest month is row #1.

    mutate(indexed_close = close / first(close) * 100) |> # create a new column that shows the closing price indexed to the first value (2019-01-01).
    ungroup() # ungroup the data s that we can use it for plotting.
head(indexed_trends) #view the first rows in your terminal to check the math.
_________________________________________________________________________________________________________

'''Visualizing the raw closing price with a linear regression line to show the overall trend.'''

my_regression_plot <- ggplot(data=tech_stocks, mapping=aes(x= date, y=close, color = ticker))+
    geom_line(alpha = 0.7)+
    geom_smooth(method = "lm",se =FALSE, color = "black", linewidth = 0.5)+
    facet_wrap(~ticker, scales = "free_y") + # create a separate plot for each company.
    theme_minimal()+
    labs(
        title = "Tech Stocks: Raw Price with Linear Forecast",
        x = "year",
        y = "Price (USD)",
    )+
    theme(legend.position = "none") #hide the legend since the titles tells us which is which.
ggplotly(my_regression_plot)
