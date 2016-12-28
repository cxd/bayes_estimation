source("multiplot.R")
source("bayes_linear_regression.R")
## this script is used to configure and traing the list model.
## the server can then use the list model
## to change the estimated data execute the setup_and_train 

file <- "data/merged_data.csv"
data <- read.csv(file, header=TRUE) 

names(data)

## Note the data available has limited attributes available to work with for complete cases
## we will use the target variable as column 5
## columns 1:4 will be the predictors
xcols <- 1:4
# pmBudgetHrs=18
ycol <- c(5)

model <- bayes_least_squares_uninform_prior(data, xcols, ycol, zscale=TRUE)

saveRDS(model, "data/model.rds")