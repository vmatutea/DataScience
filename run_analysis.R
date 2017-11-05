installed.packages("reshape2")
installed.packages("openxlsx")
library(reshape2)
library(openxlsx)

# 1.Merges the training and the test sets to create one data set.

filename <- "get_dataset.zip"

if (!file.exists(filename)){
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
    download.file(fileURL, filename, method="curl")
} 

if (!file.exists("UCI HAR Dataset")) { 
    unzip(filename)
}

activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")

train_subject <- read.table("./UCI HAR Dataset/train/subject_train.txt")
test_subject <- read.table("./UCI HAR Dataset/test/subject_test.txt")

train_X <- read.table("./UCI HAR Dataset/train/X_train.txt")
test_X <- read.table("./UCI HAR Dataset/test/X_test.txt")


train_y <- read.table("./UCI HAR Dataset/train/y_train.txt")
test_y <- read.table("./UCI HAR Dataset/test/y_test.txt")

data_x <- rbind(train_X,test_X)

# 2.Extracts only the measurements on the mean and standard deviation for each measurement.

features <- read.table("./UCI HAR Dataset/features.txt")
col_meanStd <- features$V1[grep("mean()|std()",features$V2)]

data_x_meanStd <- data_x [,col_meanStd]

# 3.Uses descriptive activity names to name the activities in the data set

data_y <- rbind(train_y,test_y)
fdata_y<- factor(unlist(data_y))
Actdata <- factor(fdata_y, levels = activity_labels[,1], labels = activity_labels[,2])

data_all <- cbind(data_x_meanStd,Actdata)

# 4.Appropriately labels the data set with descriptive variable names.

col_names <- features$V2[grep("mean()|std()",features$V2)]
col_names <- as.character(col_names)
colnames(data_all)<-c(col_names,"activity")

write.xlsx(data_all, 'activity_data.xlsx')

# 5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

data_subject <- rbind(train_subject,test_subject)
data_sub <- cbind(data_all,data_subject)
colnames(data_sub)<-c(colnames(data_all),"subject")

mdata <- melt(data_sub, id=c("activity","subject"))
mdata_mean <- dcast (mdata, activity + subject ~ variable, mean)

write.xlsx(mdata_mean, 'tidy_data.xlsx')
