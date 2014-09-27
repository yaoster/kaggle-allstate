library(randomForest)
source('load_data.R')
OUTPUT <- 'random_forest_test_output.csv'

NTREES <- 189
MTRY <- sqrt(M)
NODESIZE <- 1
rfA <- randomForest(x=train.data, y=factor(train.targets[,1]), do.trace=T, ntree=NTREES, mtry=MTRY, nodesize=NODESIZE)
rfB <- randomForest(x=train.data, y=factor(train.targets[,2]), do.trace=T, ntree=NTREES, mtry=MTRY, nodesize=NODESIZE)
rfC <- randomForest(x=train.data, y=factor(train.targets[,3]), do.trace=T, ntree=NTREES, mtry=MTRY, nodesize=NODESIZE)
rfD <- randomForest(x=train.data, y=factor(train.targets[,4]), do.trace=T, ntree=NTREES, mtry=MTRY, nodesize=NODESIZE)
rfE <- randomForest(x=train.data, y=factor(train.targets[,5]), do.trace=T, ntree=NTREES, mtry=MTRY, nodesize=NODESIZE)
rfF <- randomForest(x=train.data, y=factor(train.targets[,6]), do.trace=T, ntree=NTREES, mtry=MTRY, nodesize=NODESIZE)
rfG <- randomForest(x=train.data, y=factor(train.targets[,7]), do.trace=T, ntree=NTREES, mtry=MTRY, nodesize=NODESIZE)

votes <- cbind(rfA$votes, rfB$votes, rfC$votes, rfD$votes, rfE$votes, rfF$votes, rfG$votes)
write.table(votes, file='random_forest_votes.csv', sep=',', row.names=F, col.names=F)


pred <- cbind(rfA$predicted, rfB$predicted, rfC$predicted, rfD$predicted, rfE$predicted, rfF$predicted, rfG$predicted)
pred[,1] <- pred[,1] - 1
pred[,2] <- pred[,2] - 1
pred[,5] <- pred[,5] - 1
pred[,6] <- pred[,6] - 1

predA <- predict(rfA, newdata=test.data, type='response')
predB <- predict(rfB, newdata=test.data, type='response')
predC <- predict(rfC, newdata=test.data, type='response')
predD <- predict(rfD, newdata=test.data, type='response')
predE <- predict(rfE, newdata=test.data, type='response')
predF <- predict(rfF, newdata=test.data, type='response')
predG <- predict(rfG, newdata=test.data, type='response')
test.pred <- cbind(predA, predB, predC, predD, predE, predF, predG)
test.pred[,1] <- test.pred[,1] - 1
test.pred[,2] <- test.pred[,2] - 1
test.pred[,5] <- test.pred[,5] - 1
test.pred[,6] <- test.pred[,6] - 1
plan <- paste(as.character(test.pred[,1]),
              as.character(test.pred[,2]), 
              as.character(test.pred[,3]), 
              as.character(test.pred[,4]), 
              as.character(test.pred[,5]), 
              as.character(test.pred[,6]), 
              as.character(test.pred[,7]), 
              sep='')

output <- data.frame(customer_ID=test.customers$customer, plan=plan)
write.table(output, OUTPUT, col.names=T, row.names=F, quote=F, sep=',')
print(error.rate(train.targets, pred))

voteA <- predict(rfA, newdata=test.data, type='vote')
voteB <- predict(rfB, newdata=test.data, type='vote')
voteC <- predict(rfC, newdata=test.data, type='vote')
voteD <- predict(rfD, newdata=test.data, type='vote')
voteE <- predict(rfE, newdata=test.data, type='vote')
voteF <- predict(rfF, newdata=test.data, type='vote')
voteG <- predict(rfG, newdata=test.data, type='vote')
test.votes <- cbind(voteA, voteB, voteC, voteD, voteE, voteF, voteG)
write.table(test.votes, file='random_forest_test_votes.csv', sep=',', row.names=F, col.names=F)

# A - 9.5% / 11.05%
# B - 10.2%
# C - 10.7%
# D - 7.2%
# E - 9.8%
# F - 9.5%
# G - 17%

# features_v1
# Date | ntrees | mtry    | nodesize | train.score | test.score
# 4-21 | 101    | sqrt(M) | 1        |             | .54122
# 4-21 | 101    | sqrt(M) | 1        |             | .54104
# 4-21 | 101    | sqrt(M) | 1        | .57345      | .54200
# 4-21 | 201    | sqrt(M) | 1        | .57409      | .54212  <-
# 4-21 | 101    | M       | 1        | .56384      | .53380
# 4-21 | 101    | M/2     | 1        | .56844      | .53638
# 4-22 | 201    | sqrt(M) | 1        | .57407      | .54218  <-
# 4-23 | 301    | sqrt(M) | 1        | .57468      | .54128
# 4-23 | 301    | sqrt(M) | 1        | .57453      | .54200
# 4-24 | 101    | sqrt(M) | 5        | .57289      | .54140
# 4-25 | 298    | 7       | 21       | .57501      | .54194
# 4-25 | 199    | 28      | 35       | .57218      | .54098
# 4-25 | 179    | 2       | 23       | .52852      | .51460
# 4-25 | 179    | 44      | 4        | .56624      | .53626
# 4-25 | 172    | 23      | 27       | .57245      | .54068
# 4-25 | 289    | 35      | 20       | .57043      | .53865
# 4-25 | 230    | 37      | 26       | .57076      | .53853
# 4-25 | 137    | 41      | 32       | .56996      | .53859
# 4-26 | 171    | 23      | 12       | .57046      | .54027
# 4-26 | 179    | 8       | 21       | .57485      | .54110
# 4-29 | 179    | 8       | 1        | .57375      | .54224   <-
# 4-29 | 179    | 8       | 1        | .57376      | .54080
# 4-29 | 179    | 8       | 1        | .57561      | .54158
# 5-05 | 179    | 8       | 1        | .57576      | .54110
# 5-05 | 179    | 8       | 2        | .57541      | .54140
# 5-05 | 179    | 8       | 3        | .57586      | .54134
# 5-05 | 179    | 8       | 3        | .57547      | .54110
# 5-05 | 179    | 8       | 3        | .57452      | .54158
# 5-06 | 179    | 8       | 3        | .57441      | .54086
# 5-06 | 179    | 8       | 3        | .57383      | .54128
# 5-06 | 179    | 8       | 1        | .57407      | .54146
# 5-06 | 189    | 8       | 1        | .57399      | .54158
# 5-06 | 189    | 8       | 1        | .57414      | .54146
# 5-07 | 189    | 8       | 1        | .57380      | .54146
# 5-07 | 189    | 8       | 1        | .57348      | .54170
# 5-07 | 189    | 8       | 1        | .57584      | .54224  <-
# 5-12 | 189    | 8       | 1        | .57612      | .54194
# 5-12 | 189    | 8       | 1        | .57624      | .54200
# 5-12 | 189    | 8       | 1        | .57620      | .54158
# 5-13 | 189    | 8       | 1        | .57627      | .54146
# 5-14 | 189    | 8       | 1        | .57586      | .54230  <-

# features_v2
# Date | ntrees | mtry    | nodesize | train.score | test.score
# 4-22 | 101    | sqrt(M) | 1        | .57267      | .54110  <- was not using day difference
# 4-22 | 101    | sqrt(M) | 1        | .57362      | .54009
# 4-22 | 201    | sqrt(M) | 1        | .57509      | .54104
