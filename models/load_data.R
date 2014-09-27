TEST_DATA <- paste(path.expand('~'), '/src/kaggle/kaggle-allstate/data/test_features.csv', sep='')
TEST_CUSTOMERS <- paste(path.expand('~'), '/src/kaggle/kaggle-allstate/data/test_customers.csv', sep='')
TRAINING_DATA <- paste(path.expand('~'), '/src/kaggle/kaggle-allstate/data/train_features.csv', sep='')
TRAINING_TARGETS <- paste(path.expand('~'), '/src/kaggle/kaggle-allstate/data/train_targets.csv', sep='')
train.data <- read.table(TRAINING_DATA, sep=',', header=F, as.is=T)
test.data <- read.table(TEST_DATA, sep=',', header=F, as.is=T)
test.customers <- read.table(TEST_CUSTOMERS, sep=',', header=T, as.is=T)
train.targets <- read.table(TRAINING_TARGETS, sep=',', header=T, as.is=T)
customers <- train.targets[, 1]
train.targets <- train.targets[, 2:dim(train.targets)[2]]
N <- dim(train.data)[1]
M <- dim(train.data)[2]

error.rate <- function(targets, pred)
{
    N <- dim(targets)[1]
    M <- dim(targets)[2]

    ncorrect <- rowSums(pred == targets)
    err.rate <- sum(ncorrect == M)/N
    return(err.rate)
}
