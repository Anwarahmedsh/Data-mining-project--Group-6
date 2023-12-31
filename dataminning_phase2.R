#importing dataset
setwd("C:/Users/saran/OneDrive")
dataset = read.csv('BreastCancer1.csv')
str(dataset)
library(Hmisc)
describe(dataset)
summary(dataset)
#histogram for ages
hist(dataset$Age)
#A histogram showing the age distribution of women diagnosed with breast cancer. The histogram shows that breast cancer is more common among women whose ages range from 45 t0 50 years(highest frequency).

#pie chart for race
library(dplyr)
tab = dataset$Race %>% table()
precentages = tab %>% prop.table() %>% round(3)*100
txt = paste0(names(tab), '\n', precentages, '%')
pie(tab, labels = txt, main= 'Race')
#The pie chat divided the races into three sections with their percentage ( as our dataset shows we have white, black , other). As we see, the white race preset the highest percentage ( 84.8%).




#Scatter Plot
with(dataset, plot(Tumor.Size, Survival.Months, col = "blue", pch = 16))
#This scatter plot has no correlation although we can see that when the tumor size is small the human is more likely to live more months which make sense





#changing the value IV in Grade attribute
dataset$Grade[dataset$Grade == ' anaplastic; Grade IV' ] = 4 
table(dataset$Grade)

#install.packages("outliers")
library(outliers)
#outliers of age
outage= outlier(dataset$Age)
print(outage)
#number of rows that have the outlier 
table(dataset$Age == outage )

#outliers of tumor size
outTumorSize = outlier(dataset$Tumor.Size)
print(outTumorSize)
#number of rows that has the outlier
table(dataset$Tumor.Size == outTumorSize)

#outliers of Regional Node Examined
outNodeExamined = outlier(dataset$Regional.Node.Examined)
print(outNodeExamined)
#number of rows that has the outlier
table(dataset$Regional.Node.Examined == outNodeExamined )

#outliers of Reginol Node Positive
outNodepositive = outlier(dataset$Reginol.Node.Positive)
print(outNodepositive)
#number of rows that has the outlier
table(dataset$Reginol.Node.Positive == outNodepositive )

#outliers of Survival Months
outmonth = outlier(dataset$Survival.Months)
print(outmonth)
#number of rows that has the outlier 
table(dataset$Survival.Months==outmonth)

#delete the outliers
dataset = dataset[dataset$Age != outage ,]
dataset = dataset[dataset$Tumor.Size != outTumorSize ,]
dataset = dataset[dataset$Regional.Node.Examined != outNodeExamined ,]
dataset = dataset[dataset$Reginol.Node.Positive != outNodepositive ,]
dataset = dataset[dataset$Survival.Months != outmonth ,]
nrow(dataset)

#checking if there is any missing value or duplicated rows 
is.na(dataset)
sum(is.na(dataset))
sum(duplicated(dataset))
#removing duplicate
dataset= unique(dataset)
sum(duplicated(dataset))
#number of rows after deleting dup
nrow(dataset)
nrow(dataset)

#Normalization:
#Define function normalize
normalize <- function(x) {return ((x - min(x)) / (max(x) - min(x)))}

#Call normalize function
dataset$Age<-normalize(dataset$Age)
dataset$Tumor.Size<-normalize(dataset$Tumor.Size)
dataset$Regional.Node.Examined<-normalize(dataset$Regional.Node.Examined)
dataset$Reginol.Node.Positive<-normalize(dataset$Reginol.Node.Positive)
dataset$Survival.Months<-normalize(dataset$Survival.Months)


#showing normalized columns
print(dataset)

#encoding
dataset$Race = factor(dataset$Race,levels = c("White","Black", "Other"), labels=c(1,2,3))
dataset$Marital.Status = factor(dataset$Marital.Status,levels = c("Married","Divorced","Separated","Single ","Widowed"), labels=c(1,2,3,4,5))
dataset$differentiate = factor(dataset$differentiate,levels = c("Well differentiated","Moderately differentiated", "Poorly differentiated","Undifferentiated"), labels=c(1,2,3,4))
dataset$X6th.Stage = factor(dataset$X6th.Stage,levels = c("IIA","IIIA", "IIB","IIIB","IIIC"), labels=c(1,2,3,4,5))
dataset$Status = factor(dataset$Status,levels = c("Dead","Alive"), labels=c(0,1))
dataset$Estrogen.Status = factor(dataset$Estrogen.Status ,levels = c("Negative","Positive"), labels=c(0,1))
dataset$Progesterone.Status = factor(dataset$Progesterone.Status ,levels = c("Negative","Positive"), labels=c(0,1))
dataset$A.Stage	 = factor(dataset$A.Stage	,levels = c("Regional","Distant"), labels=c(0,1))
dataset$T.Stage	 = factor(dataset$T.Stage	,levels = c("T1","T2","T3","T4"), labels=c(1,2,3,4))
dataset$N.Stage	 = factor(dataset$N.Stage	,levels = c("N1","N2","N3"), labels=c(1,2,3))

is.na(dataset)
sum(is.na(dataset))

#feature selection
# Get the column names of the dataset
column_names <- colnames(dataset)

# Perform chi-square test for each attribute
for (attribute in column_names) {
  if (attribute != "Status") {
    # Create a contingency table
    contingency_table <- table(dataset[[attribute]], dataset$Status)
    
    # Perform chi-square test
    result <- chisq.test(contingency_table)
    
    # Print the attribute name and the result
    cat("Attribute:", attribute, "\n")
    print(result)
    cat("\n")
  }
}
#the chi-square test results indicate that most of the attributes have a significant association with the variable being tested. These attributes include Age, Race, Marital.Status, T.Stage, N.Stage, X6th.Stage, differentiate, Grade, A.Stage, Estrogen.Status, Progesterone.Status, Regional.Node.Examined, Reginol.Node.Positive, Tumor.Size, Survival.Months, and Status. The low p-values provide strong evidence to reject the null hypothesis of no association between these attributes and the variable.
#Since they are highly correlated there is no need to perform feature selection






#other way to choose the relevant attributes to the dataset, we performed this feature selection if you want to check it out, although we think the chi square is better
# ensure the results are repeatable
set.seed(7)
# load the library
library(mlbench)
library(caret)
# Split the dataset into features and target variable
features <- dataset[, -c(2 , 3 ,16)]  # Exclude non-numeric and target variable columns
target <- dataset$Status

# Define the control parameters for RFE
ctrl <- rfeControl(functions = rfFuncs, 
                   method = "cv",
                   number = 10)  # 10-fold cross-validation

# Assuming 'rfFuncs' is correctly defined for Recursive Feature Elimination using Random Forest
rfe_result <- rfe(features, target, sizes = 1:ncol(features), rfeControl = ctrl)

# Print the RFE result
print(rfe_result)
plot(rfe_result)
#The key output from the RFE method is a ranked list of features based on their importance. The higher-ranked features are considered more important or relevant for predicting the target variable, this helps choosing which features to include or exclude in the  predictive model. so we can improve model efficiency, reduce overfitting, and enhance interpretability by focusing on the most relevant features for the task at hand.