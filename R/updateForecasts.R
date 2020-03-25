#!/usr/bin/env Rscript
library(jsonlite)
library(dplyr)
library(tidyr)
library(logger)
library(foreach)
source("R/main.R")

log_appender(appender_file("updateForecasts.log"))
# download historical covid-19 data
log_info("Download the COVID-19 historical data from Novel COVID-19 API...")

tryCatch({
  raw <- fromJSON("https://corona.lmao.ninja/historical")
  saveRDS(raw, paste0("./data/historicalData.rds"))
  },
  error=function(e){
    log_error("Can not download data from Novel COVID-19 API.")
    log_error("Use cached data.")
    },
  finally = log_info("The COVID-19 historical data that has been imported.")
)

# Make the initial forecasts output
# date.stamp <- data.frame(DateRep=seq.Date(from = as.Date("2020-02-01"), to = as.Date("2020-03-21"), by = 'days'))
# out <- foreach(i=1:length(date.stamp$DateRep), .combine = rbind, .verbose = T)%do%{
#   foreach(j=1:nrow(raw), .combine = rbind)%do%{
#     dat <- getData_(raw, row = j)
#     calPred(dat, endDate = date.stamp$DateRep[i])
#   }
# }
# write.csv(out, file = "data/output_worldwide.csv", row.names = FALSE)

# Make the current forecasts output

nowDate <- as.Date(tail(names(raw$timeline$cases),1), "%m/%d/%y")
log_info(paste0("The date version of this data is ", nowDate))

log_info("Checking whether the worldwide forecasts should be updated.")
tryCatch({
  out <- read.csv("./data/output_worldwide.csv")
  lastDate <- as.Date(as.character(tail(out$date,1)))
  seqDate <- seq.Date(from = as.Date(format(lastDate+1, '%Y-%m-%d')), to = as.Date(nowDate), by = 'days')
  out.new <- foreach(i=1:length(seqDate), .combine = rbind, .verbose = TRUE)%do%{
    foreach(j=1:nrow(raw), .combine = rbind)%do%{
      dat <- getData_(raw, row = j)
      calPred(dat, endDate = seqDate[i])
    }
  }
  out_ <- bind_rows(out, out.new) %>% 
    distinct(country, province, date, .keep_all = TRUE)
  write.csv(out_, file = "./data/output_worldwide.csv", row.names = FALSE)
  log_info("The output_worldwide.csv has been up to date.")
  }, 
  error=function(e){
    log_info("Already up to date. There is no change for output_worldwide.csv.")
    }
  )

log_info("Checking whether the Taiwan forecasts should be updated.")
tryCatch({
  out <- read.csv("./data/output_TW.csv")
  lastDate <- as.Date(as.character(tail(out$date,1)))
  seqDate <- seq.Date(from = as.Date(format(lastDate+1, '%Y-%m-%d')), to = as.Date(nowDate), by = 'days')
  out.new <- foreach(i=1:length(seqDate), .combine = rbind, .verbose = TRUE)%do%{
    dat <- getData(raw, country_ = "Taiwan*", province_ = NA)
    calPred(dat, endDate = seqDate[i])
  }
  out_ <- bind_rows(out, out.new) %>% 
    distinct(country, province, date, .keep_all = TRUE)
  write.csv(out_, file = "./data/output_TW.csv", row.names = FALSE)
  log_info("The output_TW.csv has been up to date.")
  }, 
  error=function(e){
    log_info("Already up to date. There is no change for output_TW.csv.")
  }
)

