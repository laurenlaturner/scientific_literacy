## Pre/Post general analysis (Wilcoxon test, Spearman correlation, and paired t-test)
wilcox_result <- wilcox.test(df$`post SELF average`, df$`pre SELF average`, 
                             paired = TRUE, alternative = "greater")
spearman_r <- cor(df$`pre SELF average`, df$`post SELF average`, method = "spearman",
                  use = "complete.obs")
kendall_r <- cor(df$`pre SELF average`, df$`post SELF average`, method = "kendall", 
                 use = "complete.obs")
t_result <- t.test(df$`pre TOSLS score`, df$`post TOSLS score`, paired = TRUE)


## --- Visualization for Wilcoxon test ---
# Create long-format
df_self_long <- data.frame(
  ID = rep(1:nrow(df), each = 2),
  Time = rep(c("Pre", "Post"), times = nrow(df)),
  Score = c(df$`pre SELF average`, df$`post SELF average`)
)

df_self_long$Time <- factor(df_self_long$Time, levels = c("Pre", "Post"))

# Calculate medians
median_pre_self <- median(df$`pre SELF average`, na.rm = TRUE)
median_post_self <- median(df$`post SELF average`, na.rm = TRUE)

# Prepare median line data
trend_data <- data.frame(Time = c("Pre", "Post"),
                         Score = c(median_pre_self, median_post_self),
                         Group = "Median Trend")

# Plot
ggplot(df_self_long, aes(x = Time, y = Score, group = ID)) +
  geom_line(alpha = 0.4, color = "gray") +
  geom_point(aes(color = Time), size = 2) +
  geom_line(data = trend_data,
            aes(x = Time, y = Score, linetype = Group, group = Group),
            color = "black", size = 1.2) +
  scale_linetype_manual(name = "", values = c("Median Trend" = "solid")) +
  scale_color_manual(values = c("Pre" = "darkred", "Post" = "darkgreen"),
                     guide = "none") +
  labs(title = "SELF Assessment Scores: Wilcoxon Signed-Rank Test",
       subtitle = paste0("p-value = ", signif(wilcox_result$p.value, 3)),
       x = "", y = "SELF Score") +
  theme_minimal() +
  theme(legend.title = element_blank(), 
        legend.position = "bottom")


## --- Visualization for Correlations ---
# Plot
ggplot(df, aes(x = `pre SELF average`, y = `post SELF average`)) +
  geom_point(color = "steelblue", size = 2) +
  geom_smooth(method = "lm", se = FALSE, linetype = "dashed", color = "black") +
  labs(title = "SELF Assessment Correlation",
       subtitle = paste0("Spearman = ", round(spearman_r, 2), 
                         " | Kendall = ", round(kendall_r, 2)),
       x = "Pre SELF Score", y = "Post SELF Score") +
  theme_minimal()


## --- Visualization for T-test ---
# Create long-format manually
df_tosls_long <- data.frame(
  ID = rep(1:nrow(df), each = 2),
  Time = rep(c("Pre", "Post"), times = nrow(df)),
  Score = c(df$`pre TOSLS score`, df$`post TOSLS score`)
)

df_tosls_long$Time <- factor(df_tosls_long$Time, levels = c("Pre", "Post"))

# Calculate means
mean_pre_tosls <- mean(df$`pre TOSLS score`, na.rm = TRUE)
mean_post_tosls <- mean(df$`post TOSLS score`, na.rm = TRUE)

# Prepare mean line data
trend_data <- data.frame(Time = c("Pre", "Post"),
                         Score = c(mean_pre_tosls, mean_post_tosls),
                         Group = "Mean Trend")

# Plot
ggplot(df_tosls_long, aes(x = Time, y = Score, group = ID)) +
  geom_line(alpha = 0.4, color = "gray") +
  geom_point(aes(color = Time), size = 2) +
  geom_line(data = trend_data,
            aes(x = Time, y = Score, linetype = Group, group = Group),
            color = "black", size = 1.2) +
  scale_linetype_manual(name = "Mean Line", values = c("Mean Trend" = "solid")) + 
  scale_color_manual(name = "Mean Line", values = c("Mean Trend" = "black")) + 
  scale_color_manual(values = c("Pre" = "darkblue", "Post" = "darkorange"), guide = "none") + 
  labs(title = "TOSLS Scores: Paired t-Test",
       subtitle = paste0("p-value = ", signif(t_result$p.value, 3)),
       x = "", y = "TOSLS Score") +
  theme_minimal() +
  theme(legend.title = element_blank(), 
        legend.position = "bottom")


## --- Visualization for SELF Q's vs. TOSLS score ---
# Initialize empty list to store correlations
cor_results <- data.frame(Question = character(), 
                          Spearman = numeric(),
                          p_value = numeric(),
                          stringsAsFactors = FALSE)

# Loop over each post question
for (q in post_questions) {
  corr <- cor.test(df[[q]], df$`post TOSLS score`, method = "spearman")
  cor_results <- rbind(cor_results, 
                       data.frame(Question = q, 
                                  Spearman = corr$estimate, 
                                  p_value = corr$p.value))
}

# Clean question labels for plot
cor_results$Question <- sub(".*Q", "Q", cor_results$Question)

# Plot correlations
ggplot(cor_results, aes(x = reorder(Question, Spearman), y = Spearman)) +
  geom_col(fill = "skyblue") +
  geom_text(aes(label = round(Spearman, 2)), vjust = -0.5) +
  labs(title = "Spearman Correlation: Post-SELF Questions vs Post-TOSLS Score",
       x = "Post SELF Question",
       y = "Spearman Correlation") +
  theme_minimal() +
  coord_flip()


## --- Each SELF Q compared to TOSLS percent---

# Prepare long-format data
df_extra <- df.std[, c("perc_test", "Section")]
self_questions <- names(df)[grepl("^post SELF -  Q", names(df))]
df_likert <- df[, self_questions]
df_combined <- cbind(df_extra, df_likert)

df_long <- reshape(
  data = df_combined,
  varying = self_questions,
  v.names = "Score",
  timevar = "Question",
  times = self_questions,
  direction = "long"
)

df_long <- na.omit(df_long)
df_long$Section <- as.factor(df_long$Section)
df_long$Question <- as.factor(df_long$Question)

# Visualization
ggplot(df_long, aes(x = Score, y = perc_test, color = Section)) +
  geom_point(alpha = 0.5, size = 1.2) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 1) +
  facet_wrap(~ Question, ncol = 3) +
  scale_x_continuous(breaks = 1:5, limits = c(1, 5)) +
  labs(
    title = "Post TOSLS Percent vs Individual Post SELF Questions",
    x = "Post SELF Question Score",
    y = "Post TOSLS Percent"
  ) +
  scale_color_manual(values = c("2" = "blue", "3" = "red")) +
  theme_minimal()
