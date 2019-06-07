### This script parses the data from
# http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

# fetch the zip file from internet and extract content (if needed)
destZipFile <- './FUCI.ZIP'
fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if(!file.exists(destZipFile)) {
    download.file(fileUrl, destfile = destZipFile, method = "curl")
}
if(!dir.exists('./UCI HAR Dataset')) unzip(destZipFile)

# install a loads needed libraries
install.packages(c("dplyr","tidyr"))
library(dplyr)
library(tidyr)

readUCI <- function(f, ...) {
    read.csv(paste0('./UCI HAR Dataset/',f), header=FALSE, sep = '', ...)
}

## 0. Reads features list first
allfeatures <- readUCI('features.txt', col.names = c("pos", "name"))
features <- allfeatures %>% 
    # only the measurements on the mean and standard deviation
    filter(grepl("-mean\\(|-std\\(", name)) %>%
    # appropriately labels the data set with descriptive variable names
    mutate(cleanname = gsub("-mean\\(\\)","Mean",name)) %>%
    mutate(cleanname = gsub("^f","freq",cleanname)) %>%
    mutate(cleanname = gsub("^t","time",cleanname)) %>%
    mutate(cleanname = gsub("-std\\(\\)","Std",cleanname)) %>%
    mutate(cleanname = gsub("-|\\(|\\)","",cleanname))
features

# merges the training and the test sets to create one data set
train <- readUCI('train/X_train.txt')
train_y <- readUCI('train/y_train.txt')
train_subject <- readUCI('train/subject_train.txt')

test <- readUCI('test/X_test.txt')
test_y <- readUCI('test/y_test.txt')
test_subject <- readUCI('test/subject_test.txt')

# bind and filter columns on the mean and standard deviation with [,feature$pos]
all <- bind_rows(
    bind_cols(train[,features$pos], train_y, train_subject),
    bind_cols( test[,features$pos],  test_y,  test_subject)
)

# renames all columns
names(all) <- c(features$cleanname, "activity", "subject")
as_tibble(all)

# creates a second, independent tidy data set with the average 
# of each variable for each activity and each subject
tidydata <- all %>% 
    gather(key="measure", value='value', -activity, -subject) %>%
    group_by( activity, subject, measure ) %>%
    summarize(avg = mean(value))

write.table(tidydata, "tidydata.txt", row.name=FALSE)
tidydata
