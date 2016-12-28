# read the arff files from the cosmic project.
require(dplyr)

data1 <- read.csv("data/cosmic.csv", sep="|")

# FS Function size
# 
data1$totalDefects <- data1$TOT_Defects + data1$TOT_B_Defects + data1$TOT_I_Defects
data1$E_Estimate <- data1$E_Plan + data1$E_Test + data1$E_Design + data1$E_Build + data1$E_Specify + data1$E_Implement

data1Cols <- c("FS",
               "MTS",
               "totalDefects",
               "E_Estimate",
               "N_effort"
)

set1 <- data1[,data1Cols]
set1[is.na(set1$E_Estimate),]$E_Estimate <- 0

data2 <- read.csv("data/isbsg10.arff.csv", sep="|")

# S_Defects, D_Defects, P_Defects, 
# defect attributes TOT_Defects, TOT_B_Defects, TOT_I_Defects

# FS Function size
# 
data2$totalDefects <- data2$TOT_Defects + data2$TOT_B_Defects + data2$TOT_I_Defects
data2Cols <- c("FS",
               "MTS",
               "totalDefects",
               "E_Estimate",
               "N_effort"
               )

set2 <- data2[,data2Cols]

set2[is.na(set2$E_Estimate),]$E_Estimate <- 0
data3 <- read.csv("data/project_tom_data.csv")

# requirementCnt = 1, tcNA = 12, tcFaults=16, tcComponents=13, 
# totalJiraDefects=3, jiraAssigneeCnt=4, jiraComponents=9, teamSize=6, 
# note the estimate is in projBudgetHrs=14
# actual hours is : pmBudgetHrs=18
data3$FS <- data3$requirementCnt
for(i in 1:nrow(data3)) {
  if (data3[i,]$requirementCnt < data3[i,]$tcRun) {
    data3[i,]$FS <- data3[i,]$tcRun
  }
}
data3Cols <- c("FS",
               "teamSize",
               "totalJiraDefects",
               "projBudgetHrs",
               "totalBudgetHrs")
set3 <- data3[,data3Cols]
# the 3 data sets have different attributes.
# we have selected the common attributes to merge togethor
columns <- c("functionPoints", 
             "teamSize",
             "totalDefects",
             "estimatedHrs",
             "recordedHrs"
)
colnames(set1) <- columns
colnames(set2) <- columns
colnames(set3) <- columns
data <- rbind(set1, rbind(set2, set3))
# we want only the complete cases
data <- data[complete.cases(data),]
write.csv(data, "data/merged_data.csv", row.names=FALSE)
# note out of the sample data collected we have only a small number of complete cases.
dim(data)