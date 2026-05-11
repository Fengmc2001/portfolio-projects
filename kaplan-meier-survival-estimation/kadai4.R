#-------------------------------------------
# Kaplan–Meier 法による生存関数の計算
#-------------------------------------------

# （生存時間
survtime <- c(2, 4, 4, 5, 7)   # 各被験者の生存時間
event <- c(0, 0, 1, 1, 1)      # イベント発生 (1=発生, 0=打ち切り)
library(survival)
km <- survfit(Surv(survtime, event) ~ 1)
summary(km)

par(lwd = 2, cex.lab = 1.4, cex.axis = 1.2)
plot(km, xlab = "Month", ylab = "S(t)", mark.t = TRUE, 
     conf.int = FALSE, lwd = 2, cex = 2)


#
n <- 100 # サンプルサイズ
lambda <- 0.05 # 指数分布のパラメータ
set.seed(2025)
true_time <- rexp(n, rate = 0.05)
true_S <- function(t) {exp(-lambda * t)}

censor_time <- runif(n, min = 0, max = max(true_time))
obs_time <- pmin(true_time, censor_time)
status <- as.numeric(true_time <= censor_time) # 1=イベント, 0=打ち切り
dat_censored <- data.frame(time = obs_time, status = status)
dat_naive <- subset(dat_censored, status == 1)
fit_cens <- survfit(Surv(time, status) ~ 1, data = dat_censored)
fit_naive <- survfit(Surv(time, status) ~ 1, data = dat_naive)

plot(fit_cens,
     col = "blue", lwd = 2, # col：色，lwd：線の太さ
     xlab = "Time", ylab = "Survival probability", # 軸ラベル
     xlim = c(0, 80), ylim = c(0, 1), # プロットする範囲の制限
     conf.int = FALSE, # 信頼区間を非表示
     mark.t = TRUE # 打ち切りのマークを表示
)
lines(fit_naive, col = "red", lwd = 2, conf.int = FALSE)
curve(true_S, from = 0, to = 80, col = "magenta", lwd = 2, add = TRUE)

#practice1
set.seed(2025) 
censor_time1 <- pmin(runif(n, min = 0, max = max(true_time)), 30)
obs_time1 <- pmin(true_time, censor_time1)
status1 <- as.numeric(true_time <= censor_time1) # 1=イベント, 0=打ち切り
dat_censored1 <- data.frame(time = obs_time1, status = status1)
#dat_naive1 <- subset(dat_censored1, status == 1)
fit_cens1 <- survfit(Surv(time, status) ~ 1, data = dat_censored1)
#fit_naive1 <- survfit(Surv(time, status) ~ 1, data = dat_naive)

lines(fit_cens1, col = "green", lwd = 2, conf.int = FALSE)
legend("topright",
       legend = c("True survival (theoretical)",
                  "KM with censoring (correct)",
                  "Ignoring censoring (biased)",
                  "Exercise1"),
       col = c("magenta", "blue", "red","green"), lty = c(1,1,1,1), lwd = 1,cex = 0.5)



#2
getwd()
list.files()
save.dir <- "/Users/fengmc/Library/CloudStorage/OneDrive-東京理科大学/大学/課題/3/Experiment_Souzu/4"
example.data <- read.csv(file.path(save.dir, "example_data.csv"), 
                         check.names = FALSE)
example.data$group <- factor(example.data$group, 
                             labels = c("Control","Treatment"))
fit.km <- survfit(Surv(time, status) ~ group, data = example.data)
par(lwd = 2, cex.lab = 1.3, cex.axis = 1.1, mar = c(4.5, 4.5, 2, 1))
plot(fit.km, col = c("gray40","darkorange"), lwd = 3, xlab = "Time", ylab
     = "S(t)", mark.time = TRUE, cex = 1.2)
legend("topright", c("Control","Treatment"), col = c("gray40","darkorange"), 
       lty = 1, lwd = 3, bty = "n")
survdiff(Surv(time, status) ~ group, data = example.data)


#exercise2

#2
(library(survival))
str(veteran)
example.data1 <- veteran[, c("time", "status", "trt")]
example.data1$group <- factor(example.data1$trt, 
                             labels = c("Control","Treatment"))

fit.km <- survfit(Surv(time, status) ~ group, data = example.data1)
par(lwd = 2, cex.lab = 1.3, cex.axis = 1.1, mar = c(4.5, 4.5, 2, 1))
plot(fit.km, col = c("gray40","darkorange"), lwd = 3, xlab = "Time", ylab
     = "S(t)", mark.time = TRUE, cex = 1.2)
legend("topright", c("Control","Treatment"), col = c("gray40","darkorange"), 
       lty = 1, lwd = 3, bty = "n")
survdiff(Surv(time, status) ~ group, data = example.data1)
