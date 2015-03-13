#Getting and Cleaning data project README FILE

###This file contains 
* Instructions for running file _run_analysis.R_
* Explanation for each step in file _run_analysis.R_
* Assumption made if any for a particular step

Pre-requisites for running the script

* script _run_analysis.R_ and data folder _samsung_galaxyS_acc_data_ should be in same 
location. 
* Also the following sub folder structure should hold
 + folder should exist: _samsung_galaxyS_acc_data/UCI HAR Dataset/train/_
 + folder should exist: _samsung_galaxyS_acc_data/UCI HAR Dataset/test/_

###STEP1 : Merges the training and the test sets to create one data set.

Function *files_read* : arguments takes path and list of names of csv files to merge columnwise.
 1. reading all csv files in R datasets
 2. merges all datasets column wise to form one R
 3. return the new data frame

We call this function twice, once each for files in _train_ and _test_ folders
```
data_train <-files_read(main_folder=folder_in,subfolder="train",filelist=filelist_train)
data_test  <-files_read(main_folder=folder_in,subfolder="test" ,filelist=filelist_test)
```
Then we row append _data_train_ and _data_test_ into one big data set by `data_step1<- rbind(data_train,data_test)`

###STEP2 : Extracts only the measurements on the mean and standard deviation for each measurement.

**Approach:** We divide this task into following steps
 1. Extract all the feature names from _feature.txt_ file in folder *samsung_galaxyS_acc_data/UCI HAR Dataset*.
 2. Explore results obtained by matching, using broad searching keys "_std_" and "_mean_" criteria
   + do a search using grep for keyword 'std'. `grep("std",tolower(allvarnames))` see results, all looked good.
   + do a search using grep for keyword 'mean'. `grep("mean",tolower(allvarnames))` see results, 
     * Here we see occurrences of text "*mean*" within arguments to angle() function which we dropped. Measure returned is a value of angle function not 
a direct mean quantity and cannot be used as linearly. 
 3. Fine tuning the searching criteria to select only the relevant columns
   + observed using keywords as _mean()_ and _meanfreq()_, i select all the relevant mean features and drop those in angle() arguments. 
   ```
	grep("mean\\(\\)",tolower(allvarnames))
	grep("meanfreq\\(\\)",tolower(allvarnames))
	```
 4. Final feature list includes, 1st & 2nd columns (subject and activity info features), and list of features obtained from step 3 above `var_index <- c(1,2,colmean,colmeanfreq,colstd)`
 5. Subset the data from STEP1 `data_step2 <- data_step1[ ,var_index]`

###STEP3 : Uses descriptive activity names to name the activities in the data set

We divide this task into following steps
 1. Fetch activity labels from the features.txt file.
 
 ```
 file_activity <- paste(folder_in,"/activity_labels.txt",sep="")
 df_activity <- read.csv(file_activity,sep="",header = FALSE)
 ```
 2. We join the above dataset(df_activity) with previous data(data_step2) set in one many mapping. To do this we do the following
   + assign same name to the by variables in both data sets
   ``` 
    names(data_step2)[2] <- "activity_no"
    names(df_activity)[1]<- "activity_no"
   ```
   + Use join function to do one many mapping and cbind to reposition the columns
   ```
    data_list <- join(data_step2[,2],df_activity, by="activity_no")
    data_step3 <- cbind(data_step2[,1],data_list$activity,data_step2[,3:81])
   ```
we get required **data_step3**

###STEP4 : Appropriately labels the data set with descriptive variable names. 

This step required manual processing to dress up the variable names.
We divide this task into following steps
 1. Assign column names(as given to us) to merged dataset from STEP3. For this we use the column names vector we generated in STEP2 'allvarnames' in combination with 'var_index' for filtering the correct names
`names_final <- allvarnames[var_index]`. 
 2. Export this vector and then do manual edit and expand the variable names to more descriptive names. The final names vector should look like this.
  ```
  # sample of first 3 names, 3rd feature has been expanded to new name
  names_final <- c("subject",
  "activity",
  "timeBodyAccelerometer-mean()-X",
  ....)
   ```
 3. Then assign new names to the dataset obtained from STEP3 'data_step3' using `colnames(data_step3) <- names_final`

###STEP5 :From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

This step is performed in following steps

 1. Keeping subject and activity variables fixed we transpose rest of the variables using gather function to get the long form of data
    `gather(data_step3,key = features, measure,-(subject:activity)) %>%`
 2. Which is then decomposed multiple statements to separate the various multiple informations in the same values into different column
    ```
	separate(features,into=c("signal_type","stat"),extra="merge") %>%
	   separate(stat,into=c("statistic","axis"),extra="merge") %>%
	```
 3. For values which do not have axis informations we explicitly code them as NA
	`data_final$axis <- ifelse(nchar(data_final$axis)==0,NA,data_final$axis)`
 4. On the data obtained from above step "independent tidy data set" we calculate the average of each variable for each activity and each subject.
	```
	tidy_data <- group_by(data_final,subject,activity,signal_type,axis) %>%
        summarize(mean = mean(measure))
	```
 5. Finally we write the data down to the local directory in txt format
   `write.table(tidy_data,file="./tidy_data.txt",row.names=FALSE)`