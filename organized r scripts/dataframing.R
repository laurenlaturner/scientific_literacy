## Clear the environment
rm(list=ls())

## Load necessary libraries
library(readxl)
library(lme4) # for mixed models if class random effects are needed
library(dplyr) # for transformations
library(glmmTMB) # for beta regression 
library(betareg) # different beta regression package
library(car) # for diagnostic plots
library(psych) # for descriptive stats
library(ggplot2) # for data visualization
library(MuMIn) # for AIC model reduction
library(performance) # for pseudo-R^2
library(effsize) # for Cohend's d

## Load data
df <- read_excel("C:/Users/laure/Desktop/scientific_literacy/for_jupyter/data.xlsx",
                 sheet="Sheet1")

# Descriptive statistics for overall understanding of data
summary(df)
describe(df)  # from psych package

# EDA: Histogram for normality check on pre/post test scores
hist(df$`pre SELF average`)
hist(df$`post SELF average`)
mean(df$`pre SELF average`, na.rm = TRUE)
sd(df$`pre SELF average`, na.rm = TRUE)

hist(df$`pre TOSLS score`)
hist(df$`post TOSLS score`)
mean(df$`pre TOSLS score`, na.rm = TRUE)
sd(df$`pre TOSLS score`, na.rm = TRUE)

# Standardization of variables
df.std <- df
df.std$`post SELF average` <- c(scale(df$`post SELF average`))
df.std$`pre SELF average` <- c(scale(df$`pre SELF average`))
df.std$`post TOSLS score` <- c(scale(df$`post TOSLS score`))
df.std$`pre TOSLS score` <- c(scale(df$`pre TOSLS score`))


## Likert Transformation (Centered between -1 and 1)
transform_likert <- function(x) {
  return((x - 3) / 2)
}

pre_questions <- paste0("pre SELF -  Q", 1:8)
post_questions <- paste0("post SELF -  Q", 1:8)

## Apply the transformation for centering Likert-scale data
df.std <- df %>%
  mutate(across(all_of(pre_questions), transform_likert)) %>%
  mutate(across(all_of(post_questions), transform_likert))

# Calculate delta (change in scores)
df.std$delta_self <- df.std$`post SELF average` - df.std$`pre SELF average`
df.std$delta_test <- df.std$`post TOSLS score` - df.std$`pre TOSLS score`

# Calculate delta of percentages
df.std$delta_test_percent <- df.std$delta_test/28

# Calculate percentages of scores (absolute values, out of 28)
df.std$perc_test <- df.std$`post TOSLS score`/28

# Convert 0's and 1's to be slightly shifted
df.std$perc_test[df.std$perc_test == 0] <- 0.0005
df.std$perc_test[df.std$perc_test == 1] <- 0.9995

## -- Effect Size --
cohen.d(df$`post TOSLS score`, df$`pre TOSLS score`, paired = TRUE, na.rm = TRUE)
