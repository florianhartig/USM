
### NUR LAUFEN LASSEN WENN RTools noch nicht installiert ist, Linux / Mac Nutzer müssen nichts machen ###

install.packages("installr")
install.packages("devtools")

library(installr)

# CIP Pools set Rtools 33, eigene Rechner kommt auf die R version an. 
install.Rtools(choose_version = FALSE, check = TRUE, GUI = TRUE)


### Pfad setzen ###


# Für Leute mit eigenem Rechner solltet ihr jetzt gar nichts machen müssen, weiter zu packages installieren

# Für CIP 4 machen wir jetzt 
Sys.setenv(PATH = paste('c:\\Rtools\\bin;C:\\Rtools\\gcc-4.6.3\\bin;', Sys.getenv("PATH"), sep = ""))


# Für CIP 3 
# 1. Set to 32 bit R in Tools -> GlobalOptions ->  R -> Rversion
# 2. Restart Rstudio
# Dann geht es weiter mit

newPath = paste('c:\\\\Rtools\\\\bin;C:\\Rtools\\mingw_32\\bin;', Sys.getenv("PATH"), sep = "")
Sys.setenv(PATH=newPath)

# Jetzt die Packages kompilieren

library(devtools)
install_url("https://dl.dropboxusercontent.com/s/ccvpnvblf3vzuvs/BayesianTools_0.0.0.9000.tar.gz", dependencies = T)

library(BayesianTools)
?BayesianTools

# Beispiel VSEM Modell -> siehe auch ?VSEM

# Create radiation data
PAR <- VSEMcreatePAR(1:1000)
plotTimeSeries(observed = PAR)

# Model reference parameters
refPars <- VSEMgetDefaults()
refPars

# Create prediction
prediction <- VSEM(refPars$best, PAR) 
oldpar <- par(mfrow = c(2,2))
for (i in 1:4) plotTimeSeries(predicted = prediction[,i], main = colnames(prediction)[i])
par(oldpar)

# Weitere Beispiele siehe Skript
