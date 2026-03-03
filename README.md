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

## 📊 Milestone 2: Statistical Interpretation & Metrics
This milestone focuses on Hypothesis Testing, Generalized Linear Models (GLMs), and Model Diagnostics. We used a simulated clinical trial dataset ($n=500$) to demonstrate rigorous statistical validation.


### 1. Comparative Analysis (ANOVA vs. ANCOVA): 
We tested if different treatment groups significantly affected post-treatment blood pressure.

**ANOVA:** Confirmed significant differences between groups ($F=63.43, p < 2e-16$).

**ANCOVA:** By adding baseline_bp as a covariate, the model became significantly more precise.

**Impact:** The Residual Mean Square error dropped from 259 to 26, proving that controlling for initial health states is vital for experimental accuracy.

### 2. Predictive Modeling (GLMs)Logistic Regression: 
Modeled the likelihood of medical complications.

**Finding:** Age is a significant risk factor ($p < 0.001$). For every additional year of age, a patient's odds of complication increase by ~5.1%.

**Poisson Regression:** Modeled the count of side effects.Finding: Both experimental drugs significantly impacted side effect counts compared to the placebo ($p < 2e-16$).

### 3. Survival Analysis & Forecasting Cox Proportional-Hazards: 

Analyzed the time to disease relapse.Finding: Drug A reduces the risk of relapse by 60.5% ($HR = 0.39$) compared to the placebo.

**Time Series (ARIMA):** Built an ARIMA(5, 1, 2) model to forecast hospital admissions.

**Performance:** The model achieved an RMSE of 5.21, meaning forecasts are typically within ~5 patients of the actual daily load.

### 4. Model Validation (Diagnostics)

To ensure these findings weren't just noise, we performed 10-fold Cross-Validation and checked residual assumptions:

**Linearity:** Residuals showed a "night sky" distribution, confirming equal variance (Homoscedasticity).

**Normality:** The Normal Q-Q Plot confirmed that residuals follow a normal distribution, with only minor deviations at the extreme tails

## 🛠️ Tools

- Language: `R`
- IDE:  `VS Code`
- Libraries Used: `Tidyverse`,`Janitor`,`zoo`,`scales`,`plotly`,`survival`,`survminer`,`forecast`,`pROC`,`caret`

