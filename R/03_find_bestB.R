library(dplyr)
dat_world <- read.csv("data/Stage1/Stage1_NovelCovid_worldwide.csv")
dat_world <- dat_world %>% 
  group_by(country, date) %>% 
  mutate(cul_cases = sum(actual_cases)) %>% 
  ungroup() %>% 
  select(country, date, cul_cases) %>% 
  distinct()

get_data <- function(arg_c = "USA", arg_n = 1){
  d <- dat_world %>% 
    filter(country == arg_c) %>% 
    arrange(date) %>% 
    tail(17) %>% 
    select(cul_cases) %>% 
    unlist() %>% 
    unname()
  # [1]   3499   4632   6421   7783  13677  19100  25489  
  #       33276  43847  53740  65778  83836 101657 121478
  l <- length(d)
  if(arg_n == 1){
    tr <- d[(l-14):(l-1)]
    ans <- d %>% tail(1)
  }else if(arg_n == 2){
    tr <- d[(l-15):(l-2)]
    ans <- d %>% tail(2)
  }else if(arg_n == 3){
    tr <- d[(l-16):(l-3)]
    ans <- d %>% tail(3)
  }
  return(list(tr = tr, ans = ans))
}
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
RSS <- function(p, t){
  sum((p - t)^2)
}
get_pred <- function(C, N, BB){
  d <- get_data(C, N)
  if(N == 1){
    pred <- Pred.Chao(d$tr, B = BB)[2]
  }else if(N == 2){
    pred <- Pred.Chao(d$tr, B = BB)[2:3]
  }else if(N == 3){
    pred <- Pred.Chao(d$tr, B = BB)[2:4]
  }
  return(data.frame(pred = pred, ans = d$ans))
}

time1 <- Sys.time()
tuning_p <- c(2:300)
result <- sapply(unique(dat_world$country), function(C){
  idx <- lapply(tuning_p, function(BB){
    dat_rss <- lapply(1:3, function(i){
      get_pred(C = C, N = i, BB = BB)
    }) %>% 
      Reduce(f = rbind) 
    rss <- RSS(p = dat_rss$pred, t = dat_rss$ans)
    return(rss)
  }) %>% 
    which.min()
  return(tuning_p[idx])
})
time2 <- Sys.time()
time2 - time1 # 12 mins

out <- data.frame(country = unique(dat_world$country), B = result)
write.csv(out, file = "data/Stage1/Stage1_bestB.csv", row.names = FALSE)
