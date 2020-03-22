# Don't RUN...

library(foreach)
source("R/updateForecasts.R")
raw <- readRDS("historicalData2020-03-22.rds")
dat <- getData(raw, country_ = "Taiwan", province_ = NA, type = "cases")
out <- calPred(dat, endDate = as.Date("2020-03-22"))
out


date.stamp <- data.frame(DateRep=seq.Date(from = as.Date("2020-02-01"), to = as.Date("2020-03-21"), by = 'days'))
out <- foreach(i=1:length(date.stamp$DateRep), .combine = rbind, .verbose = T)%do%{
  foreach(j=1:nrow(raw), .combine = rbind)%do%{
    dat <- getData_(raw, row = j)
    calPred(dat, endDate = date.stamp$DateRep[i])
  }
}
write.csv(out, file = "output_worldwide.csv", row.names = FALSE)


dat <- getData(raw, country_ = "Taiwan", province_ = NA, type = "cases")
date.stamp <- data.frame(DateRep=seq.Date(from = as.Date("2020-02-01"), to = as.Date("2020-03-20"), by = 'days'))
out <- foreach(i=1:length(date.stamp$DateRep), .combine = rbind, .verbose = T)%do%{
    calPred(dat, endDate = date.stamp$DateRep[i])
}
write.csv(out, file = "output_TW.csv", row.names = FALSE)
