###########################################
# Optimization 


rm(list=ls())
library(Rpreles)
library(DEoptim)

load('Boreal_sites.rdata')
load('par.rdata')
parind <- c(5:11,14:18) #Suggested indexes for PRELES parameters


runPreles <- function(parx = NULL, indices = NULL){
  p <- par$def
  p[indices] = parx
  out <- PRELES(PAR=s1$PAR, TAir=s1$TAir, VPD=s1$VPD, Precip=s1$Precip, CO2=s1$CO2, fAPAR=s1$fAPAR, p=p[1:30] )
  return(out)
}

# Wie gut fitted das Modell zu den Daten?

NLL <- function(parx){
  out <- runPreles(parx, parind)
  NlogLik = sum(dnorm(s1$GPPobs , mean = out$GPP, sd = 1, log = T)) # entspricht sum((s1$GPPobs - out$GPP)^2) - später eventuell auch SD mitoptimieren
  return(-NlogLik)
}


NLL(par$min[parind])
NLL(par$def[parind])

bestParameter <- optim(par$min[parind], NLL)
bestParameter$value

# Besser als der Anfang, aber hat das Optimum nicht gefunden
# Trotzdem plotten wir mal die Residuen

par(mfrow=c(1,2),oma=c(0,0,2,0))

preles_s1 <- runPreles(par$min[parind], parind)
barplot(preles_s1$GPP - s1$GPPobs, main = "Residuen vorher",ylim = c(-8,5))

preles_s1 <- runPreles(bestParameter$value, parind)
barplot(preles_s1$GPP - s1$GPPobs, main = "Residuen nachher",ylim = c(-8,5))


# OK, wir müssen also schwerere Geschütze auffahren

library(DEoptim)

out<- DEoptim(NLL, lower = par$min[parind], upper =  par$max[parind])

out$optim$bestmem

# Vergleich 

NLL(par$min[parind]) # startwerte
NLL(par$def[parind]) # unsere default werte 
out$optim$bestval # bester Wert

par(mfrow=c(1,2),oma=c(0,0,2,0))

preles_s1 <- runPreles(par$min[parind], parind)
barplot(preles_s1$GPP - s1$GPPobs, main = "Residuen vorher",ylim = c(-8,5))

preles_s1 <- runPreles(out$optim$bestmem, parind)
barplot(preles_s1$GPP - s1$GPPobs, main = "Residuen nachher",ylim = c(-8,5))



# TODO

# 1) Ansatz durchgehen und verstehen

# 2) Modifiziert die Likelihood funktion so dass sie GPP und EP sinnvoll einbezieht. Zu berücksichtigen a) sind beide outputs auf der gleichen Skala? b) Haben beide die gleiche Varianz? Entweder ihr müsst die Standardabweichung der Normalverteilung mit Hand anpassen, oder besser - ihr fittet für jeden Output eine Standardabweichung mit!






