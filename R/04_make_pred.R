#!/usr/bin/env Rscript
library(jsonlite)
library(dplyr)
library(tidyr)
library(logger)
library(foreach)
source("R/main.R")

log_info("Computing Stage2_worldwide_pred.csv")
tryCatch({
  out <- read.csv("data/Stage1/Stage1_NovelCovid_worldwide.csv", stringsAsFactors = FALSE)
  dat_B <- read.csv("data/Stage1/Stage1_bestB.csv", stringsAsFactors = FALSE)
  out$date <- as.Date(out$date)
  country_vec <- unique(out$country)
  
  pred_func <- function(lastDate){
    lapply(1:length(country_vec), function(i){
      dat1 <- out %>% filter(country == country_vec[i])
      province_vec <- unique(dat1$province)
      theB <- dat_B$B[dat_B$country == country_vec[i]]
      lapply(1:length(province_vec), function(j){
        if(is.na(province_vec[j])){
          dat2 <- dat1 %>% filter(is.na(province))
        }else{
          dat2 <- dat1 %>% filter(province == province_vec[j])
        }
        calPred(dat = dat2, startDate=NULL, endDate = lastDate,
                method="Chao", data_source=NULL, arg_B = theB)
      }) %>% 
        Reduce(f = rbind)
    }) %>% 
      Reduce(f = rbind)
  }
  
  # excute yesterday's forecast
  lastDate <- max(as.Date(out$date)) - 1 
  pred <- pred_func(lastDate)
  write.csv(pred, file = "data/Stage2/Stage2_worldwide_pred.csv", row.names = FALSE)
  
  # append today's forecast
  lastDate <- max(as.Date(out$date))
  pred <- pred_func(lastDate)
  # country, province, date, actual_cases, 
  # predict_cases, predict_cases_1, predict_cases_2, 
  # predict_cases_3, predict_cases_4, predict_cases_5, predict_cases_6
  write.table(pred, "data/Stage2/Stage2_worldwide_pred.csv",
              sep = ",", col.names = !file.exists("data/Stage2/Stage2_worldwide_pred.csv"),
              row.names = FALSE,
              append = TRUE)
  log_info("The Stage2_worldwide_pred.csv has been up to date.")
}, 
error=function(e){
  log_info("Already up to date. There is no change for Stage2_worldwide_pred.csv.")
}
)

log_info("Computing Stage2_tw_pred.csv")
tryCatch({
  out <- read.csv("data/Stage1/Stage1_NovelCovid_tw.csv", stringsAsFactors = FALSE)
  out$date <- as.Date(out$date)
  
  pred_func <- function(lastDate){
    calPred(dat = out, startDate=NULL, endDate = lastDate,
            method="Chao", data_source=NULL)
  }
  
  # excute yesterday's forecast
  lastDate <- max(as.Date(out$date)) - 1 
  pred <- pred_func(lastDate)
  write.csv(pred, file = "data/Stage2/Stage2_tw_pred.csv", row.names = FALSE)
  
  # append today's forecast
  lastDate <- max(as.Date(out$date))
  pred <- pred_func(lastDate)
  # country, province, date, actual_cases, 
  # predict_cases, predict_cases_1, predict_cases_2, 
  # predict_cases_3, predict_cases_4, predict_cases_5, predict_cases_6
  write.table(pred, "data/Stage2/Stage2_tw_pred.csv",
              sep = ",", col.names = !file.exists("data/Stage2/Stage2_tw_pred.csv"),
              row.names = FALSE,
              append = TRUE)
  log_info("The Stage2_tw_pred has been up to date.")
  
  write.table(pred, "data/Stage2/Stage2_tw_pred_caches.csv",
              sep = ",", col.names = !file.exists("data/Stage2/Stage2_tw_pred_caches.csv"),
              row.names = FALSE,
              append = TRUE)
  log_info("The Stage2_tw_pred_caches has been up to date.")
}, 
error=function(e){
  log_info("Already up to date. There is no change for Stage2_tw_pred.")
}
)

log_info("Computing Stage2_tw_county_pred.csv")
tryCatch({
  out <- read.csv("data/Stage1/Stage1_Taiwan_CDC.csv", stringsAsFactors = FALSE)
  out$date <- as.Date(out$date)
  
  pred_func <- function(lastDate){
    lapply(unique(out$county), function(x){
      dat <- filter(out, county == x)
      calPred(dat, startDate=NULL, endDate = lastDate,
              method="Chao", data_source="tw_county")
    }) %>% Reduce(f = rbind)
  }
  
  # excute yesterday's forecast
  lastDate <- max(as.Date(out$date)) - 1 
  pred <- pred_func(lastDate)
  write.csv(pred, file = "data/Stage2/Stage2_tw_county_pred.csv", row.names = FALSE)
  
  # append today's forecast
  lastDate <- max(as.Date(out$date))
  pred <- pred_func(lastDate)
  # county, date, actual_cases, 
  # predict_cases, predict_cases_1, predict_cases_2, 
  # predict_cases_3, predict_cases_4, predict_cases_5, predict_cases_6
  write.table(pred, "data/Stage2/Stage2_tw_county_pred.csv",
              sep = ",", col.names = !file.exists("data/Stage2/Stage2_tw_county_pred.csv"),
              row.names = FALSE,
              append = TRUE)
  
  
  log_info("The Stage2_tw_pred has been up to date.")
}, 
error=function(e){
  log_info("Already up to date. There is no change for Stage2_tw_pred.")
}
)

