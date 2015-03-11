#----------------------
# Project Assignment
#----------------------

library(tidyr)
library(plyr)
library(dplyr)

#check if required folder structure exists
folder_in <- "./samsung_galaxyS_acc_data/UCI HAR Dataset"

if(!file.exists(folder_in)){
	print("Path for input files does not exists")
} else{
        print("ok")	
}
#---------------------------------------------
# STEP1 : Merges the training and the test sets to create one data set.
#---------------------------------------------

#function for reading txt files to data frame
files_read <- function(main_folder,subfolder,filelist){
        path = paste(main_folder,"/",subfolder,sep = "")
		if(!file.exists(path)){
					print("Path for files does not exists")
					return(0)
		} 
        #read file 
		file1 <- paste(path,"/",filelist[1],sep="")
		file2 <- paste(path,"/",filelist[2],sep="")
		file3 <- paste(path,"/",filelist[3],sep="")
		data_id <- read.csv(file1,sep =" ",header = FALSE)
		data_y  <- read.csv(file2,sep =" ",header = FALSE)
		data_X  <- read.csv(file3,sep ="" ,header = FALSE)
		message("all three files read ")
		# join to from a data frame
		data_all<- cbind(data_id,data_y,data_X)
		data_out<- tbl_df(data_all)
		message("data frame created")
		rm(data_all,data_id,data_y,data_X,file1,file2,file3,path) #cleaning operation
		message("cleanup performed")
        return(data_out)
}

filelist_train<-c("subject_train.txt","y_train.txt","X_train.txt")
filelist_test<-c("subject_test.txt","y_test.txt","X_test.txt")

data_train <-files_read(main_folder=folder_in,subfolder="train",filelist=filelist_train)
data_test  <-files_read(main_folder=folder_in,subfolder="test" ,filelist=filelist_test)

#This is the one combined data 
data_step1<- rbind(data_train,data_test)
rm(filelist_train,filelist_test,data_train,data_test)

#---------------------------------------------
# STEP2 : Extracts only the measurements on the mean and standard deviation for each measurement.
#---------------------------------------------
#Assumption: selected features containing mean() ,std(),meanFreq() in the names.
#dropped variables which only had mean text in arguments and not in return function
#dropped e.g. angle(tBodyAccMean,gravity) , angle(tBodyAccJerkMean),gravityMean)


#fetching feature names from feature.txt
#----------------------------------------

file_path <- paste(folder_in,"/features.txt",sep="")
Xnames <- read.csv(file_path,sep="",header = FALSE)
xnames_vector <- lapply(Xnames$V2,as.character) 	#from factor to character conversion
allvarnames <- c("subject",c("activity"),xnames_vector)

#variable selection, choose 1,2 and any feature in list which contains mean() ,std(), meanFreq()

colmean     <- grep("mean\\(\\)",tolower(allvarnames))
colmeanfreq <- grep("meanfreq\\(\\)",tolower(allvarnames))
colstd      <- grep("std" ,tolower(allvarnames[]))

#final list of indices to keep
var_index <- c(1,2,colmean,colmeanfreq,colstd)
var_index <- sort(var_index)
var_index <- unique(var_index)

#filter columns by var_index this is the resutl for step2
data_step2 <- data_step1[ ,var_index]

rm(file_path,Xnames,xnames_vector,colmean,colmeanfreq,colstd)
#---------------------------------------------
# STEP3 : Uses descriptive activity names to name the activities in the data set
#---------------------------------------------

#acitivity labels
file_activity <- paste(folder_in,"/activity_labels.txt",sep="")
df_activity <- read.csv(file_activity,sep="",header = FALSE)

names(data_step2)[1] <- "subject"
names(data_step2)[2] <- "activity_no"
names(df_activity)[1]<- "activity_no"
names(df_activity)[2]<- "activity"
data_list <- join(data_step2[,2],df_activity, by="activity_no")
data_step3 <- cbind(data_step2[,1],data_list$activity,data_step2[,3:81])
rm(data_list,file_activity,df_activity)
#---------------------------------------------
# STEP4 : Appropriately labels the data set with descriptive variable names. 
#---------------------------------------------
#assign colmun names to megred data
names_final <- allvarnames[var_index]

