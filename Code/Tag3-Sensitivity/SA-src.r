rm(list=ls(all=TRUE))

library(sensitivity)


# random sample of parameters
n <- 100
X <- data.frame(X1 = runif(n),X2 = runif(n),X3 = runif(n))


# calculate linear model
y <- with(X, 0.1 * X1 + 3 * X2 + 1 * X3)

# src computes the Standardized Regression Coefficients (SRC), or the Standardized Rank Regression Coefficients (SRRC), which are sensitivity indices based on linear or monotonic assumptions in the case of independent factors.

x1 <- src(X, y, nboot = 100, rank = F)
print(x1)
plot(x1)

x2 <- src(X, y, nboot = 100, rank = T)
print(x2)
plot(x2)

