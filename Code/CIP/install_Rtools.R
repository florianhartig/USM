install.packages("installr")
library(installr)

install.Rtools(choose_version = FALSE, check = TRUE, use_GUI = TRUE,
page_with_download_url = "http://cran.r-project.org/bin/windows/Rtools/")


## make sure you tick the box to change path during the installation