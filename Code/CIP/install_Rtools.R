install.packages("installr")
install.packages("devtools")

install.packages("sensitivity")


library(installr)

# set Rtools 33
install.Rtools(choose_version = FALSE, check = TRUE, GUI = TRUE)

# Weil wir keine admin Rechte haben müssen wir den Pfad mit Hand setzen

Sys.setenv(PATH = paste('c:\\Rtools\\bin;C:\\Rtools\\gcc-4.6.3\\bin;', Sys.getenv("PATH"), sep = ""))

Sys.getenv("PATH")



library(devtools)

install.packages("magrittr")
install_url("https://cran.r-project.org/src/contrib/Archive/RNetLogo/RNetLogo_1.0-1.tar.gz", dependencies =T )



# Für CIP 4 läuft bleibt alles so 
# Für CIP 3 statt des Pfades oben
# 1. Set to 32 bit R in GlobalOptions, R, Rversion
# 2. Restart Rstudio
# Then set the path

newPath = paste('c:\\\\Rtools\\\\bin;C:\\Rtools\\mingw_32\\bin;', Sys.getenv("PATH"), sep = "")
Sys.setenv(PATH=newPath)

# Jetzt die Packages kompilieren

install_url("https://dl.dropboxusercontent.com/s/ccvpnvblf3vzuvs/BayesianTools_0.0.0.9000.tar.gz", dependencies = T)

library(BayesianTools)
?BayesianTools
vignette("AQuickStart", package = "BayesianTools")

install_url("https://dl.dropboxusercontent.com/s/zn64j1tut47v9mj/Rpreles_1.0.tar.gz", dependencies = T)
