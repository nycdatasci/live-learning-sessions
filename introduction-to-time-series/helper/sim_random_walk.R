# function to similate random walk
sim.random.walk<-function(seed=30,n=1000,random.mean=0,random.sd=1) {data.frame("t"=1:n,"X"=cumsum(rnorm(n,random.mean,random.sd)))}
