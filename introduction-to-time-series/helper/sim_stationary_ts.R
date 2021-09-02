sim.stationary.example<-function(seed=30,n=1000,random.mean=0,random.sd=1,B=1) {
  data.frame("t"=1:n,
             #nonstationary; differencing
             "X1"=cumsum(rnorm(n,random.mean,random.sd)),
             #nonstationary; detrending
             "X2"=B*(1:n)+rnorm(n,random.mean,random.sd),
             #stationary
             "X3"=rnorm(n,random.mean,random.sd))  
}