require(corrplot)
require(plyr)
require(ggplot2)
require(reshape2)
require("gpairs")
require("GGally")

source("multiplot.R")
source("bayes_linear_regression.R")


file <- "data/merged_data.csv"
data <- read.csv(file, header=TRUE) 

names(data)
## columns 1:4 will be the predictors
xcols <- 1:4
# pmBudgetHrs=18
ycol <- c(5)


plotScatter <- function(data, cols, targetCol) {
  old.par <- par(mfrow=c(2,5))
  names <- colnames(data)
  targetName<- names[targetCol]
  
  for(i in cols) {
    name <- names[i]
    plot(data[,targetCol]~data[,i], ylab=targetName, xlab=name)
  }
  par(old.par)
}
plotScatter(data, xcols, ycol[1])

test <- bayes_least_squares_uninform_prior(data, xcols, ycol, zscale=TRUE)


ggplot(data, aes(x=recordedHrs)) +
  geom_histogram(aes(binwidth=100), colour="black", fill="lightblue") +
  ggtitle("Recorded Hours")


dim(test$Y)

temp <- data[,c(xcols,ycol)]
C <- cor(temp)
corrplot(C, type="lower",diag=FALSE)

X1 <- data[,xcols]
Y1 <- data[,ycol]

## the model is built now estimate the HPD
rBeta1 <- test$randBetaPosterior(test, test$sSqr, 100)
d2 <- test$betaConfData(test, test$sSqr,100, names= c("B1", "B2", "B3", "B4", "prob"))
ggpairs(data=d2[,1:5],
        upper=list(continuous="density"),
        title="Beta Density 100 Simulations")

# 95%
betaConf1 <- test$betaConfInterval(test, test$sSqr,0.05)
x0 <- betaConf1$beta[1,1]
y0 <- betaConf1$beta[2,1]
delta <- betaConf1$upperQuartile - betaConf1$lowerQuartile
theta <- seq(0,2*pi,length=100)
x <- x0 + delta*cos(theta)
y <- y0 + delta*sin(theta)

# 90%
betaConf2 <- test$betaConfInterval(test, test$sSqr,0.1)
delta2 <- betaConf2$upperQuartile - betaConf2$lowerQuartile
x2 <- x0 + delta2*cos(theta)
y2 <- y0 + delta2*sin(theta)

#75%
betaConf3 <- test$betaConfInterval(test, test$sSqr,0.25)
delta3 <- betaConf3$upperQuartile - betaConf3$lowerQuartile
x3 <- x0 + delta3*cos(theta)
y3 <- y0 + delta3*sin(theta)

hpd <- data.frame(x95=x,y95=y,x90=x2,y90=y2,x75=x3,y75=y3)

ggplot(hpd) +
  geom_point(aes(x=x95,y=y95), col="purple") +
  geom_point(aes(x=x90,y=y90), col="blue") +
  geom_point(aes(x=x75,y=y75), col="black") 

## approximate hpd
old.par <- par(mfrow=c(2,2))
options(scipen=5)
plot(x3,y3,type="l", main="hpd beta1,beta2 at 75%,90% and 95%", xlab="beta1", ylab="beta2")
n <- ncol(rBeta1)
m <- n-1
points(rBeta1[,2]~rBeta1[,1], col="lightblue")
lines(x3,y3)
lines(x2,y2,col="blue")
lines(x,y,col="red")
## scaling up confidence level to Y
Ylower <- test$X%*%betaConf1$betaL
Ylower <- Ylower*test$yscale + test$ycenter

Yupper <- test$X%*%betaConf1$betaU
Yupper <- Yupper*test$yscale + test$ycenter
Ymean <- test$X%*%betaConf1$beta
Ymean <- Ymean*test$yscale + test$ycenter

hist(Ylower, breaks=20, main="histrogram of 95% lower credible interval for Y|X")
hist(Yupper, breaks=20, main="histogram of 95% upper credible interval for Y|X")

plot(Ymean, type="l")
lines(Yupper, col="red")
lines(Ylower, col="blue")

par(old.par)



c <- test$yPredictiveConfidence(test, test$X, 0.05)

confData <- data.frame(c)
confData$x <- c(1:nrow(confData))

confDataA <- confData
CA1 <- ggplot(confDataA, aes(x=data$functionPoints)) +
  geom_line(aes(y=upper), colour="red") + 
  geom_line(aes(y=mean)) + 
  geom_line(aes(y=lower), colour="red") + 
  ylab("pmBudgetHrs") +
  ggtitle("Standardised 95% credible interval for Budget Hours")

CA6 <- ggplot(confDataA, aes(x=data$functionPoints)) +
  geom_line(aes(y=unscaledUpper), colour="red") + 
  geom_line(aes(y=unscaledMean)) + 
  geom_line(aes(y=unscaledLower), colour="red") +
  ylab("Hours") +
  ggtitle("95% credible interval for mean Budget Hours")

