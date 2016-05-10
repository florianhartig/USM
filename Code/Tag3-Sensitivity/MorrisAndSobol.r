rm(list=ls(all=TRUE))

library(sensitivity)


# Test case : the function of Ishigami


# Screening

# morris implements the Morris's elementary effects screening method (Morris 1992). This method, based on design of experiments, allows to identify the few important factors at a cost of r * (p + 1) simulations (where p is the number of factors). This implementation includes some improvements of the original method: space-filling optimization of the design (Campolongo et al. 2007) and simplex-based design (Pujol 2009).


morrisOut <- morris(model = ishigami.fun, factors = 4, r = 10,
            design = list(type = "oat", levels = 10, grid.jump = 5), bsup = 3)
print(morrisOut)
plot(morrisOut)




# sobol implements the Monte Carlo estimation of the Sobol' sensitivity indices. This method allows the estimation of the indices of the variance decomposition, sometimes referred to as functional ANOVA decomposition, up to a given order, at a total cost of (N + 1) * n where N is the number of indices to estimate. This function allows also the estimation of the so-called subset indices, i.e. the first-order indices with respect to single multidimensional inputs.

n <- 1000
X1 <- data.frame(matrix(runif(4 * n, max = 3), nrow = n))
X2 <- data.frame(matrix(runif(4 * n, max = 3), nrow = n))

sobolOut <- sobol(model = ishigami.fun, X1, X2, order = 2, nboot = 100)

print(sobolOut)
plot(sobolOut)


