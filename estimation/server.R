
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)
require(ggplot2)

source("multiplot.R")
source("bayes_linear_regression.R")

model <- readRDS("../data/model.rds")


shinyServer(function(input, output) {
   
  
  makeData <- function(input) {
    X <- data.frame(
      functionPoints=input$requirementCnt,
      teamSize=input$teamSize,
      totalDefects=input$requirementCnt*input$defectRatio,
      estimateHrs=input$estimateHrs
    )
    as.matrix(rbind(X,X))
  }
  
  
  
  output$distPlot <- renderPlot({
    X <- makeData(input)
    ## investigate the prediction
    Ypred1 <- model$yPredictivePosteriorSimulate(model,X,1000)
    Y <- Ypred1*model$yscale + model$ycenter
    options(scipen=5)
    # draw the histogram with the specified number of bins
    hist(Y[Y>0], main="Estimate Hours", xlab="Hours", breaks=25)
  })
  
  output$summary <- renderTable({
    X <- makeData(input)
    ## investigate the prediction
    Ypred1 <- model$yPredictivePosteriorSimulate(model,X,1000)
    Y <- Ypred1*model$yscale + model$ycenter
    options(scipen=5)
    estimatedHrs <- Y[Y>0]
    summary(data.frame(estimatedHrs)[1])
  })
  
  output$projection <- renderPlot({
    X <- makeData(input)
    ## investigate the prediction
    Ypred1 <- model$yPredictivePosteriorSimulate(model,X,1000)
    Y <- Ypred1*model$yscale + model$ycenter
    options(scipen=5)
    Y <- Y[,1]
    data <- data.frame(Y[Y>0])
    colnames(data) <- c("estimatedHrs")
    data$simulation <- 1:length(data$estimatedHrs)
    
    cols2 <- c("#FF00FF")
    labels2 <- c("simulated")
    
    ggplot(data, aes(x=simulation)) +
      geom_point(aes(y=estimatedHrs, col="simulated"), shape=1) +
      scale_colour_manual(values=cols2, labels=labels2) +
      ggtitle("Simulated hours")
  })
  
})
