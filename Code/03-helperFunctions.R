# Couple NetLogo Model to R

# load RNetLogo package 
# (if not installed already, execute install.packages("rJava") and install.packages("RNetLogo") )
require(RNetLogo)

# an R random seed (for beeing reproducible)
set.seed(-1556080447)

# the NetLogo installation path (where the NetLogo.jar is located)
nl.path     <- "/Applications/NetLogo 5.0.4"

# the path to the NetLogo model file
model.path  <- "NetLogo/02-SM2_Hoopoes.nlogo"

model = "model1"

# initialize NetLogo
NLStart(nl.path, gui=FALSE, nl.obj=model)
NLLoadModel(model.path,nl.obj=model)

#NLQuit(nl.obj=model, all=FALSE)

# a function to handle a simulation

simulate <- function(param.set, parameter.names, no.repeated.sim = 1, nl.obj, trace.progress = F, iter.length = NULL, function.name = "Model", returnAverage = T) {
  # some security checks
  if (length(param.set) != length(parameter.names))
  { stop("Wrong length of param.set!") }
  if (no.repeated.sim <= 0)
  { stop("Number of repetitions must be > 0!") }
  if (length(parameter.names) <= 0)
  { stop("Length of parameter.names must be > 0!") }

  # an empty list to save the simulation results
  eval.values <- NULL

  # repeated simulations (to control stochasticity)
  for (i in 1:no.repeated.sim)
  {
    # create a random-seed for NetLogo from R, based on min/max of NetLogo's random seed
    # for NetLogo 4:
    #NLCommand("random-seed",runif(1,-9007199254740992,9007199254740992), nl.obj=nl.obj)
    # since NetLogo 5:
    NLCommand("random-seed",runif(1,-2147483648,2147483647), nl.obj=nl.obj)
    
    # TODO: adapt the following to your simulation model
    # This is the stuff for one simulation
    NLCommand("setup", nl.obj=nl.obj)

    # set NetLogo parameters to current parameter values
    lapply(seq(1:length(parameter.names)), function(x) {NLCommand("set ",parameter.names[x], param.set[x], nl.obj=nl.obj)})

    # run simulation
    # TODO: adapt to your simulation process
    # two warm-up years (12 months each)
    NLDoCommand(2,"repeat 12 [go]", nl.obj=nl.obj)
    # here: run 20 x 1 year (=12 months) and get results from month 11 (november) as calibration criterion
    cal.crit <- NLDoReport(20,"repeat 12 [go]",c("year","month-11-count","month-11-alpha"), as.data.frame=T, df.col.names=c("year","abund","alpha"), nl.obj=nl.obj)

    # TODO: adapt to your calibration criteria
    # number of patches (for calculation of percentage)
    patches.count <- NLReport("count patches", nl.obj=nl.obj)

    # calculate calibration criteria
    # mean abundance criterion
    abundance.criterion <- mean(cal.crit$abund)
    # variation criterion
    variation.criterion <- sd(cal.crit$abund)
    # vacancy criterion
    vacancy.criterion <- mean(cal.crit$alpha/patches.count)

    # merge calibration criteria
    calibration.criteria <- c(abundance.criterion,variation.criterion,vacancy.criterion)

    # append to former results
    eval.values <- rbind(eval.values,calibration.criteria)
  }
  
  colnames(eval.values) = c("Abundance", "AbundanceSD", "Vacancies")
  rownames(eval.values) = as.character(1:no.repeated.sim)

  # print the progress if requested
  if (trace.progress == TRUE)
  {
    already.processed <- get("already.processed",env=globalenv()) + 1
    assign("already.processed", already.processed, env=globalenv())
    print(paste("processed (",function.name,"): ", already.processed / iter.length * 100, "%", sep = ""))
  }

  # return the mean of the repeated simulation results
  if (no.repeated.sim > 1)
  {
    if (returnAverage == T) return(colMeans(eval.values))
    else return(eval.values)
  }
  else {
    return(eval.values)
  }
}
