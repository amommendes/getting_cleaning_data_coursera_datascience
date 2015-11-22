# Course Project - Getting and Cleaning Data

# Dowloading data from web
temp<- tempfile ()
download.file('https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip', temp)

# Reading files
library (data.table)
library (dplyr)

unzip(temp, exdir = getwd())

## Loading files
fea<-read.table("./UCI HAR Dataset/features.txt", row.names = 1,
                allowEscapes = T
                , colClasses = 'character') # Variable Names


sub_train<-read.table("./UCI HAR Dataset/train/subject_train.txt") # Subject Id
y_train<-read.table("./UCI HAR Dataset/train/y_train.txt") # Activities
x_train<- read.table("./UCI HAR Dataset/train/X_train.txt") # Train Set
x_train<- cbind(sub_train,y_train,x_train)  # Binding Train Data
x_train<- tbl_df(x_train) # tbl class

sub_test<-read.table("./UCI HAR Dataset/test/subject_test.txt") # Subject Id
y_test<-read.table("./UCI HAR Dataset/test/y_test.txt")  # Activities
x_test<- read.table("./UCI HAR Dataset/test/X_test.txt") # Test Set
x_test<- cbind(sub_test,y_test,x_test) # Binding Train Data
x_test<- tbl_df(x_test) # tbl class


# 1.Merges the training and the test sets to create one data set.

dataset<-rbind(x_train, x_test)
dataset<-tbl_df(dataset)
dataset

colnames(dataset)<- c("subject", "activity", paste(fea[[1]]))
names (dataset)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
MeanStdNames<-fea[[1]][grep("mean\\(\\)|std\\(\\)", fea[[1]])]
MeanStdData<-dataset[,c('subject','activity',MeanStdNames)]

# 3. Uses descriptive activity names to name the activities in the data set
act_labels<-read.table("./UCI HAR Dataset/activity_labels.txt", colClasses = c('numeric', 'character'))[,2] # Loading Activity Names

for (i in 1:nrow(dataset)){
    if (dataset$activity[i] == 1){
        dataset$activity[i]<-act_labels[1]
    } else if (dataset$activity[i] == 2){
        dataset$activity[i]<-act_labels[2]
    } else if (dataset$activity[i] == 3){
        dataset$activity[i]<-act_labels[3]
    } else if (dataset$activity[i] == 4){
        dataset$activity[i]<-act_labels[4]
    } else if (dataset$activity[i] == 5){
        dataset$activity[i]<-act_labels[5]
    } else dataset$activity[i]<-act_labels[6]
}

dataset$activity

# 4. Appropriately labels the data set with descriptive variable names. 
names(dataset)<-gsub("^t", "time", names(dataset))
names(dataset)<-gsub("^f", "frequency", names(dataset))
names(dataset)<-gsub("Acc", "Accelerometer", names(dataset))
names(dataset)<-gsub("Gyro", "Gyroscope", names(dataset))
names(dataset)<-gsub("Mag", "Magnitude", names(dataset))
names(dataset)<-gsub("BodyBody", "Body", names(dataset))
names(dataset)

#5. From the data set in step 4, creates a second, independent 
#tidy data set with the average of each variable for each activity and each subject.

tidy<-dataset
tidy<-aggregate(. ~subject + activity, tidy, mean)
write.table(tidy, file = "./tidy_data.txt")

## End
