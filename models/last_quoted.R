source('load_data.R')

last.quoted <- function(data)
{
    a.quote <- data[,15:17]
    b.quote <- data[,18:19]
    c.quote <- data[,20:23]
    d.quote <- data[,24:26]
    e.quote <- data[,27:28]
    f.quote <- data[,29:32]
    g.quote <- data[,33:36]

    a.point <- rep(0, N)
    b.point <- rep(0, N)
    c.point <- rep(0, N)
    d.point <- rep(0, N)
    e.point <- rep(0, N)
    f.point <- rep(0, N)
    g.point <- rep(0, N)

    a.point[a.quote[,1] == 1] <- 0
    a.point[a.quote[,2] == 1] <- 1
    a.point[a.quote[,3] == 1] <- 2

    b.point[b.quote[,1] == 1] <- 0
    b.point[b.quote[,2] == 1] <- 1

    c.point[c.quote[,1] == 1] <- 1
    c.point[c.quote[,2] == 1] <- 2
    c.point[c.quote[,3] == 1] <- 3
    c.point[c.quote[,4] == 1] <- 4

    d.point[d.quote[,1] == 1] <- 1
    d.point[d.quote[,2] == 1] <- 2
    d.point[d.quote[,3] == 1] <- 3

    e.point[e.quote[,1] == 1] <- 0
    e.point[e.quote[,2] == 1] <- 1

    f.point[f.quote[,1] == 1] <- 0
    f.point[f.quote[,2] == 1] <- 1
    f.point[f.quote[,3] == 1] <- 2
    f.point[f.quote[,3] == 1] <- 3

    g.point[g.quote[,1] == 1] <- 1
    g.point[g.quote[,2] == 1] <- 2
    g.point[g.quote[,3] == 1] <- 3
    g.point[g.quote[,3] == 1] <- 4

    pred <- cbind(a.point, b.point, c.point, d.point, e.point, f.point, g.point)
    return(pred)
}

pred <- last.quoted(train.data)
err <- error.rate(train.targets, pred)
print(err)

test.pred <- last.quoted(test.data)
test.pred <- data.frame(customer_ID=customers, plan=test.pred)
