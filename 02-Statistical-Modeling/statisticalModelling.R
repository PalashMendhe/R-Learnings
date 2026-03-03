'''Setup and Generation of Sample Data for Statistical Modeling in R'''

library(tidyverse)
library(survival)
library(survminer)
library(forecast)
library(pROC)
library(caret)

set.seed(42)

n <- 500

#--- 1. Clinical (ANOVA, ANCOVA, GLMs, Survival) ---
clinical_data <- tibble(
  patient_id = 1:n,
  age = round(rnorm(n, mean = 60, sd = 10)),
  treatment_group = factor(sample(c("Placebo", "Drug_A", "Drug_B"), n, replace = TRUE), 
                           levels = c("Placebo", "Drug_A", "Drug_B")), # Factor for modeling
  baseline_bp = rnorm(n, mean = 140, sd = 15),
  post_bp = baseline_bp - ifelse(treatment_group == "Drug_A", 10, 
                                 ifelse(treatment_group == "Drug_B", 20, 0)) + rnorm(n, 0, 5),
  side_effects = rpois(n, lambda = ifelse(treatment_group == "Placebo", 1, 3)),
  complication = rbinom(n, 1, prob = ifelse(age > 65, 0.3, 0.1)),
  months_to_relapse = round(rexp(n, rate = ifelse(treatment_group == "Placebo", 0.05, 0.02))),
  relapse_event = sample(c(0, 1), n, replace = TRUE, prob = c(0.3, 0.7))
)

#--- 2. Time Series (ARIMA, Exponential Smoothing) ---
dates <- seq(as.Date("2020-01-01"), as.Date("2022-12-31"), by = "days")
time_series_data <- tibble(
  date = dates,
  admissions = round(50 + 20 * sin(seq(1,10, length.out = length(dates))) +
               seq(1, 20, length.out = length(dates)) + rnorm(length(dates), 0, 5))
)

#---3. Non-Linear Models (Logistic Regression, Poisson Regression) ---
hours <- seq(0.5, 24, by = 0.5)
non_linear_data <- tibble(
    hour = hours,
    concentration = 100 * exp(-0.15 * hour) + rnorm(length(hours), 0, 2)
)
___________________________________________________________________________________________________
'''The modeling Pipeline'''

#--- 1. ANOVA: Does treatment group affect post-treatment blood pressure? ---

# Fit the ANOVA model
anova_model <- aov(post_bp ~ treatment_group, data = clinical_data)

# Display the summary of the ANOVA model
summary(anova_model)

#If the p-value is less than 0.05, so we reject the null hypothesis and conclude that there are 
#significant differences in post-treatment blood pressure between the treatment groups.

# Perform Tukey's HSD test for pairwise comparisons
TukeyHSD(anova_model)

#--- 2. ANCOVA: Does post_bp differ by treatment_group, assuming we control for their baseline_bp?

# Fit the ANCOVA model
ancova_model <- aov(post_bp ~ treatment_group + baseline_bp, data = clinical_data)

# Display the summary of the ANCOVA model
# baseline_bp is a covariate that we are controlling for, so we can see if treatment_group 
# still has a significant effect on post_bp after accounting for baseline_bp.
summary(ancova_model)

#--- 3. GLM: Can we predict if a patient experiences a major complication (1 or 0) based on their age and baseline_bp?

# FIt the model (family = binomial for binary outcomes)
glm_model <- glm(complication ~ age + baseline_bp, data = clinical_data, family = binomial(link = "logit"))

# Display the summary of the GLM model
# Look at the 'Estimate' for age. It will be positive, meaning older age increases the log-odds of a complication.
summary(glm_model)

# --- 4. GLM:Poisson Regression: How does the treatment_group affect the count of mild side_effects?
poisson_model <- glm(side_effects ~ treatment_group, data = clinical_data, family = poisson(link = "log"))  
summary(poisson_model)

# ---5. Non-Linear Modeling: Can we map the exact exponential decay curve of the drug concentration in the bloodstream? 

# Fit the NLM model
nl_model <- nls(concentration ~ C0 * exp(-k * hour), data = non_linear_data, start = list(C0 = 100, k = 0.1))
summary(nl_model) # The summary should estimate C0 very close to 100, and k very close to 0.15 (our ground truth!) 

# ---6. Time Series Modelling: Based on daily admissions over the last 3 years, what will admissions look like for the next 30 days?

# Convert the raw numbers to time series object
admissions_ts <- ts(time_series_data$admissions, frequency = 365, start = c(2020, 1))
# Fit the ARIMA model
arima_model <- auto.arima(admissions_ts)
# Forecast the next 30 days
arima_forecast <-forecast(arima_model, h=30)
# Plot the forecast
plot(arima_forecast, main = "ARIMA Forecast of Admissions", xlab = "Date", ylab = "Number of Admissions")
summary(arima_model) # Look at the AIC value to see how well the model fits the data. Lower is better.

# ---7 Survival Analysis: Does treatment_group impact the time it takes for a patient to relapse?

# Create a survival object
surv_obj <- Surv(time = clinical_data$months_to_relapse, event = clinical_data$relapse_event)

# Fit the Kaplan-Meier survival curves by treatment group
km_fit <- survfit(surv_obj ~ treatment_group, data = clinical_data)

# Plot the survival curves
ggsurvplot(km_fit, data = clinical_data, pval = TRUE, conf.int = TRUE,
            title="Time to relapse by Treatment Group", xlab = "Months to Relapse", ylab = "Survival Probability")

#Fit a Cox Proportional-Hazards model to control for age
cox_model <- coxph(surv_obj ~ treatment_group + age + baseline_bp, data = clinical_data)
summary(cox_model) # Look at the hazard ratios for treatment_group to see if it significantly affects the time to relapse after controlling for age and baseline_bp.
____________________________________________________________________________________________________
'''Extracting the key Metrics '''
# 1. Continuous Metrics (using the ANCOVA Model)

adj_r_squared <- summary(ancova_model)$adj.r.squared
rmse_value <- sqrt(mean(ancova_model$residuals^2))
cat("Adjusted R-squared:", round(adj_r_squared, 2), "\n")
cat("RMSE:", round(rmse_value, 2), "blood pressure points\n\n")

# 2. Binary Classification Metrics (using the GLM Model)

predicted_probabilities <- predict(glm_model, type = "response")
roc_obj <- roc(clinical_data$complication, predicted_probabilities)

auc_value <- auc(roc_obj)
cat("Logistic Model AUC:", round(auc_value, 4), "\n")

'''The numbers we derived are overly optimistic because we are evaluating data on the same data we trined it on.
This leads to most common pitfall in Statistical Modeling: Overfitting.'''

'''The FIX - Cross-Validation (CV)'''

# Cross_validating ANCOVA model
train_control <- trainControl(method = "cv", number = 10) # 10-fold CV
cv_ancova <- train(post_bp ~ treatment_group + baseline_bp, 
                    data = clinical_data, 
                    method = "lm", 
                    trControl = train_control)
print(cv_ancova)

# Residuals vs. Fitted plot for the CV model
plot(cv_ancova$finalModel$fitted.values, cv_ancova$finalModel$residuals, 
     xlab = "Fitted Values", ylab = "Residuals", main = "Residuals vs Fitted (CV Model)")

# Q-Q plot for the CV model
my_residuals <- cv_ancova$finalModel$residuals
qqnorm(my_residuals, main = "Q-Q Plot of Residuals (CV Model)")
qqline(my_residuals, col = "red", lwd = 2)
