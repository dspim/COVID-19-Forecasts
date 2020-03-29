#!/usr/bin/env Rscript
library(jsonlite)
library(dplyr)
library(tidyr)

getData <- function(raw, country_="taiwan*", province_=NA, type="cases"){
  raw_ <- raw %>% 
    filter(country==country_) 
  
  dat <- raw_[["timeline"]][[type]] %>% 
    gather(key = "date", value="cases") %>% 
    mutate(date=as.Date(date, "%m/%d/%y")) %>% 
    mutate(country=country_, province=province_) %>% 
    mutate(actual_cases=as.numeric(cases)) %>% 
    select(country, province, date, actual_cases)
  
  dat
}

getData_ <- function(raw, row=1, type="cases"){
  raw_ <- raw %>% 
    slice(row)
  country_ <- raw_[[1]]
  province_ <- raw_[[2]]
  dat <- raw_[["timeline"]][[type]] %>% 
    gather(key = "date", value="cases") %>% 
    mutate(date=as.Date(date, "%m/%d/%y")) %>% 
    mutate(country=country_, province=province_) %>% 
    mutate(actual_cases=as.numeric(cases)) %>% 
    select(country, province, date, actual_cases)
  
  dat
}


calPred <- function(dat, startDate=NULL, endDate=NULL, method="Chao", 
                    data_source=NULL){
  
  if(is.null(endDate)){
    endDate <- as.Date(max(dat$date))
  }
  if(is.null(startDate)){
    tryCatch({
      startDate <- as.Date(format(endDate - 14, '%Y-%m-%d'))
    }, error = function(e){
      startDate <- as.Date(min(dat$date))
    }, finally = {
      startDate
    })
  }
  
  dat_ <- dat %>% 
    filter(between(date, startDate, endDate)) 
  
  # Change forecast method here
  if(method=="Chao"){
    pred <- Pred.Chao(dat_$actual_cases, m=1:7)
  }
  
  pred <- data.frame(t(round(pred, 2)))
  names(pred) <- c("predict_cases", 
                   "predict_cases_2", "predict_cases_3", "predict_cases_4",
                   "predict_cases_5", "predict_cases_6", "predict_cases_7")
  
  if(is.null(data_source)){
    out <- data.frame(dat_[nrow(dat_), c(1:4)], pred)
    return(out)
  }
  if(data_source == "tw_county"){
    # source: Taiwan CDC county level data
    out <- data.frame(dat_[nrow(dat_), 1:3], pred)
  }

  return(out)
}

#' Chao2 richness estimator and its extrapolation
#' @param x a vector of daily cumulative confirmed cases (default is last 14 days).
#' @param m a vector of periods for forecasting (default is 0:7 days)
#' @param B a tuning parameter adjust from Hsieh, Ma and Chao (2016)
Pred.Chao <- function(x, m=0:7, B=17){
  # Chao 1987
  n <- length(x)
  Q1 <- (x[n]-x[n-1]) * B
  Q2 <- ((x[n-1]-x[n-2]) - (x[n]-x[n-1])) * choose(B,2)
  
  Q0 <- ifelse(Q2>0, (B-1)/B*Q1^2/2/Q2, (B-1)/B*Q1*(Q1-1)/2)
  Sobs <- x[n]
  a <- ifelse(Q1==0, 0, Q1/(n*Q0+Q1))
  Sm <- sapply(m, function(m) {Sobs + Q0*(1-(1-a)^m)})
  Sm
}
