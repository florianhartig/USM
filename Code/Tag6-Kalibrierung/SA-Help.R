rm(list=ls())
library(Rpreles)
library(sensitivity)

load('Boreal_sites.rdata')
load('par.rdata')
parind <- c(5:11,14:18) #Suggested indexes for PRELES parameters


###########################################
# Define function to run preles

runPreles <- function(parx = NULL, indices = NULL){
  p <- par$def
  p[indices] = parx
  out <- PRELES(PAR=s1$PAR, TAir=s1$TAir, VPD=s1$VPD, Precip=s1$Precip, CO2=s1$CO2, fAPAR=s1$fAPAR, p=p[1:30] )
  return(sum(out$GPP))
}

###########################################
# LOCAL SA



###########################################
# GLOBAL SA

runPrelesM <- function(M){ 
  out <- rep(NA, nrow(M)) 
  for (i in seq(nrow(M))){
    out[i] = runPreles(M[i,], parind)
  }
  return(out)
}

