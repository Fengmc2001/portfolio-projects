# パッケージのインストールと読み込み
library(alr4)

# データの読み込み
data(BGSgirls)
# 今回必要なデータのみを残す
BGSg <- subset(x = BGSgirls, select = c(HT9, WT9, HT18, WT18))

# 基本統計量と相関係数の確認
summary(BGSg)
cor(BGSg)

# 散布図行列
pairs(BGSg)

# 全変数を用いた回帰
mreg1 <- lm(WT18 ~ ., data = BGSg)
summary(mreg1)

# WT9とHT18を用いたモデル
mreg2 <- lm(WT18 ~ WT9 + HT18, data = BGSg)
summary(mreg2)

# 回帰診断プロット（外れ値の特定）
par(mfrow=c(2,2))
plot(mreg2, which=c(1,2,3,5))
par(mfrow=c(1,1))

# 外れ値（134番）の確認
BGSg[rownames(BGSg) == "134", ]
# 外れ値を削除
BGSg2 <- BGSg[rownames(BGSg) != "134", ]

# 削除後のデータで再度分析
mreg2_new <- lm(WT18 ~ WT9 + HT18, data = BGSg2)
summary(mreg2_new)

# 削除後の回帰診断プロット
par(mfrow=c(2,2))
plot(mreg2_new, which=c(1,2,3,5))
par(mfrow=c(1,1))


# ============================================================
# 信頼区間のシミュレーション検証
# ============================================================
M <- 10000
n <- 100
beta <- c(1, 2, -0.5)

ci.lower <- ci.upper <- rep(0,M)
set.seed(44)

count_in <- 0   # カウンタ：期待値含む
count_out <- 0  # カウンタ：期待値含まない

for (m in 1:M) { 
  x1 <- runif(n, -3, 3)
  x2 <- runif(n, -3, 3)
  error <- rnorm(n, 0, sqrt(5))
  y <- beta[1] + beta[2]*x1 + beta[3]*x2 + error
  reg <- lm(y ~ x1 + x2)
  ci.beta1 <- confint(reg)[2,] # x1 (beta[2]) の信頼区間
  ci.lower[m] <- ci.beta1[1]
  ci.upper[m] <- ci.beta1[2]
  
  if(ci.lower[m] > beta[2] | ci.upper[m] < beta[2]){
    count_out <- count_out + 1
  }else{
    count_in <- count_in + 1
  }
} 

cat("真の値を含む回数:", count_in, "\n")
cat("真の値を含まない回数:", count_out, "\n")
cat("被覆率:", count_in / M, "\n")