multiplot(CA1,CA6, cols=2)

## investigate the prediction
Ypred <- test$predictY(test, X1)
Ypred1 <- test$yPredictivePosteriorSimulate(test,X1,1000)
Ys <- (Y1 - test$ycenter)/test$yscale


residual <- Ypred - Ys
residual1 <- Ypred1 - Ys 
mse <- sapply(1:nrow(Ypred1), function(i) { sum((Ypred1[i,] - Ys)^2 / nrow(X1)) })

mseData <- data.frame(MSE=mse,simulation=1:nrow(Ypred1))

mseAPlot <- ggplot(mseData, aes(x=simulation)) +
  geom_point(aes(y=MSE)) +
  ggtitle("MSE of 100 simulations for with new data")


multiplot(mseAPlot)

mseA <- mse
summary(mse)


minIdx <- which(mse %in% min(mse))

YpredScaled <- Ypred*test$yscale + test$ycenter
Ypred1Scaled <- (Ypred1[minIdx,]*test$yscale) + test$ycenter
residualScaled <- residual1[minIdx,]*test$yscale + test$ycenter
stdResidualScaled <- residual*test$yscale + test$ycenter

plotData <- data.frame(requirementCnt=data$functionPoints, 
                       stdResidual=residual,
                       stdResidualScaled=stdResidualScaled,
                       residuals=residual1[minIdx,],
                       residualScaled=residualScaled,
                       predictedWaitTime=YpredScaled,
                       simulatedWaitTime=Ypred1Scaled,
                       actualHours=Y1)

t <- (residual1^2)/ncol(residual)
simMse1 <-sum(t)/(nrow(t)*ncol(t))

t1 <- residual1*test$yscale + test$ycenter
t <- (t1^2)/ncol(residual)
simMseScaled1 <-sum(t)/(nrow(t)*ncol(t))

t <- (residual^2)/nrow(residual)
predMse1 <- sum(t)/(nrow(t)*ncol(t))
t1 <- residual*test$yscale + test$ycenter
t <- (t1^2)/nrow(residual)
predMseScaled1 <-sum(t)/(nrow(t)*ncol(t))


## plot the residuals
p1 <- ggplot(plotData, aes(x=actualHours)) +
  geom_point(aes(y=residuals)) +
  ggtitle("Standardised residuals of minimum MSE estimate")

p2 <- ggplot(plotData, aes(x=residuals)) +
  geom_histogram(color="black", fill="lightblue") + 
  ggtitle("Histogram of standardised residuals for minimum MSE estimate")

p3 <- ggplot(plotData, aes(x=actualHours)) +
  geom_point(aes(y=residualScaled)) +
  ggtitle("residuals of minimum MSE estimate")

p4 <- ggplot(plotData, aes(x=residualScaled)) +
  geom_histogram(color="black", fill="lightblue") + 
  ggtitle("Histogram of residuals for minimum MSE estimate")

multiplot(p1,p2,p3,p4,cols=2)

# prediction residuals

p1 <- ggplot(plotData, aes(x=actualHours)) +
  geom_point(aes(y=stdResidual)) +
  ggtitle("Standardised residuals of minimum MSE estimate")

p2 <- ggplot(plotData, aes(x=stdResidual)) +
  geom_histogram(color="black", fill="lightblue") + 
  ggtitle("Histogram of standardised residuals for minimum MSE estimate")

p3 <- ggplot(plotData, aes(x=actualHours)) +
  geom_point(aes(y=stdResidualScaled)) +
  ggtitle("residuals of minimum MSE estimate")

p4 <- ggplot(plotData, aes(x=stdResidualScaled)) +
  geom_histogram(color="black", fill="lightblue") + 
  ggtitle("Histogram of residuals for minimum MSE estimate")
multiplot(p1,p2,p3,p4, cols=2)


## plot the prediction

cols <- c("#000000", "#FF0000")
labels <- c("actual", "predicted")

cols2 <- c("#000000", "#FF00FF")
labels2 <- c("actual", "simulated")


pA1 <- ggplot(plotData, aes(x=requirementCnt)) +
  geom_point(aes(y=actualHours, col="actual")) +
  geom_point(aes(y=predictedWaitTime, col="predicted"), shape=1) +
  scale_colour_manual(values=cols, labels=labels) +
  ggtitle("Original Data predicted hours on actual hours")

pA2 <- ggplot(plotData, aes(x=requirementCnt)) +
  geom_point(aes(y=actualHours, col="actual")) +
  geom_point(aes(y=simulatedWaitTime, col="simulated"), shape=1) +
  scale_colour_manual(values=cols2, labels=labels2) +
  ggtitle("Simulated hours on actual hours")

multiplot(pA1,pA2)
