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


