#!/usr/bin/env Rscript
library(jsonlite)
library(dplyr)
library(tidyr)
library(logger)
library(foreach)
library(rvest)
library(xml2)
library(httr)
source("R/main.R")

log_appender(appender =  appender_tee("updateForecasts.log"))
# download historical covid-19 data
log_info("Download the COVID-19 historical data from Novel COVID-19 API...")
tryCatch({
  # raw <- fromJSON("https://corona.lmao.ninja/historical")
  raw <- fromJSON("https://corona.lmao.ninja/v2/historical")
  saveRDS(raw, paste0("./data/historicalData.rds"))
  },
  error=function(e){
    log_error("Can not download data from Novel COVID-19 API.")
    log_error("Use cached data.")
    },
  finally = log_info("The COVID-19 historical data that has been imported.")
)

log_info("Download the Taiwan county level historical data from CDC website...")
tryCatch({
  cdc_url <- "https://nidss.cdc.gov.tw/ch/NIDSS_DiseaseMap.aspx?dc=1&dt=5&disease=19CoV" 
  cdc_raw <- GET(url = cdc_url) %>%
    content() %>% 
    html_table(fill = TRUE) 
  tw_cdc <- cdc_raw[[19]][-23, ]
  names(tw_cdc) <- c("county", "actual_cases")
  # update yesterday's data at every morning around 06:00. 
  tw_cdc$date <- regmatches(cdc_raw[[18]]$X1, regexec("資料更新時間為[0-9]{4}\\/[0-9]{1,2}\\/[0-9]{1,2}", cdc_raw[[18]]$X1)) %>% 
    regmatches(., regexec("[0-9]{4}\\/[0-9]{1,2}\\/[0-9]{1,2}", .)) %>%
    unlist() %>% 
    as.Date() - 1 
  tw_cdc$predict_cases <- 0
  tw_cdc$predict_cases_1 <- 0
  tw_cdc$predict_cases_2 <- 0
  tw_cdc$predict_cases_3 <- 0
  tw_cdc$predict_cases_4 <- 0
  tw_cdc$predict_cases_5 <- 0
  tw_cdc$predict_cases_6 <- 0
  d <- read.csv("./data/tw_county.csv", stringsAsFactors = FALSE)
  d <- d %>% 
    rbind(tw_cdc) 
  write.csv(d, file = "./data/tw_county.csv")  
},
error=function(e){
  log_error("Can not download data from Taiwan CDC.")
  log_error("Use cached data.")
},
finally = log_info("The Taiwan CDC historical data has been updated.")
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
  out <- read.csv("./data/output_worldwide.csv", stringsAsFactors = FALSE)
  out$date <- as.Date(out$date)
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
  out <- read.csv("./data/output_TW.csv",  stringsAsFactors = FALSE)
  out$date <- as.Date(out$date)
  lastDate <- as.Date(as.character(tail(out$date,1)))
  seqDate <- seq.Date(from = as.Date(format(lastDate+1, '%Y-%m-%d')), to = as.Date(nowDate), by = 'days')
  out.new <- foreach(i=1:length(seqDate), .combine = rbind, .verbose = TRUE)%do%{
    dat <- getData(raw, country_ = "taiwan*", province_ = NA)
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

log_info("Checking whether the Taiwan county level forecasts should be updated.")
tryCatch({
  out <- read.csv("./data/tw_county.csv",  stringsAsFactors = FALSE)
  out$date <- as.Date(out$date)
  lastDate <- as.Date(as.character(tail(out$date,1)))
  seqDate <- seq.Date(from = as.Date(format(lastDate+1, '%Y-%m-%d')),
                      to = as.Date(Sys.Date()-1), by = 'days')
  # set start_date to 14 days after the firstday of the raw data when initializing /data/tw_county.csv.
  # seqDate <- seq.Date(from = as.Date("2020-02-14"), to = as.Date(Sys.Date()-1), by = 'days')
  county_vec <- unique(out$county) %>% as.character()
  out.new <- foreach(i=1:length(seqDate), .combine = rbind, .verbose = TRUE)%do%{
    foreach(j=1:length(county_vec), .combine = rbind)%do%{
      dat <- filter(out, county == county_vec[j]) %>% 
        mutate(cases = as.numeric(actual_cases))
      calPred(dat, endDate = seqDate[i], data_source = "tw_county")
    }
  }
  # out_ <- rbind(out[1:352,], out.new)
  out_ <- rbind(out, out.new) %>% 
    group_by(county, date) %>% 
    dplyr::tail(1)
  write.csv(out_, file = "./data/tw_county.csv", row.names = FALSE)
  log_info("The tw_county.csv has been up to date.")
}, 
error=function(e){
  log_info("Already up to date. There is no change for tw_county.csv.")
}
)

log_info("Mission completed.")

