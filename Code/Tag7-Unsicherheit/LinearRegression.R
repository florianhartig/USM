trueA <- 5
trueB <- 0
trueSd <- 10
sampleSize <- 31


x <- runif(31, -10,10)
y <-  trueA * x + trueB + rnorm(n=sampleSize,mean=0,sd=trueSd)
plot(x,y)


# par = 1) slope, 2) intercept, 3) sd

likelihood<- function(par){
  pred = par[1] * x + par[2]
  LL = sum(dnorm(y, pred, sd = par[3], log = T))
  return(LL)
}


posterior <- function(par){
  prior <- sum(dunif(par, c(-10,-10,0), c(10,10,30) , log = T))
  if (prior == -Inf) return(prior)
  else return(prior + likelihood(par))
}



run_metropolis_MCMC <- function(startvalue, iterations){
  chain = array(dim = c(iterations+1,3))
  chain[1,] = startvalue
  for (i in 1:iterations){
    proposal = rnorm(3,mean = chain[i,], sd= c(0.1,0.5,0.3))
    
    probab = exp(posterior(proposal) - posterior(chain[i,]))
    if (runif(1) < probab){
      chain[i+1,] = proposal
    }else{
      chain[i+1,] = chain[i,]
    }
  }
  return(chain)
}



startvalue = c(4,0,10)
chain = run_metropolis_MCMC(startvalue, 10000)
chain = chain[3000:10000, ] # burnin weg

plot(mcmc(chain))
summary(mcmc(chain))

lm(y ~ x)



