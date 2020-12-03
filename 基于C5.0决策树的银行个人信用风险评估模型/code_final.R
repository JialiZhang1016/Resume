#### input the data ####
dataset = read.csv("model_sample.csv")
dataset = dataset[,-1]


#### data clean ####
# delete part of the data
isna<-sapply(dataset, function(x) sum(is.na(x)))
dataset_3 <- subset(dataset,select = sapply(dataset, function(x) sum(is.na(x)))<2000) # 删去列中�?0太多�?
dataset_4 <- na.omit(dataset_3) # 删去行有空缺�?
dataset_5 <- dataset_4[,-which(colSums(dataset_4)<150)] # 删去全为0的�?
datanew <- dataset_5
#sapply(datanew,class)
datanew = cbind(y = as.factor(datanew$y),datanew[,-1])
#sapply(datanew,class) 
# outline point
summary(datanew)
dim(datanew)
table(datanew$y)
table(datanew$x_001)
str(datanew)



#### train-set and test-set(3:7) ####
set.seed(111)
n <- dim(datanew)[1]
index = sample(n,round(0.7*n))
train = datanew[index,]
test = datanew[-index,]
# examine train and test set data 
prop.table(table(train$y));prop.table(table(test$y)) 
prop.table(table(dataset$x_001));prop.table(table(datanew$x_001))



#### C5.0 decision tree ####
# library(C50)
# library(gmodels)

# modeling and caculate time
runT = rep(0,40)
accurancy = rep(0,40)
times <- proc.time()
credit_model <- C5.0(train[-1],train$y)
timee <- proc.time()

# predict and caculate accurancy
credit_pred <- predict(credit_model, test)
runT[1] <- timee[[3]]-times[[3]]
accurancy[1] = mean(credit_pred == test$y)
CrossTable(test$y, credit_pred,prop.chisq = F,prop.c = F, prop.r = F,dnn = c('actual default','predict default'))



#### C5.0 boosting ####
runT = rep(0,40)
accurancy = rep(0,40)
trialf = rep(1,40)
triall = rep(1,40)
for(i in 2:40)
{
  times <- proc.time()
  credit_boost <- C5.0(train[-1],train$y,trial = i)
  timee <- proc.time()
  runT[i] <- timee[[3]]-times[[3]]
  credit_pred <- predict(credit_boost, test)
  accurancy[i] <- mean(credit_pred == test$y)
  itrial <- credit_boost$trials
  trialf[i] <- itrial[[1]]
  triall[i] <- itrial[[2]]
}
AT <- cbind(runT,accurancy,trialf,triall)

credit_boost14 <- C5.0(train[-1],train$y,trials = 15)
credit_pred <- predict(credit_boost14, test)
CrossTable(test$y, credit_pred,prop.chisq = F,prop.c = F, prop.r = F,dnn = c('actual default','predict default'))



#### cost matrix ####
error_cost <- matrix(c(0,1,4,0),nrow = 2)
credit_model <- C5.0(train[-1],train$y,costs = error_cost,trials=15)
credit_pred <- predict(credit_model, test)
CrossTable(test$y, credit_pred,prop.chisq = F,prop.c = F, prop.r = F,dnn = c('actual default','predict default'))



install.packages("partykit")
library("partykit")
mytree <- C50::C5.0(train[-1],train$y,costs = error_cost,trials=15)
plot(credit_model[50])



