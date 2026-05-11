# ===============================
#   Data Loading and Preparation
# ===============================

getwd()

base0 <- read.csv("/Users/fengmc/Library/CloudStorage/OneDrive-東京理科大学/大学/課題/3/Experiment_Souzu/6/base0.csv")
after0 <- read.csv("/Users/fengmc/Library/CloudStorage/OneDrive-東京理科大学/大学/課題/3/Experiment_Souzu/6/after0.csv")

# Merge the two datasets by ID
yobi <- merge(base0, after0, by = "id")

# Convert group variable to factor with English labels
yobi$group <- factor(yobi$group,
                     levels = c("N", "P"),
                     labels = c("Drug group", "Placebo group"))

# Check the data
head(yobi)

# ===============================
#   Task 1: Descriptive Statistics
# ===============================
library(dplyr)

# ---- (1) Summary statistics for continuous variables ----
summary_stats <- yobi %>%
  group_by(group) %>%
  summarise(
    n = n(),
    age_mean = mean(age), age_sd = sd(age),
    age_median = median(age), age_min = min(age), age_max = max(age),
    sbp_b_mean = mean(sbp_b), sbp_b_sd = sd(sbp_b),
    sbp_b_median = median(sbp_b), sbp_b_min = min(sbp_b), sbp_b_max = max(sbp_b),
    dbp_b_mean = mean(dbp_b), dbp_b_sd = sd(dbp_b),
    dbp_b_median = median(dbp_b), dbp_b_min = min(dbp_b), dbp_b_max = max(dbp_b),
    sbp_a_mean = mean(sbp_a), sbp_a_sd = sd(sbp_a),
    sbp_a_median = median(sbp_a), sbp_a_min = min(sbp_a), sbp_a_max = max(sbp_a),
    dbp_a_mean = mean(dbp_a), dbp_a_sd = sd(dbp_a),
    dbp_a_median = median(dbp_a), dbp_a_min = min(dbp_a), dbp_a_max = max(dbp_a)
  )
summary_stats

# → Displays mean and SD for each group


# ---- (2) Histograms (black–gray style) ----
num_vars <- c("age", "sbp_b", "dbp_b", "sbp_a", "dbp_a")

par(mfrow = c(2, 3), bg = "white")  # 2x3 layout, white background
for (var in num_vars) {
  hist(yobi[[var]],
       main = paste("Frequency of", var),
       xlab = var,
       col = "gray70",    # gray bars
       border = "black",  # black borders
       breaks = 10,
       cex.main = 0.8)
}

barplot(table(yobi$sex),
        main = "Frequency of sex",
        col = "gray70",
        border = "black",
        ylab = "Frequency",
        cex.main = 0.8)


# ---- (3) Sex distribution ----
sex_summary <- yobi %>%
  group_by(group, sex) %>%
  summarise(count = n()) %>%
  mutate(percentage = count / sum(count) * 100)

sex_summary


# ===============================
#   Task 2: Correlation and Scatter Plots
# ===============================

# ---- (1) Correlation matrix ----
cor_matrix <- yobi %>%
  select(age, sbp_b, dbp_b, sbp_a, dbp_a) %>%
  cor(use = "complete.obs")
cor_matrix

# ---- (2) Pairwise scatter plots ----
pairs(yobi[, c("age", "sbp_b", "dbp_b", "sbp_a", "dbp_a")],
      main = "Pairwise Scatter Plots",
      pch = 21, col = "black", bg = "gray80")


# ===============================
#   Task 3: Group Comparison (SBP after)
# ===============================

library(ggplot2)
library(dplyr)

yobi_plot <- yobi %>%
  group_by(group, sbp_a) %>%
  summarise(count = n(), .groups = "drop")

# プロット
ggplot(yobi_plot, aes(x = group, y = sbp_a,
                      color = group, shape = group)) +
  geom_point(aes(alpha = count), size = 4, stroke = 1.2) +
  scale_alpha_continuous(range = c(0.5, 1), guide = "none")+
  scale_color_manual(values = c("#1F77B4", "#E24A33")) +  # 蓝 & 橙
  scale_shape_manual(values = c(16, 17)) +  # 圆 & 三角
  labs(
    title = "Systolic Blood Pressure by Group (After 2 months)",
    x = "Group",
    y = "Systolic Blood Pressure (mmHg)"
  ) +
  theme_minimal(base_size = 16) +
  theme(
    legend.position = "top",
    legend.title = element_blank(),
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12),
    panel.grid.major.y = element_line(color = "grey80", size = 0.4)
  )


# ===============================
#   Task 4: Group Balance Check
# ===============================
#ok


