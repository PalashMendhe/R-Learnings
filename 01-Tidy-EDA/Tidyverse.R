'''Loading the necesarry packages, and reading in the data from the csv file.'''
__________________________________________________________________________________________________________

library(tidyverse) # Includes dplyr, ggplot2, readr, and lubridate (for dates).
library(janitor) # for clean_names.
library(scales) # for formatting the y-axis as currency.
library(plotly) # for making the plot interactive.

tech_stocks <- read_csv("01-Tidy-EDA/major-tech-stock-2019-2024.csv") |>
    clean_names() |> # clear the column names and make them more consistent.
    drop_na(close) # drop any rows that have missing values in the "close" column.
____________________________________________________________________________________________________________________

''''''
indexed_trends <- tech_stocks |>
    group_by(ticker) |> #Group by company so our calculations happen independently for each stock.
    arrange(date) |> #Sort by date to guarantee the oldest month is row #1.

    mutate(indexed_close = close / first(close) * 100) |> # create a new column that shows the closing price indexed to the first value (2019-01-01).
    ungroup() # ungroup the data s that we can use it for plotting.
head(indexed_trends) #view the first rows in your terminal to check the math.
______________________________________________________________________________________________________________________________
'''Visualizing the raw closing price with a linear regression line to show the overall trend.'''

my_plot <- ggplot( data = indexed_trends, mapping = aes(x=date, y=indexed_close, color=ticker))+
    geom_hline(yintercept = 100, linetype = "dashed", color = "gray") + # add a horizontal line at y=100 to show the baseline.
    geom_line(linewidth = 1)+
    theme_minimal()+
    scale_y_continuous(labels = dollar_format())+ # format the y-axis labels as dollar_currency.
    labs(
        title = "Major Companies Stock Performance Over Time (2019-2024)",
        subtitle = "Average closing price per month",
        x = "Month",
        y = "Average Closing Price (USD)",
        color = "Company"
    ) +
    facet_wrap(~ticker, scales = "free_y") + # create a separate plot for each company.
    theme(legend.position = "none") #hide the legend since the titles tells us which is which.
ggplotly(my_plot)
