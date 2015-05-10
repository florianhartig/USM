#-------------------------------------------------------------------------------------
# I. Testing the function
#-------------------------------------------------------------------------------------


test <- simulate(c(0.7, 0.97, 0.9), no.repeated.sim=10,nl.obj=model, 
          parameter.names=c('scout-prob', 'survival-prob', 'scouting-survival'),
          returnAverage = T)


# for convenience later, I create a simplified version that 

simplifiedSim <- function(pars, rep=1, returnAverage = T) simulate(pars, no.repeated.sim=rep,nl.obj=model, 
                                         parameter.names=c('scout-prob', 'survival-prob', 'scouting-survival'),
                                         returnAverage = returnAverage)


test2 <- simplifiedSim(c(0.7, 0.97, 0.9))

#-------------------------------------------------------------------------------------
# II. Creation of the parameter sets of the full factorial experimental design
#-------------------------------------------------------------------------------------


parameter.values <- list(
  'scout-prob'    = list(min = 0.0,  max = 0.5, by=0.05),
  'survival-prob' = list(min = 0.95, max = 1.0, by=0.005),
  'scouting-survival' = list(min = 0.8, max = 1.0, by=0.05)
)

# get names of parameters
parameter.names <- names(parameter.values)
# create the full factorial design with the predefined 
# parameter value grid size
parameter.sequences <- lapply(parameter.values, function(x) {seq(x$min,x$max,x$by)})
names(parameter.sequences) <- parameter.names
full.factorial.design <- expand.grid(parameter.sequences)
# get number of combinations
design.combinations <- length(full.factorial.design[[1]])


# variable used for progress tracing 
# (global variable: not nice, but I see currently no other way in R)
already.processed <- 0
# simulate for all parameter sets and
# get results of all evalulation criteria as list
sim.results.ffd <- apply(full.factorial.design, 1, 
                                                 simulate, no.repeated.sim=1, 
                                                 nl.obj=model, trace.progress=T,
                                                 parameter.names=parameter.names, 
                                                 iter.length=design.combinations
                                                 )

results <- data.frame(full.factorial.design, t(sim.results.ffd) )

pairs(results)

linearFit<- lm(X1 ~ scout.prob * survival.prob * scouting.survival, data = results)
summary(linearFit)

library(sensitivity)

# src computes the Standardized Regression Coefficients (SRC), or the Standardized Rank Regression Coefficients (SRRC), which are sensitivity indices based on linear or monotonic assumptions in the case of independent factors

srcResults <- src(results[,1:3], results[,4], rank = F)
plot(srcResults)

pccResults <- pcc(results[,1:3], results[,4], rank = F)
plot(srcResults)


# Morris Screening

# morris implements the Morris's elementary effects screening method (Morris 1992). This method, based on design of experiments, allows to identify the few important factors at a cost of r * (p + 1) simulations (where p is the number of factors). This implementation includes some improvements of the original method: space-filling optimization of the design (Campolongo et al. 2007) and simplex-based design (Pujol 2009).


simplifiedSim2 <- function(parMat, rep=1, returnAverage = T, out = 1){

  parMat <- as.matrix(parMat) 
  
  res <- rep(NA, nrow(parMat))

  for (i in 1:nrow(parMat)){
    temp <- simulate(parMat[i,], no.repeated.sim=rep,nl.obj=model, 
    parameter.names=c('scout-prob', 'survival-prob', 'scouting-survival'),
    returnAverage = returnAverage)
    res[i] <- temp[out]
  }
  return(res)
}


morrisOut <- morris(model = simplifiedSim2, factors = 3, r = 10, binf = c(0,0.95,0.8), bsup = c(0.5,1,1),
                    design = list(type = "oat", levels = 10, grid.jump = 5))
print(morrisOut)
plot(morrisOut)


# sobol implements the Monte Carlo estimation of the Sobol' sensitivity indices. This method allows the estimation of the indices of the variance decomposition, sometimes referred to as functional ANOVA decomposition, up to a given order, at a total cost of (N + 1) * n where N is the number of indices to estimate. This function allows also the estimation of the so-called subset indices, i.e. the first-order indices with respect to single multidimensional inputs.


n <- 1000
X1 <- data.frame(matrix(runif(4 * n, max = 3), nrow = n))
X2 <- data.frame(matrix(runif(4 * n, max = 3), nrow = n))

sobolOut <- sobol(model = ishigami.fun, X1, X2, order = 2, nboot = 100)

print(sobolOut)
plot(sobolOut)


###########################################################
# UA

mittelwert = c(0.5, 0.97, 0.9)
sd = c(0.1, 0.005, 0.05)

samples = 200
output <- matrix(NA, nrow = samples, ncol = 3)

for (i in 1:samples){
  parameter <- rnorm(n = 3, mean = mittelwert, sd = sd)
  parameter[parameter < 0] = 0
  parameter[parameter > 1] = 1
  output[i,] =  simplifiedSim(parameter)
}
par(mfrow=c(2,2))

hist(output[,1])
hist(output[,2])
hist(output[,3])







