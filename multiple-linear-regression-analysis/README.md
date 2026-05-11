# Multiple Linear Regression & Outlier Diagnostics

This directory contains the R code used for evaluating the impact of outliers on a multiple linear regression model, as well as a Monte Carlo simulation demonstrating the frequency properties of a 95% confidence interval.

## Contents
- **R Script**: `multiple_regression_outliers.R` utilizes the `BGSgirls` dataset from the `alr4` package. It includes generating diagnostic plots to identify outliers (leverage points), refitting the model without the outlier, and running a 10,000-iteration simulation to verify confidence interval coverage.

## Associated Blog Post
A detailed academic write-up explaining the statistical theory and results is available here:
[重回帰分析における外れ値の処理と信頼区間のシミュレーション検証](https://fengmc2001.github.io/blog/multiple-linear-regression-analysis)