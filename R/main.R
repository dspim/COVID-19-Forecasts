library(jsonlite)
library(dplyr)
library(tidyr)

# library(lubridate)

raw <- fromJSON("https://corona.lmao.ninja/historical")
saveRDS(raw, paste0("../data/historicalData", Sys.Date(), ".rds"))


getData <- function(raw, country_="Taiwan*", province_=NA, type="cases"){
  raw_ <- raw %>% 
    filter(country=="Taiwan*") 
  
  dat <- raw_[["timeline"]][[type]] %>% 
    gather(key = "date", value="cases") %>% 
    mutate(date=as.Date(date, "%m/%d/%y")) %>% 
    mutate(country=country_, province=province_) %>% 
    mutate(cases=as.numeric(cases)) %>% 
    select(country, province, date, cases)
  
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
    mutate(cases=as.numeric(cases)) %>% 
    select(country, province, date, cases)
  
  dat
}

Pred.Chao <- function(x, m){
  # Chao 1987
  n <- length(x)
  Q1 <- (x[n]-x[n-1]) * n
  Q2 <- ((x[n-1]-x[n-2]) - (x[n]-x[n-1])) * choose(n,2)
  
  Q0 <- ifelse(Q2>0, (n-1)/n*Q1^2/2/Q2, (n-1)/n*Q1*(Q1-1)/2)
  Sobs <- x[n]
  a <- ifelse(Q1==0, 0, Q1/(n*Q0+Q1))
  Sm <- sapply(m, function(m) {Sobs + Q0*(1-(1-a)^m)})
  Sm
}


calPred <- function(dat, startDate=NULL, endDate=NULL, method="Chao"){
  
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
  
  if(method=="Chao"){
    n <- nrow(dat_)
    pred <- Pred.Chao(dat_$cases[-n], m=1:7)
  }
  pred <- data.frame(t(round(pred, 2)))
  out <- data.frame(dat_[n,], pred)
  names(out) <- c("country", "province", "date", 
                  "actual_cases", "predict_cases", 
                  "predict_cases_1", "predict_cases_2", "predict_cases_3",
                  "predict_cases_4", "predict_cases_5", "predict_cases_6")

  out
}