names_final <- c("subject",
"activity",
"timeBodyAccelerometer-mean()-X",
"timeBodyAccelerometer-mean()-Y",
"timeBodyAccelerometer-mean()-Z",
"timeBodyAccelerometer-std()-X",
"timeBodyAccelerometer-std()-Y",
"timeBodyAccelerometer-std()-Z",
"timeGravityAccelerometer-mean()-X",
"timeGravityAccelerometer-mean()-Y",
"timeGravityAccelerometer-mean()-Z",
"timeGravityAccelerometer-std()-X",
"timeGravityAccelerometer-std()-Y",
"timeGravityAccelerometer-std()-Z",
"timeBodyAccelerometerJerk-mean()-X",
"timeBodyAccelerometerJerk-mean()-Y",
"timeBodyAccelerometerJerk-mean()-Z",
"timeBodyAccelerometerJerk-std()-X",
"timeBodyAccelerometerJerk-std()-Y",
"timeBodyAccelerometerJerk-std()-Z",
"timeBodyGyroscope-mean()-X",
"timeBodyGyroscope-mean()-Y",
"timeBodyGyroscope-mean()-Z",
"timeBodyGyroscope-std()-X",
"timeBodyGyroscope-std()-Y",
"timeBodyGyroscope-std()-Z",
"timeBodyGyroscopeJerk-mean()-X",
"timeBodyGyroscopeJerk-mean()-Y",
"timeBodyGyroscopeJerk-mean()-Z",
"timeBodyGyroscopeJerk-std()-X",
"timeBodyGyroscopeJerk-std()-Y",
"timeBodyGyroscopeJerk-std()-Z",
"timeBodyAccelerometerMagnitude-mean()",
"timeBodyAccelerometerMagnitude-std()",
"timeGravityAccelerometerMagnitude-mean()",
"timeGravityAccelerometerMagnitude-std()",
"timeBodyAccelerometerJerkMagnitude-mean()",
"timeBodyAccelerometerJerkMagnitude-std()",
"timeBodyGyroscopeMagnitude-mean()",
"timeBodyGyroscopeMagnitude-std()",
"timeBodyGyroscopeJerkMagnitude-mean()",
"timeBodyGyroscopeJerkMagnitude-std()",
"freqBodyAccelerometer-mean()-X",
"freqBodyAccelerometer-mean()-Y",
"freqBodyAccelerometer-mean()-Z",
"freqBodyAccelerometer-std()-X",
"freqBodyAccelerometer-std()-Y",
"freqBodyAccelerometer-std()-Z",
"freqBodyAccelerometer-meanFreq()-X",
"freqBodyAccelerometer-meanFreq()-Y",
"freqBodyAccelerometer-meanFreq()-Z",
"freqBodyAccelerometerJerk-mean()-X",
"freqBodyAccelerometerJerk-mean()-Y",
"freqBodyAccelerometerJerk-mean()-Z",
"freqBodyAccelerometerJerk-std()-X",
"freqBodyAccelerometerJerk-std()-Y",
"freqBodyAccelerometerJerk-std()-Z",
"freqBodyAccelerometerJerk-meanFreq()-X",
"freqBodyAccelerometerJerk-meanFreq()-Y",
"freqBodyAccelerometerJerk-meanFreq()-Z",
"freqBodyGyroscope-mean()-X",
"freqBodyGyroscope-mean()-Y",
"freqBodyGyroscope-mean()-Z",
"freqBodyGyroscope-std()-X",
"freqBodyGyroscope-std()-Y",
"freqBodyGyroscope-std()-Z",
"freqBodyGyroscope-meanFreq()-X",
"freqBodyGyroscope-meanFreq()-Y",
"freqBodyGyroscope-meanFreq()-Z",
"freqBodyAccelerometerMagnitude-mean()",
"freqBodyAccelerometerMagnitude-std()",
"freqBodyAccelerometerMagnitude-meanFreq()",
"freqBodyBodyAccelerometerJerkMagnitude-mean()",
"freqBodyBodyAccelerometerJerkMagnitude-std()",
"freqBodyBodyAccelerometerJerkMagnitude-meanFreq()",
"freqBodyBodyGyroscopeMagnitude-mean()",
"freqBodyBodyGyroscopeMagnitude-std()",
"freqBodyBodyGyroscopeMagnitude-meanFreq()",
"freqBodyBodyGyroscopeJerkMagnitude-mean()",
"freqBodyBodyGyroscopeJerkMagnitude-std()",
"freqBodyBodyGyroscopeJerkMagnitude-meanFreq()"
)

colnames(data_step3) <- names_final

#---------------------------------------------
# STEP5 :From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
#---------------------------------------------

data_final <- gather(data_step3,key = features, measure,-(subject:activity)) %>%
		separate(features,into=c("signal_type","stat"),extra="merge") %>%
		separate(stat,into=c("statistic","axis"),extra="merge") %>%
                tbl_df()

#coding NA for measure where axis information not code in the name.
data_final$axis <- ifelse(nchar(data_final$axis)==0,NA,data_final$axis)

tidy_data <- group_by(data_final,subject,activity,signal_type,axis) %>%
        summarize(mean = mean(measure))
