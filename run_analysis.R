## create ./Project directory if it does not exist
if(!file.exists("./Project")){dir.create("./Project")}

## download the dataset if it has not been downloaded
if(!file.exists("data.zip")){
    fileUrl <- "https://d396qusza40orc.cloudfront.net/
                getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileUrl, destfile = "./data.zip")
}

## unzip the dataset
if(!file.exists("UCI HAR Dataset")){
    unzip(zipfile = "./data.zip", exdir = "./Project")
}

## load activity labels and data
fp <- file.path("./Project", "UCI HAR Dataset")
    ## Activity labels
ActivityTest <- read.table(file.path(fp, "test", "Y_test.txt"), 
                           header = FALSE)
ActivityTrain <- read.table(file.path(fp, "train", "Y_train.txt"), 
                            header = FALSE)
    ## Subject
SubjectTest <- read.table(file.path(fp, "test", "subject_test.txt"), 
                          header = FALSE)
SubjectTrain <- read.table(file.path(fp, "train", 
                                     "subject_train.txt"), 
                           header = FALSE)
    ## Data
DataTest <- read.table(file.path(fp, "test", "X_test.txt"), 
                       header = FALSE)
DataTrain <- read.table(file.path(fp, "train", "X_train.txt"), 
                        header = FALSE)

## load variable names
VNames <- read.table(file.path(fp, "features.txt"), header = FALSE)

## 1. merge the training and test sets
Subjects <- rbind(SubjectTrain, SubjectTest)
Activities <- rbind(ActivityTrain, ActivityTest)
Datas <- rbind(DataTrain, DataTest)
names(Subjects) <- "subject"
names(Activities) <- "activity"
names(Datas) <- VNames$V2
combinedData <- cbind(Subjects, Activities, Datas)


## 2. extract only measurements on the mean and s.d. for each 
## measurements
m_sd <- VNames$V2[grep("[Mm]ean|[Ss]td", VNames$V2)]
select <- c("subject", "activity", as.character(m_sd))
Data <- subset(combinedData, select = select)

## 3. uses descriptive activity names to name the activity in 
## the data set
activityLabels <- read.table(file.path(fp, "activity_labels.txt"), 
                             header = FALSE)
Data$activity <- factor(Data$activity, labels = activityLabels$V2)

## 4. appropriately labels the data set with descriptive variable 
## names
names(Data) <- gsub("^t", "time", names(Data))
names(Data) <- gsub("^f", "frequency", names(Data))
names(Data) <- gsub("Acc", "Accelerometer", names(Data))
names(Data) <- gsub("Gyro", "Gyroscope", names(Data))
names(Data) <- gsub("Mag", "Magnitude", names(Data))
names(Data) <- gsub("BodyBody", "Body", names(Data))

## 5. from the data set in step 4, creates a second, independent 
## tidy data set with the average of each variable for each 
## activity and each subject
tidyData <- aggregate(. ~subject + activity, Data, mean)
tidyData <- tidyData[order(tidyData$subject, tidyData$activity), ]
write.table(Data2, file = "tidydata.txt", row.names = FALSE)