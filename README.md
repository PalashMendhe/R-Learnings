# R-Learnings
I have created this repo to learn R-programming Language for GSOC-2026 as fast as possible.
This Repo will also help me to keep the track of my progress for mastering R for Data Science and Statistical Analysis.

## 📌 Milestone 1: The "Tidy" EDA (Stock Data)
This project demonstrates the power of the Tidyverse for data manipulation and visualization. Moving away from standard loops, I used "pipes" (|>) and layered grammar to analyze 5 years of tech stock history (2019-2024).

### 🚀 Key Features
**Data Cleaning:** Used janitor::clean_names() to standardize messy CSV headers.
**Time-Series Smoothing:** Implemented a 3-month moving average using zoo::rollmean to identify long-term trends.
**Linear Forecasting:** Applied geom_smooth(method = "lm") to visualize the overall growth trajectory of tech giants.
**Interactivity:** Integrated plotly to make static ggplot2 charts hoverable and dynamic.

#### 📊 1. Smoothened Trends
File: `Tidyverse_smoothed.R`
This analysis compares raw monthly closing prices against a bolded 3-month moving average. By using facet_wrap, I isolated each company's performance to see how they handled market volatility differently.
#### 📈 2.Linear Regression Visualization
File: `Tidyverse_Visualize_LinReg.R`
Instead of just looking at raw data points, this script fits a Linear Model (LM) over the timeline. It provides a visual baseline to see which stocks are currently trading above or below their historical growth trend.

## 🛠️ Tools

- Language: `R`
- IDE:  `VS Code`
- Primary Libraries: `Tidyverse`,`Janitor`,`zoo`,`scales`,`plotly`

