###getting and cleaning data proj

Instructions for running file run_analysis.R
============================================
data folder "samsung_galaxyS_acc_data" should be in same 
location as script. Also the following subfolder structure should hold
folder should exist "samsung_galaxyS_acc_data/UCI HAR Dataset/train"
folder should exist "samsung_galaxyS_acc_data/UCI HAR Dataset/test"

STEP1 : Merges the training and the test sets to create one data set.
----------------------------------------------------------------------
Create a function files_read takes path and list of names of files to append columnwise.
we read all the csv files into R dataset and combine each one to form a 
single big data. We call this function once each for train and test folders.
```
data_train <-files_read(main_folder=folder_in,subfolder="train",filelist=filelist_train)
data_test  <-files_read(main_folder=folder_in,subfolder="test" ,filelist=filelist_test)
```
Then we append the Train and Test into one big data set. `data_step1<- rbind(data_train,data_test)`

STEP2 : Extracts only the measurements on the mean and standard deviation for each measurement.
-----------------------------------------------------------------------------------------------
strategy for selecting the variables names
1. do a search using grep for 'std' using grep. see results, all looked good.
2. do a search using grep for 'mean'using grep. see results, there we occurrences of 
mean within arguments to angle() function which need to be dropped as the value returned is not
as mean. Using using mean() and meanfreq() i could select all the relevant mean variables.
```
grep("mean\\(\\)",tolower(allvarnames))
grep("meanfreq\\(\\)",tolower(allvarnames))
```
3. Create a array of names of variables, include include the first two columns and the above
selected variables. `var_index <- c(1,2,colmean,colmeanfreq,colstd)` etc commands..
4. filter the dataset selected variables `data_step2 <- data_step1[ ,var_index]`

STEP3 : Uses descriptive activity names to name the activities in the data set
-------------------------------------------------------------------------------
1.fetch activity labels from the features.txt file.
```
file_activity <- paste(folder_in,"/activity_labels.txt",sep="")
df_activity <- read.csv(file_activity,sep="",header = FALSE)
```
2. We need to join the above dataset(df_activity) with previous data(data_step2) set in one many mapping
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
STEP4 : Appropriately labels the data set with descriptive variable names. 
---------------------------------------------
Assign colmun names to merged dataset. for this we use the column names vector
we generated in STEP2 'allvarnames' and var_index for filtering the correct names
`names_final <- allvarnames[var_index]` Then do edit and expand the variable names to more descriptive names manually.
```
names_final <- c("subject",
"activity",
"timeBodyAccelerometer-mean()-X",
....)
```
Then assign these to the data_step3 `colnames(data_step3) <- names_final`

STEP5 :From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
-----------------------------------------------------------------------------------------------------------------------------------------------------
