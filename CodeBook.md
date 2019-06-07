# CodeBook

The script run_analysis.R parses the data from

> http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

and performs initial data preparation and the 5 steps required.

The following a a brief description of the operations:

1. fetch the zip file from internet and extract content (if needed)
2. install a loads needed libraries "dplyr","tidyr", ...

# Cleaning and binding all
1. Reads the features.txt list first, and changes feature names to improve the readability of the final data frame. 
```r   
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
```
NOTE that in this step we also filter for mean and standard deviation using
```r
# only the measurements on the mean and standard deviation
... filter(grepl("-mean\\(|-std\\(", name)) ...

```

2. loads the training and the test sets, and the subjects
```r
train <- readUCI('train/X_train.txt')
train_y <- readUCI('train/y_train.txt')
train_subject <- readUCI('train/subject_train.txt')

test <- readUCI('test/X_test.txt')
test_y <- readUCI('test/y_test.txt')
test_subject <- readUCI('test/subject_test.txt')
```

3. bind and filter columns using the features (already filtered on the mean and standard deviation with [,feature$pos])
```r
all <- bind_rows(
    bind_cols(train[,features$pos], train_y, train_subject),
    bind_cols( test[,features$pos],  test_y,  test_subject)
)
```

4. renames all columns
```r
names(all) <- c(features$cleanname, "activity", "subject")
```

The output of the binded dataset will be in the variable "all".

# Creating the tidy data set
Now let's create a second, independent TIDY data set with the average of each variable for each activity and each subject. 

Definition of tidy:
1. Each variable you measure should be in one column.
2. Each different observation of that variable should be in a different row.
3. There should be one table for each "kind" of variable.
4. If you have multiple tables, they should include a column in the table that allows them to be linked.

So we have this table:
```
   activity subject timeBodyAccMeanZ timeBodyAccStdY timeBodyAccStdZ ...
      <int>   <int>            <dbl>           <dbl>           <dbl>
 1        5       1           -0.133          -0.983          -0.914
 2        5       1           -0.124          -0.975          -0.960
 3        5       1           -0.113          -0.967          -0.979
 ```

and first we use gather() change the multiple columns into 1 called _measure_ and his value is stored in _value_.
The next step is to group and calculate the mean for that group.
```r
tidydata <- all %>% 
    gather(key="measure", value='value', -activity, -subject) %>%
    group_by( activity, subject, measure ) %>%
    summarize(avg = mean(value))
```
Resulting in a tidy data set with the average of each variable for each activity and each subject:
```
      activity subject     measure         avg
        <int>  <int>        <chr>         <dbl>
 1        1       1 freqBodyAccJerkMeanX -0.171 
 2        1       1 freqBodyAccJerkMeanY -0.0352
 3        1       1 freqBodyAccJerkMeanZ -0.469 
 4        1       1 freqBodyAccJerkStdX  -0.134 
 5        1       1 freqBodyAccJerkStdY   0.107 
 6        1       1 freqBodyAccJerkStdZ  -0.535 
 7        1       1 freqBodyAccMagMean   -0.129 
 8        1       1 freqBodyAccMagStd    -0.398 
 9        1       1 freqBodyAccMeanX     -0.203
 ``` 
Finally we write tidydata.txt to disk
```r
write.table(tidydata, "tidydata.txt", row.name=FALSE)
```

I hope this is clear enough. If you have any question please feel free to contact me.