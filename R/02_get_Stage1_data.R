#!/usr/bin/env Rscript
library(dplyr)
library(foreach)
source("R/main.R")
raw <- readRDS("data/raw/historicalData.rds")

# Stage1_NovelCovid_worldwide
out <- foreach(j=1:nrow(raw), .combine = rbind) %do% {
  dat <- getData_(raw, row = j)
  } %>% distinct()
# country, province, date, actual_cases
write.csv(out, file = "data/Stage1/Stage1_NovelCovid_worldwide.csv", row.names = FALSE)

# Stage1_NovelCovid_tw
dat <- getData(raw, country_ = "taiwan*", province_ = NA, type = "cases") %>% 
  distinct()
# country, province, date, actual_cases
write.csv(dat, file = "data/Stage1/Stage1_NovelCovid_tw.csv", row.names = FALSE)

# Taiwan CDC data
cdc_h <- read.csv("data/raw/raw_Taiwan_CDC_historical.csv", stringsAsFactors = FALSE)
start_date <- cdc_h$date %>% as.Date() %>% max()
start_date <- start_date + 1 # 歷史資料最新日期的後一天開始
end_date <- Sys.Date() %>% as.Date()
end_date <- end_date - 1
# 執行日為Sys.Date()，但TW_CDC_daily的每日資料最新日期為檔名-1天
seq_date <- seq(start_date, end_date, by = "day") %>% as.character()
cdc_daily <- lapply(seq_date, function(date){
  read.csv(paste0("data/raw/TW_CDC_daily/tw_county_", date, ".csv"))
}) %>% 
  Reduce(f = rbind) 
dat_cdc <- rbind(cdc_h, cdc_daily)
# county, date, actual_cases
write.csv(dat_cdc, file = "data/Stage1/Stage1_Taiwan_CDC.csv", row.names = FALSE)