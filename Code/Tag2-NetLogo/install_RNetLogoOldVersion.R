# Installs the old RNetLogo version due to outdated R version on the CIP computers

library(devtools)

install.packages("magrittr")
install_url("https://cran.r-project.org/src/contrib/Archive/RNetLogo/RNetLogo_1.0-1.tar.gz", dependencies =T )


