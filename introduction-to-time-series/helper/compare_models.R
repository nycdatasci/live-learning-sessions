# function to compare linear regression to basic time series model
compare.models<-function(seed=30,n=100,train.fraction=0.8,random.mean=0,random.sd=0.1,B=1) {
  # simulate a sample time series model
  dat<-data.frame("t"=1:n,"X"=NA,"X.lag"=NA,"e"=rnorm(n=n,mean=random.mean,sd=random.sd))
  dat$X.lag<-lag(dat$e,1); dat$X<-B*coalesce(dat$X.lag,0)+dat$e; dat$X[dat$t>train.fraction*n]<-NA
  
  # fit regular linear regression and a simple AR(1) time series model
  pred.lm<-predict(lm(X~X.lag,data=dat[dat$t<=train.fraction*n,]),newdata=dat[dat$t>train.fraction*n,],interval="prediction",level=0.95)
  pred.ts<-predict(arima(dat$X[dat$t<=train.fraction*n],order=c(0,1,0)),n.ahead=n-train.fraction*n,se.fit=T)
  
  # store future forecasts for plotting
  dat$X.lm[dat$t>train.fraction*n]<-pred.lm[,1]
  dat$X.lm.lwr[dat$t>train.fraction*n]<-pred.lm[,2]
  dat$X.lm.upr[dat$t>train.fraction*n]<-pred.lm[,3]
  dat$X.ts[dat$t>train.fraction*n]<-pred.ts$pred
  dat$X.ts.lwr[dat$t>train.fraction*n]<-pred.ts$pred-qnorm(0.975)*pred.ts$se
  dat$X.ts.upr[dat$t>train.fraction*n]<-pred.ts$pred+qnorm(0.975)*pred.ts$se
  
  # plot comparison of models
  g1<-dat %>%
    ggplot(aes(t,coalesce(X,X.lm),color=t>=train.fraction*n)) +
    geom_ribbon(aes(ymin=coalesce(X,X.lm.lwr),ymax=coalesce(X,X.lm.upr),alpha=0.1),fill="orange2") +
    geom_line() +
    scale_color_economist() +
    theme(legend.position="none") +
    xlab("T") +
    ylab("X") +
    ggtitle("Linear Regression Forecast")
  g2<-dat %>%
    ggplot(aes(t,coalesce(X,X.ts),color=t>=train.fraction*n)) +
    geom_ribbon(aes(ymin=coalesce(X,X.ts.lwr),ymax=coalesce(X,X.ts.upr),alpha=0.1),fill="orange2") +
    geom_line() +
    scale_color_economist() +
    theme(legend.position="none") +
    xlab("T") +
    ylab("X") +
    ggtitle("Time Series Forecast")
  grid.arrange(g1,g2,ncol=1,nrow=2)
}