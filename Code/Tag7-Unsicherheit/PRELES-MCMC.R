
rm(list=ls())
library(Rpreles)
library(DEoptim)
library(coda)
library(IDPmisc)


load('Boreal_sites.rdata')
load('par.rdata')

parind <- c(5:10,31) #Suggested indexes for PRELES parameters


runPreles <- function(parx = NULL, indices = NULL){
  p <- par$def
  p[indices] = parx
  out <- PRELES(PAR=s1$PAR, TAir=s1$TAir, VPD=s1$VPD, Precip=s1$Precip, CO2=s1$CO2, fAPAR=s1$fAPAR, p=p[1:30] )
  return(out)
}

# Wie gut fitted das Modell zu den Daten?

NLL <- function(parx){
  out <- runPreles(parx[1:(length(parx)-1)], parind[1:(length(parx)-1)])
  NlogLik = sum(dnorm(s1$GPPobs , mean = out$GPP, sd = parx[length(parx)], log = T)) # entspricht sum((s1$GPPobs - out$GPP)^2) - später eventuell auch SD mitoptimieren
  return(-NlogLik)
}

# Finden erst mal den besten Wert

optimalParam<- DEoptim(NLL, lower = par$min[parind], upper =  par$max[parind])


optimalParam$optim$bestmem

#parind <- c(5:10, 31)


posterior <- function(parx){
  prior = sum(dunif(parx, min = par$min[parind], max = par$max[parind], log = T)) 
  if (prior == -Inf) return(-Inf)
  LL = - NLL(parx)
  return(LL + prior)
}


run_metropolis_MCMC <- function(startvalue, iterations){
  chain = array(dim = c(iterations+1,length(startvalue)))
  chain[1,] = startvalue
  post = rep(NA, iterations+1)
  post[1] = posterior(startvalue)
  
  for (i in 1:iterations){
    
    proposal = rnorm(length(startvalue),mean = chain[i,], sd= (par$max[parind] - par$min[parind])/150)
    
    newPosterior = posterior(proposal)
    probab = exp(newPosterior - post[i])
    if (runif(1) < probab){
      chain[i+1,] = proposal
      post[i+1] = newPosterior
    }else{
      chain[i+1,] = chain[i,]
      post[i+1] = post[i]
    }
  }
  colnames(chain)= par$name[parind]
  return(cbind(chain, post))
}

iter = 5000
burnin = 2000
thin = 5

MCMCparamtersample <- run_metropolis_MCMC(optimalParam$optim$bestmem, iter)
MCMCparamtersample <- MCMCparamtersample[seq(burnin,iter, thin),] # burnin and thinning 
plot(mcmc(MCMCparamtersample, start = burnin, thin = thin))


# Wesentliche effizientere MCMC algorithmen wären, z.B., hier https://github.com/florianhartig/LearningBayes/blob/master/CommentedCode/02-Samplers/MCMC/LaplacesDeamon.md



panel.hist <- function(x, ...)
{
  usr <- par("usr"); on.exit(par(usr))
  par(usr = c(usr[1:2], 0, 1.5) )
  h <- hist(x, plot = FALSE)
  breaks <- h$breaks; nB <- length(breaks)
  y <- h$counts; y <- y/max(y)
  rect(breaks[-nB], 0, breaks[-1], y, col="blue4", ...)
}

panel.cor <- function(x, y, digits=2, prefix="", cex.cor)
{
  usr <- par("usr"); on.exit(par(usr))
  par(usr = c(0, 1, 0, 1))
  r <- abs(cor(x, y, method = "spearman"))
  txt <- format(c(r, 0.123456789), digits=digits)[1]
  txt <- paste(prefix, txt, sep="")
  if(missing(cex.cor)) cex <- 0.8/strwidth(txt)
  text(0.5, 0.5, txt, cex = cex * r)
}

betterPairs <- function(YourData){
  return(pairs(YourData, lower.panel=function(...) {par(new=TRUE);ipanel.smooth(...)}, diag.panel=panel.hist, upper.panel=panel.cor))
}


betterPairs(MCMCparamtersample)


save(MCMCparamtersample, file = "mcmc.Rdata")

load(file = "mcmc.Rdata")


# Vorhersageunsicherheit


confidence = matrix(NA, ncol = length(runPreles()$GPP), nrow = nrow(MCMCparamtersample))
predictions = confidence

for (i in 1:nrow(MCMCparamtersample)){
  param <- MCMCparamtersample[i,]
  confidence[i,] <- runPreles(param[1:(length(param)-2)], parind[1:(length(param)-2)])$GPP
  predictions[i,] = confidence[i,] + rnorm(length(confidence[i,]), sd = param[length(param)-1])
}

hist(rowSums(confidence))


confidenceregionUp <- apply(confidence, 2, function(x)quantile(x, probs = 0.95))
confidenceregionLow <- apply(confidence, 2, function(x)quantile(x, probs = 0.05))
predictionregionUp <- apply(predictions, 2, function(x)quantile(x, probs = 0.95))
predictionregionLow <- apply(predictions, 2, function(x)quantile(x, probs = 0.05))


bestOut <- runPreles(optimalParam$optim$bestmem[1:(length(optimalParam$optim$bestmem)-1)], parind[1:(length(optimalParam$optim$bestmem)-1)])

plot(bestOut$GPP, type = "l", ylab = "GPP", xlab = "Day", ylim = c(-1,11))

polygon(c(1:730,730:1), c(predictionregionUp, predictionregionLow[730:1]), col = "gold", border = NA)
polygon(c(1:730,730:1), c(confidenceregionUp, confidenceregionLow[730:1]), col = "maroon3", border = NA)

lines(bestOut$GPP, lwd = 1, col = "green")
points(s1$GPPobs, col = "black", cex =1.5, pch =3, lwd = 2)



# Residuals 

resGPP = bestOut$GPP - s1$GPPobs
resET = bestOut$ET - s1$ETobs

plot(bestOut$GPP, resGPP)
plot(resGPP, resET)

plot(acf(resGPP))




