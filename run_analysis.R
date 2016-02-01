## well first we need to get the data:
## First created a sub-directory for the files
if(!file.exists("./FinalProject")){dir.create("./FinalProject")}
setwd("~/coursera/Course3/FinalProject")
library(dplyr)
## first download the data (this took awhile to finish)
fileUrl <- ("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip")
download.file(fileUrl, destfile = "zipData.zip")

## Now see what is in the zipped file
FileList <- unzip("zipData.zip", list=TRUE)
FileList

## Based on this we want the 17th and 18th files for the test and 
## the 31st and 32nd files for the train

## Create table with TestX contents in it
TestX <-read.table(unz("zipData.zip", FileList[17,1]))

## Convert table to data frame (and add ColumnNames - couldn't get this done in the same step) 
testingdata<-as.data.frame.matrix(TestX) 

## file number 2 is the features, so we want that as our column labels
ColumnNames<-(read.table(unz("zipData.zip", FileList[2,1])))
colnames(testingdata)<-factor(ColumnNames$V2)

## We need to add a column for the activity being performed
activitylabel<-as.data.frame.matrix(read.table(unz("zipData.zip", FileList[18,1])))
testingdata$activity<-factor(activitylabel$V1)

## We need to add a column for the subject 
subjectlabel<-as.data.frame.matrix(read.table(unz("zipData.zip", FileList[16,1])))
##testingdata$subject<-factor(subjectlabel$V1)
testingdata$subject<-subjectlabel$V1

## Now we want to change the data from factors to words
## This is not graceful, but I cannot find another way
testingdata$activity<-gsub("1","Walking",testingdata$activity)
testingdata$activity<-gsub("2","Walking Upstairs",testingdata$activity)
testingdata$activity<-gsub("3","Walking Downstairs",testingdata$activity)
testingdata$activity<-gsub("4","Sitting",testingdata$activity)
testingdata$activity<-gsub("5","Standing",testingdata$activity)
testingdata$activity<-gsub("6","Laying",testingdata$activity)
#Convert character strings to factor
testingdata$activity<-as.factor(testingdata$activity)

## Now do the same thing for the training data:
TrainX <-read.table(unz("zipData.zip", FileList[31,1]))
trainingdata<-as.data.frame.matrix(TrainX) 
colnames(trainingdata)<-ColumnNames$V2

## add the activity information
activitylabeltraining<-as.data.frame.matrix(read.table(unz("zipData.zip", FileList[32,1])))
trainingdata$activity<-factor(activitylabeltraining$V1)
  
## We need to add a column for the subject 
subjectlabeltraining<-as.data.frame.matrix(read.table(unz("zipData.zip", FileList[30,1])))

##trainingdata$subject<-factor(subjectlabeltraining$V1)
trainingdata$subject<-subjectlabeltraining$V1

## Now we want to change the data from factors to words
## This is not graceful, but I cannot find another way
trainingdata$activity<-gsub("1","Walking",trainingdata$activity)
trainingdata$activity<-gsub("2","Walking Upstairs",trainingdata$activity)
trainingdata$activity<-gsub("3","Walking Downstairs",trainingdata$activity)
trainingdata$activity<-gsub("4","Sitting",trainingdata$activity)
trainingdata$activity<-gsub("5","Standing",trainingdata$activity)
trainingdata$activity<-gsub("6","Laying",trainingdata$activity)
#Convert character strings to factor
trainingdata$activity<-as.factor(trainingdata$activity)

##  When I test to make sure all the column names are the same, I only find 478??? not sure why:
length(intersect(names(testingdata),names(trainingdata)))

alldata<-rbind(trainingdata,testingdata)

##let's try to remove the columns with duplicate headers,w hich seem to relate to non mean and non std stuff
list<-as.numeric(duplicated(names(alldata)))
alldata<-(alldata[,!list])

alldata<-arrange(alldata, subject, activity)
## I would have thought this would work, but it returns an error that operations are possible
## only for numeric, logical or complex types, but they work separately
##  relevantdata<-select(alldata, contains("-mean"|"-std"))
relevantdata<-select(alldata, contains("-mean"))
relevantdata2<-select(alldata, contains("-std"))
relevantdata3<-select(alldata,contains("activity"))
relevantdata4<-select(alldata,contains("subject"))
## so now we bind the results
BigData<-cbind(relevantdata,relevantdata2, relevantdata3, relevantdata4)

#Group data by two factors: Subject and Activity, there are 30x6=180 groups...
#This uses the dplyr library...

groupedData <- group_by(BigData, subject, activity)
meansData <- summarise_each(groupedData, funs(mean))
write.table(meansData, file = "./SubjectActivityMeans.txt", row.names=F)
