install.packages("psych")

library(dplyr)
library(psych)

base0 <- read.csv("/Users/fengmc/Library/CloudStorage/OneDrive-東京理科大学/大学/課題/3/Experiment_Souzu/6/base0.csv")
after0 <- read.csv("/Users/fengmc/Library/CloudStorage/OneDrive-東京理科大学/大学/課題/3/Experiment_Souzu/6/after0.csv")

yobi <- merge(base0, after0, by=("id"))

yobi_n <- filter(yobi, group=="N")
yobi_p <- filter(yobi, group=="P")




describe(yobi_n)
describe(yobi_p)

hist(yobi_n$age)
hist(yobi_n$sbp_b)
hist(yobi_n$dbp_b)
hist(yobi_n$sbp_a)
hist(yobi_n$dbp_a)

hist(yobi_p$age)
hist(yobi_p$sbp_b)
hist(yobi_p$dbp_b)
hist(yobi_p$sbp_a)
hist(yobi_p$dbp_a)

nrow(filter(yobi_n, sex=="F"))/nrow(yobi_n)
nrow(filter(yobi_n, sex==""))/nrow(yobi_n)