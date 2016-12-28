require(corrplot)

# data from the test objective matrix collected by hand.
file <- "data/project_tom_data.csv"
data <- read.csv(file, header=TRUE) 

# anonymise the project names

plot(data$totalJiraDefects~data$pmBudgetHrs)

plot(data$totalJiraDefects~data$tmCardHrs)

plot(data$teamSize~data$tmCardHrs)

plot(data$requirementCnt~data$tmCardHrs)

nums <- data.frame(requirementCnt=data$requirementCnt,
                   tcRun=data$tcRun,
                   totalJiraDefects=data$totalJiraDefects,
                   jiraAssigneeCnt=data$jiraAssigneeCnt,
                   projHrsDelta=data$projHrsDelta,
                   teamSize=data$teamSize,
                   tcCount=data$tcCount,
                   totalJiraClosed=data$totalJiraClosed,
                   jiraComponents=data$jiraComponents,
                   totalBudgetHrs=data$totalBudgetHrs,
                   tmCardHrs=data$tmCardHrs,
                   tcNA=data$tcNA,
                   tcComponents=data$tcComponents,
                   projBudgetHrs=data$projBudgetHrs,
                   totalHrsUsed=data$totalHrsUsed,
                   tcFaults=data$tcFaults,
                   totalJiraNonIssue=data$totalJiraNonIssue,
                   pmBudgetHrs=data$pmBudgetHrs,
                   totalhrsDelta=data$totalhrsDelta)

C <- cor(nums)
corrplot(C)

d <- density(data$teamSize)
plot(d)

d2 <- density(data$projBudgetHrs)
plot(d2)

d3 <- density(data$tmCardHrs)
plot(d3)
lines(d2, col="red")
d3