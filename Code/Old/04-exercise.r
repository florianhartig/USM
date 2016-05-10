#Exercise,1


data=c(3.196864,4.291920,4.899847,5.020927,3.746708,4.193449,3.530901,6.126271,7.926927,5.242902,5.615995,5.289514,5.857824,7.337421,7.709084,5.673432,6.187052,5.726149,7.756734,7.911522,7.396525)



plot(data)




model <- function (N0 = 3, r=0.7, K=30, timesteps = 20){
  
  popdyn <- c(N0, rep(NA, timesteps))
  
  for (i in 1:timesteps){
    popdyn[i+1] <- popdyn[i] * (r+1) * (1 - popdyn[i] / K) 
  }
  return(popdyn)          
}



# cost function, calculate difference between model and data

objective <- function(x){
  
  NO = x[1]
  r = x[2]
  K = x[3]
  
  # TODO define objective function that calculates difference between model and data

}



# use the optim function i R to find the best fit to your objective

optim



plot(data, xlim = c(0,40), ylim = c(0,15))

lines(model(optimfit$par[1], optimfit$par[2], optimfit$par[3], 40), col = "red", lwd = 1)











