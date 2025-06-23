## ----------------------------------------------------------
## What is the predictive relationship of self-perception 
## and actual scientific literacy (TOSLS)?
## ----------------------------------------------------------

## -----------------------------------------------
## 1. Setup: Create delta-based and post-based data frames
## -----------------------------------------------

# Filter for complete cases for delta-based models
df_delta <- na.omit(df.std[, c("delta_test_percent", "delta_self", "Section")])
df_delta$Section <- as.factor(df_delta$Section)

# Filter for complete cases for post-score model
df_post <- na.omit(df.std[, c("perc_test", "post SELF average", "Section")])
df_post$Section <- as.factor(df_post$Section)


## -----------------------------------------------
## 2. OLS Model: Change in TOSLS vs. Change in SELF
## -----------------------------------------------

# Linear model (no random effects)
model_delta_ols <- lm(delta_test_percent ~ delta_self + Section, data = df_delta)
summary(model_delta_ols)

# Add predictions for plotting
df_delta$predicted_ols <- predict(model_delta_ols)

# Visualization
ggplot(df_delta, aes(x = delta_self, y = delta_test_percent, color = Section)) +
  geom_point(alpha = 0.7) +
  geom_line(aes(y = predicted_ols), linewidth = 1) +
  labs(title = "OLS Model: ΔTOSLS vs ΔSELF",
       x = "Change in SELF Score",
       y = "Change in TOSLS Score (percent)") +
  scale_color_manual(values = c("2" = "blue", "3" = "red")) +
  theme_minimal()


## -----------------------------------------------
## 3. Mixed-Effects Model: ΔTOSLS ~ ΔSELF (random intercept by Section)
## -----------------------------------------------

model_delta_mixed <- lmer(delta_test_percent ~ delta_self + (1 | Section), data = df_delta)
summary(model_delta_mixed)

# Add predicted values for plotting
df_delta$predicted_mixed <- predict(model_delta_mixed)

# Visualization
ggplot(df_delta, aes(x = delta_self, y = delta_test_percent, color = Section)) +
  geom_point(alpha = 0.7) +
  geom_line(aes(y = predicted_mixed), linewidth = 1) +
  labs(title = "Mixed Model: ΔTOSLS vs ΔSELF (Random Intercepts)",
       x = "Change in SELF Score",
       y = "Change in TOSLS Score (percent)") +
  scale_color_manual(values = c("2" = "blue", "3" = "red")) +
  theme_minimal()


## -----------------------------------------------
## 4. Mixed-Effects Model: Post-TOSLS ~ Post-SELF Average
## -----------------------------------------------

m_mixed_ols <- lmer(perc_test ~ `post SELF average` + (1 | Section), data = df_post)
summary(model_post_mixed)

# Add predicted values
df_post$predicted_post <- predict(model_post_mixed)

# Visualization
ggplot(df_post, aes(x = `post SELF average`, y = perc_test, color = Section)) +
  geom_point(alpha = 0.7) +
  geom_line(aes(y = predicted_post), linewidth = 1) +
  labs(title = "Mixed Linear Model: Post TOSLS Percent vs Post SELF Average",
       x = "Post SELF Average",
       y = "Post TOSLS Percent") +
  scale_color_manual(values = c("2" = "blue", "3" = "red")) +
  theme_minimal()


