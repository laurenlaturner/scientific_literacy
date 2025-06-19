## 2 proportion z-test on Change in TOSLS per BLS objective

## Clear the environment
rm(list=ls())

## Load data
df <- read_excel("C:/Users/laure/Desktop/scientific_literacy/for_jupyter/data.xlsx",
                 sheet="Sheet3")


library(tidyverse)
library(janitor)

# Clean up column names to make them easier to reference
df <- df %>% clean_names()

# Check cleaned column names
# names(df)
# pre_sum_correct, pre_total, post_sum_correct, post_total

# Add a column with p-values for each row
df <- df %>%
  mutate(
    p_value = pmap_dbl(
      list(pre_sum_correct, pre_total, post_sum_correct, post_total),
      function(pre_s, pre_n, post_s, post_n) {
        prop.test(x = c(pre_s, post_s), n = c(pre_n, post_n), correct = FALSE)$p.value
      }
    )
  )

library(dplyr)
library(janitor)
library(knitr)

# Assuming df is already cleaned and has the p_value column
pretty_df <- df %>%
  mutate(
    `Pre %` = round(pre_sum_correct / pre_total, 3),
    `Post %` = round(post_sum_correct / post_total, 3),
    `P-value` = signif(p_value, 3),
    `Significant?` = case_when(
      p_value < 0.001 ~ "*** (p < .001)",
      p_value < 0.01  ~ "** (p < .01)",
      p_value < 0.05  ~ "* (p < .05)",
      TRUE ~ "No"
    )
  ) %>%
  select(Name = 1, `Pre %`, `Post %`, `P-value`, `Significant?`)

# Print it nicely
kable(pretty_df, align = 'lcccl', caption = "Pre/Post Percentages and Significance Test Results")
