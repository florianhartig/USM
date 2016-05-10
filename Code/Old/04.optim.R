# Model fitting 

# helper funktion erst laden


simplifiedSim <- function(pars, rep=1, returnAverage = T) simulate(pars, no.repeated.sim=rep,nl.obj=model, 
                                                                   parameter.names=c('scout-prob', 'survival-prob', 'scouting-survival'),
                                                                   returnAverage = returnAverage)



trueParameters = c(0.4, 0.97, 0.9)
observedData <-  simplifiedSim(trueParameters, rep = 20, returnAverage = T)


# als fit funktion bauen wir uns hier eine "synthetic likelihood"

# Details der Methode sind erklärt in Hartig, F.; Calabrese, J. M.; Reineking, B.; Wiegand, T. & Huth, A. (2011) Statistical inference for stochastic simulation models - theory and application. Ecol. Lett., 14, 816-827.

fit <- function(pars){
  simdat <- simplifiedSim(pars, rep = 20, returnAverage = F)[,1]
  return(dnorm(observedData[1], mean = mean(simdat), sd =  sd(simdat), log = F))}

n = 30

parameters<-cbind(rep(0.4,n), seq(0.95, 0.99, length.out = n), rep(0.9,n))

result <- apply(parameters, 1, fit )

plot(seq(0.95, 0.99, length.out = n), result, type = "b")

