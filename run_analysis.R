## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

library(dplyr)

if (!require("data.table")) 
   {
    install.packages("data.table")
   }

if (!require("reshape2")) 
   {
    install.packages("reshape2")
   }

## Download dataset
if (!file.exists("./data"))
   {
    dir.create("./data")
   }
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile="./data/Dataset.zip", method="curl")

## Unzip dataset
unzip(zipfile="./data/Dataset.zip",exdir="./data")

## Read training data
x_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

## Read test data
x_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

## Read feature table
features <- read.table('./data/UCI HAR Dataset/features.txt')

## Read activity labels:
activityLabels = read.table('./data/UCI HAR Dataset/activity_labels.txt')

## Assign column names
colnames(x_train) <- features[,2] 
colnames(y_train) <-"activityId"
colnames(subject_train) <- "subjectId"
      
colnames(x_test) <- features[,2] 
colnames(y_test) <- "activityId"
colnames(subject_test) <- "subjectId"
      
colnames(activityLabels) <- c('activityId','activityType')

## Merge all data in one set
mrg_train <- cbind(y_train, subject_train, x_train)
mrg_test <- cbind(y_test, subject_test, x_test)
setAllInOne <- rbind(mrg_train, mrg_test)

## Read column names
colNames <- colnames(setAllInOne)

## Create vector for defining ID, mean and standard deviation
mean_and_std <- (grepl("activityId", colNames) | grepl("subjectId", colNames) | grepl("mean..", colNames) | grepl("std..", colNames))

## Make subset from setAllInOne
setForMeanAndStd <- setAllInOne[ , mean_and_std == TRUE]

setWithActivityNames <- merge(setForMeanAndStd, activityLabels, by='activityId', all.x=TRUE)

## Make second tidy data set
secTidySet <- aggregate(. ~subjectId + activityId, setWithActivityNames, mean)
secTidySet <- secTidySet[order(secTidySet$subjectId, secTidySet$activityId),]

## Write second tidy data set in txt file
write.table(secTidySet, "secTidySet.txt", row.name=FALSE)
