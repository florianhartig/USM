

################# create truth ###################################################
# this is our "truth"
# I'm creating here data from a stochastic population model with additional observation
# error. We won't fit exactly the same model, just so that we know exactly what the 
# true parameters are that were used to create the data 


fullmodel <- function (N0 = 3, r=0.4, K=60, procerr=0.2, obserr=1.2, timesteps = 20){
  
  popdyn <- c(N0, rep(NA, timesteps))
  for (i in 1:timesteps){
    popdyn[i+1] <- popdyn[i] * (r+1) * (1 - popdyn[i] / K) + rnorm(1,sd = procerr)  
  }
  popobs = rnorm((timesteps+1),popdyn, sd = obserr)
  return(data.frame(popdyn, popobs)  )        
}

# create full data, and take a part of that for fitting the model
# we keep the rest for validation
fullData <- fullmodel(timesteps = 40)
data = fullData$popobs[1:21]
plot(data)
save(fullData, file = "fulldata.RData")



############### create model to fit ##############################################

# OK, this is the model we want to fit for the moment
# It has the same structure as the truth, but no observation and no
# process error. Imagine this is your "complicated" model

model <- function (N0 = 3, r=0.7, K=30, timesteps = 20){
  
  popdyn <- c(N0, rep(NA, timesteps))
  for (i in 1:timesteps){
    popdyn[i+1] <- popdyn[i] * (r+1) * (1 - popdyn[i] / K) 
  }
  return(popdyn)          
}


############### Objective function ##############################################

# need sumthing that calculates for us the difference between the data that 
# we want to use to fit the model, and the model results 

objective <- function(x){
  
  NO = x[1]
  r = x[2]
  K = x[3]
  
  difference = (data - model(NO, r, K, 20))^2
  return(sum(difference))
  
}


######### Optimization ###############################



optimfit <- optim(c(1,1.3,40), objective, method = "Nelder-Mead")

# look at the help in optim and change the optimization algorithm. Do the results stay the same?

# plotting the results
plot(data, xlim = c(0,40), ylim = c(0,20))
lines(model(optimfit$par[1], optimfit$par[2], optimfit$par[3], 40), col = "red", lwd = 1)
lines(fullData$popdyn, col = "green")





######## Metropolis algorithm ################

library(coda)

proposalfunction <- function(param){
  return(rnorm(3,mean = param, sd= c(0.2,0.2,0.2)))
}

run_metropolis_MCMC <- function(startvalue, iterations){
  chain = array(dim = c(iterations+1,3))
  chain[1,] = startvalue
  for (i in 1:iterations){
    proposal = proposalfunction(chain[i,])
    
    probab = exp(-objective(proposal) + objective(chain[i,]))
    
    if (runif(1) < probab){
      chain[i+1,] = proposal
    }else{
      chain[i+1,] = chain[i,]
    }
  }
  return(mcmc(chain))
}

startvalue = c(4,1,20)
chain = run_metropolis_MCMC(startvalue, 100000)

# plotting the development in the chain an the marginal parameter distributions
plot(chain)


# to see correlations between parameters, we have to do a bit more

#For plotting run https://raw.githubusercontent.com/florianhartig/Cookbook/master/Plotting/Correlation/CorrelationDensityPlotWithIpanel.r

burnIn = 10000
betterPairs(chain[-(1:burnIn),])




############## forwarding of the parametric uncertainty to our predictions #######################

plot(data, xlim = c(0,40), ylim = c(0,20))

for (i in 1:1000){
  
  pars = chain[1000+50*i,]
  
  lines(model(pars[1], pars[2], pars[3], 40), col="#44444404", lwd = 10)
  
}

lines(model(optimfit$par[1], optimfit$par[2], optimfit$par[3], 40), col = "red", lwd = 1)
points(data, col = "red")
lines(fullData$popdyn, col = "green")