# ===============================
#   Task 5: Two-sample t-tests
# ===============================

# 【1】開始時点（SBP_b）の群間比較
t_test_before <- t.test(sbp_b ~ group, data = yobi, var.equal = FALSE)
t_test_before

# 【2】2か月後（SBP_a）の群間比較
t_test_after <- t.test(sbp_a ~ group, data = yobi, var.equal = FALSE)
t_test_after

# 【3】結果
cat("\n---- t-test Results ----\n")
cat("Before (SBP_b):\n")
print(t_test_before)

cat("\nAfter (SBP_a):\n")
print(t_test_after)

# ===============================
#   Task 6
# ===============================

# 【1】変化量（差分）を計算
yobi$diff <- yobi$sbp_a - yobi$sbp_b   # 2か月後 − 開始時点

# 【2】群ごとの要約統計量を確認
library(dplyr)
diff_summary <- yobi %>%
  group_by(group) %>%
  summarise(
    n = n(),
    mean_diff = mean(diff, na.rm = TRUE),
    sd_diff   = sd(diff, na.rm = TRUE),
    median_diff = median(diff, na.rm = TRUE),
    min_diff = min(diff, na.rm = TRUE),
    max_diff = max(diff, na.rm = TRUE)
  )
diff_summary

# 【3】2群間の変化量の母平均の差を t検定で確認
t_test_diff <- t.test(diff ~ group, data = yobi, var.equal = FALSE)
t_test_diff


###############################################################
#   収縮期血圧（SBP）の変化量を主要変数とした検定・検出力分析
###############################################################

# --- データの読み込み --- #
base1 <- read.csv("/Users/fengmc/Library/CloudStorage/OneDrive-東京理科大学/大学/課題/3/Experiment_Souzu/6/base1.csv")     # 投与前データ（Before）
after1 <- read.csv("/Users/fengmc/Library/CloudStorage/OneDrive-東京理科大学/大学/課題/3/Experiment_Souzu/6/after1.csv")   # 投与後データ（After）

# --- ライブラリの読み込み --- #
library(dplyr)

# --- データのソート（groupとid順）--- #
base1s <- arrange(base1, group, id)
after1s <- arrange(after1, group, id)

# --- データのマージ（対応付け）--- #
main <- left_join(base1s, after1s, by = c("group", "id"))

# --- 収縮期血圧の変化量（差分）を計算 --- #
main$diff <- main$sbp_a - main$sbp_b

###############################################################
# 課題8：群ごとの基本統計量と性別の度数・割合（DBPなし）
###############################################################



# --- (1) 連続量データの基本統計量 --- #
summary_stats <- main %>%
  group_by(group) %>%
  summarise(
    n = n(),
    age_mean = mean(age, na.rm = TRUE),
    age_sd = sd(age, na.rm = TRUE),
    age_median = median(age, na.rm = TRUE),
    age_min = min(age, na.rm = TRUE),
    age_max = max(age, na.rm = TRUE),
    
    sbp_b_mean = mean(sbp_b, na.rm = TRUE),
    sbp_b_sd = sd(sbp_b, na.rm = TRUE),
    sbp_b_median = median(sbp_b, na.rm = TRUE),
    sbp_b_min = min(sbp_b, na.rm = TRUE),
    sbp_b_max = max(sbp_b, na.rm = TRUE),
    
    sbp_a_mean = mean(sbp_a, na.rm = TRUE),
    sbp_a_sd = sd(sbp_a, na.rm = TRUE),
    sbp_a_median = median(sbp_a, na.rm = TRUE),
    sbp_a_min = min(sbp_a, na.rm = TRUE),
    sbp_a_max = max(sbp_a, na.rm = TRUE),
    
    diff_mean = mean(diff, na.rm = TRUE),
    diff_sd = sd(diff, na.rm = TRUE),
    diff_median = median(diff, na.rm = TRUE),
    diff_min = min(diff, na.rm = TRUE),
    diff_max = max(diff, na.rm = TRUE)
  )

print(summary_stats)


# --- (2) 2値変数（sex）の度数と割合 --- #
sex_summary <- main %>%
  group_by(group, sex) %>%
  summarise(count = n()) %>%
  mutate(percentage = round(count / sum(count) * 100, 1))

print(sex_summary)

###############################################################
# 課題9
###############################################################
#ok

###############################################################
# 課題10：主要変数（Diff = SBP(a) − SBP(b)）の母平均の比較
###############################################################

# --- (1) 2群間の母平均の差を t検定で確認 --- #
t_test_diff <- t.test(diff ~ group, data = main, var.equal = FALSE)
print(t_test_diff)

