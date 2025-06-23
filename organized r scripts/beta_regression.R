# ---------------------------------------------------------
# Analysis: Effect of CHANGE in Student's Self-Perception 
#           on CHANGE in TOSLS Score
# ---------------------------------------------------------

# Ensure Section is a factor
df.std$Section <- as.factor(df.std$Section)

## -----------------------------------------------
## 1. Beta Regression Model: perc_test ~ delta_self + Section
## -----------------------------------------------

# Fit Beta regression model
m_beta <- betareg(perc_test ~ delta_self + Section, data = df.std)
summary(m_beta)

# Inverse logit function to back-transform to response scale
inv_logit <- function(x) exp(x) / (1 + exp(x))

# Identify rows with complete predictor data
complete_rows <- complete.cases(df.std[, c("delta_self", "Section")])

# Predict fitted values on link scale for complete rows only
pred_link <- predict(m_beta, newdata = df.std[complete_rows, ], type = "link")

# Initialize predicted_beta column with NA
df.std$predicted_beta <- NA

# Assign back-transformed predictions to corresponding rows
df.std$predicted_beta[complete_rows] <- inv_logit(pred_link)

# Visualization: points + predicted lines by Section
ggplot(df.std, aes(x = delta_self, y = perc_test, color = Section)) +
  geom_point(alpha = 0.7) +
  geom_line(aes(y = predicted_beta), linewidth = 1) +
  labs(
    title = "Beta Regression: Percentage TOSLS vs Change in SELF (by Section)",
    x = "Change in SELF Score (delta_self)",
    y = "Percentage TOSLS Score (perc_test)"
  ) +
  scale_color_manual(values = c("2" = "blue", "3" = "red")) +
  theme_minimal()


## -----------------------------------------------
## 2. Mixed-Effects Beta Regression: perc_test ~ `post SELF average` + (1 | Section)
## -----------------------------------------------

m_mixed_beta <- glmmTMB(perc_test ~ `post SELF average` + (1 | Section),
                        family = beta_family(),
                        data = df.std)
summary(m_mixed_beta)

# Handle missing data for prediction
complete_rows_mixed <- complete.cases(df.std[, c("post SELF average", "Section")])

pred_mixed <- predict(m_mixed_beta, newdata = df.std[complete_rows_mixed, ], type = "response")

df.std$predicted_mixed_beta <- NA
df.std$predicted_mixed_beta[complete_rows_mixed] <- pred_mixed

# Visualization
ggplot(df.std, aes(x = `post SELF average`, y = perc_test, color = Section)) +
  geom_point(alpha = 0.7) +
  geom_line(aes(y = predicted_mixed_beta), linewidth = 1) +
  labs(
    title = "Mixed Beta Regression: Percentage TOSLS vs Post SELF Average (by Section)",
    x = "Post SELF Average",
    y = "Percentage TOSLS Score (perc_test)"
  ) +
  scale_color_manual(values = c("2" = "blue", "3" = "red")) +
  theme_minimal()