#use install.packages('packagename') to compile requisite packages

library(astsa)
library(xts)
library(TTR)
library(TSA)
library(aTSA)
library(forecast)

View(jj)

plot(jj, type="o", ylab="Quarterly Earnings per Share", 
     main ='Johnson & Johnson Quarterly Earnings')

'''
note you will get a warning for getYahooData being depreciated in favor
quantmod::getSymbols but pulling from quantmod creates NA
which will cause the difference code below to break. For ease of coding,
we will use getYahooData for now.
'''

djia = getYahooData("^DJI", start=20060420, end=20160420, freq="daily")
djiar = diff(log(djia$Close))[-1] # approximate returns
plot(djiar, main="DJIA Returns", type="n")
lines(djiar)

par(mfrow=c(2,1))
ts.plot(fmri1[,2:5], col=1:4, ylab="BOLD", main="Cortex")
ts.plot(fmri1[,6:9], col=1:4, ylab="BOLD", main="Thalamus & Cerebellum")


#White Noise

#load the robot dataset
data(robot)
#plot the dataset
plot(robot, main = 'Robots Random Distance from Point')


'''
Create a sine wave. Note: these examples are drawn from the 
accompanying text to the tsa library
'''

cs = 2*cos(2*pi*1:500/50 + .6*pi); w = rnorm(500,0,1)
par(mfrow=c(3,1), mar=c(3,2,2,1), cex.main=1.5)
plot.ts(cs, main=expression(2*cos(2*pi*t/50+.6*pi)))

#add Gaussian white noise
plot.ts(cs+w, main=expression(2*cos(2*pi*t/50+.6*pi) + N(0,1)))

#applying the moving average filter

cs_wn = (cs+w)
v = filter(cs_wn, sides=2, filter=rep(1/25,25)) # moving average with rolling window of 25
par(mfrow=c(2,1))
plot.ts(v, main="Moving Average with a Rolling 25 window")

#random walk

w = rnorm(200)
x = cumsum(w)
wd = w +.2
xd = cumsum(wd)
plot.ts(xd, ylim=c(-5,55), main="Random Walk", ylab='')
lines(x, col=4)

#plots for stationary, nonstationary
data(prey.eq)
plot(prey.eq, main='Adjusted Data of Prey dataset from TSA')

plot(rec, main='Fish Population data')

data(airmiles)
plot(airmiles, main = 'Monthly US airlines, 1996-2005')

data(gold)
plot(gold, main='Gold Prices over 252 days in 2005')

#ACF & PACF plot
#build AR model with order 2 (1.5, -.75 as lag coefficients)
ACF = ARMAacf(ar=c(1.5,-.75), ma=0, 24)[-1]
PACF = ARMAacf(ar=c(1.5,-.75), ma=0, 24, pacf=TRUE)

par(mfrow=c(1,2))
plot(ACF, type="h", xlab="lag", ylim=c(-.8,1)); abline(h=0)
plot(PACF, type="h", xlab="lag", ylim=c(-.8,1)); abline(h=0)

#Let's try a full example

#plot the time series
plot(rec)

#evaluate the time series for stationarity using an unit-root test
'''
not covered in slides but we look to reject as the test has a null of
variance is dependent on t
'''

adf.test(rec)

#plot the ACF/PACF, note it will give ACF/PACF values up to lag 48
acf2(rec)

#from the graph we see that AR(2) is a viable model

#subset the data and fit the data without the year into AR2 model
rec_ts = data.frame(rec)[1:441,]
#build the AR(2) model
ar2_mdl = arima(rec_ts,order=c(2,0,0))

#store forecast predictions
ar2_preds = predict(ar2_mdl,n.ahead = 12)$pred

#plot predictions against original data
plot.ts(c(rec),lty=2)
lines(ar2_preds, col=4, lwd=3)