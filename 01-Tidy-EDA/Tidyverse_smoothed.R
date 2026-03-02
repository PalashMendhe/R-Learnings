'''Loading the necesarry packages, and reading in the data from the csv file.'''
_________________________________________________________________________________________________________

library(tidyverse) # Includes dplyr, ggplot2, readr, and lubridate (for dates).
library(janitor) # for clean_names.
library(scales) # for formatting the y-axis as currency.
library(plotly) # for making the plot interactive.
library(zoo) # for rollmean, which calculates the moving average.

tech_stocks <- read_csv("01-Tidy-EDA/major-tech-stock-2019-2024.csv") |>
    clean_names() |> # clear the column names and make them more consistent.
    drop_na(close) # drop any rows that have missing values in the "close" column.
_________________________________________________________________________________________________________

'''Create a new data column that show the 3-month moving average of the closing price.'''

smoothed_trends <- tech_stocks |>
    group_by(ticker) |> #Group by company so our calculations happen independently for each stock.
    arrange(date) |> #Sort by date to guarantee the oldest month is row #1.

    mutate(moving_avg_3m= rollmean(close, k=3, NA, align = "right")) |> # create a 3-month moving average of the closing price.
    ungroup() # ungroup the data s that we can use it for plotting.
head(smoothed_trends) #view the first rows in your terminal to check the math.
_________________________________________________________________________________________________________

'''Create a line plot that shows both the raw monthly average closing price and the 3-month moving average 
for each company. The raw price will be faded out, and the smoothed trend will be bolded.'''

my_plot <- ggplot( data = smoothed_trends, mapping = aes(x=date, color=ticker))+
    geom_line(mapping = aes(y=moving_avg_3m), alpha = 1, linewidth = 1.2) + # add a horizontal line at y=100 to show the baseline.
    geom_line(mapping=aes(y = close), alpha =0.5,linewidth = 0.5)+
    facet_wrap(~ticker, scales = "free_y") + # create a separate plot for each company.
    theme_minimal()+
    scale_y_continuous(labels = dollar_format())+ # format the y-axis labels as dollar_currency.
    labs(
        title = "Tech Stocks: Raw Price vs 3-Month Moving Average",
        subtitle = "Faded line = Raw Monthly Average | Bold line = 3-Month Trend",
        x = "year",
        y = "Price (USD)",
    )
ggplotly(my_plot)
