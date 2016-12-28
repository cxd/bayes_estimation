
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)
source("bayes_linear_regression.R")

model <- readRDS("../data/model.rds")

req <- mean(model$X[,1])
req <- round(req*model$xscale[1] + model$xcenter[1])
team <- mean(model$X[,2])
team <- round(team*model$xscale[2] + model$xcenter[2])
defects <- mean(model$X[,3])
defects <- round(defects*model$xscale[3] + model$xcenter[3])
hrs <- mean(model$X[,4])
hrs <- round(hrs*model$xscale[4] + model$xcenter[4])
defectRatio <- round(defects/req, 1)

shinyUI(fluidPage(
  titlePanel("Software Estimate"),
  
  fluidRow(column(8,
    p("Enter the estimated properties for the project")
    )),
  
  fluidRow(
    column(4,
           numericInput("requirementCnt",
                        label=h3("Function Point Count"),
                        value=req)
           ),
    column(4,
           numericInput("teamSize",
                        label=h3("Full Team Size (PM, Design, Dev, Test & CE)"),
                        value=team))
    
    ),
  
  fluidRow(
    column(4,
           numericInput("defectRatio",
                        label=h3("Estimated Defect Ratio to Function point count"),
                        value=defectRatio), min=0, max=1.0),
    column(4,
           numericInput("estimateHrs",
                        label=h3("Initial Estimate of Hrs"),
                        value=hrs))
  ),
  
  fluidRow(
    column(4,
           submitButton(text="Estimate"))
  ),
  
  fluidRow(
    column(8,
           plotOutput("distPlot")),
    column(3,
           tableOutput("summary"))
  ),
  
  fluidRow(
    column(8,
           plotOutput("projection"))
  )
  
  
))
