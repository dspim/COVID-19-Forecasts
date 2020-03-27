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
  saveRDS(raw, paste0("data/raw/historicalData.rds"))
},
error=function(e){
  log_error("Can not download data from Novel COVID-19 API.")
  log_error("Use cached data.")
},
finally = log_info("The COVID-19 historical data that has been imported.")
)

log_info("Download the Taiwan county level daily data from CDC website...")
tryCatch({
  cdc_url <- "https://nidss.cdc.gov.tw/ch/NIDSS_DiseaseMap.aspx?dc=1&dt=5&disease=19CoV" 
  httr::set_config(config(ssl_verifypeer = 0L))
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
  tw_cdc$date <- tw_cdc$date %>% 
    as.character()
  
  write.csv(tw_cdc, file = paste0("data/raw/TW_CDC_daily/tw_county_", (Sys.Date()-1), ".csv"),
            row.names = FALSE)  
},
error=function(e){
  log_error("Can not download data from Taiwan CDC.")
  log_error("Use cached data.")
},
finally = log_info("The Taiwan CDC historical data has been updated.")
)