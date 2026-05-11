# Kaplan-Meier Survival Estimation

This directory contains the R scripts and sample dataset used for performing survival analysis, specifically focusing on Kaplan-Meier estimation and the log-rank test for right-censored data. 

## Contents
- **R Scripts**: `kadai4.R` contains the code to simulate survival times via the exponential distribution, compare "naive" removal of censored data against proper KM estimation, and apply the log-rank test to the `veteran` dataset.
- **Data**: `example_data.csv` is a small sample dataset containing time-to-event and censoring status for two groups.

## Associated Blog Post
A detailed academic write-up explaining the statistical theory and results is available here:
[Kaplan-Meier 推定量と右打ち切り](https://fengmc2001.github.io/blog/kaplan-meier-survival-analysis)
