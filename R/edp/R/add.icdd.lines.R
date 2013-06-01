add.icdd.lines <-
function(path='./',
         card='04-0787-Al-Fm3m',
         max.ht=5000,
         l.col='blue',
         do.legend=TRUE,
         do.debug=FALSE){
  # function to add icdd lines
  str.file <- paste(path,card,'.csv',sep='')
  df.lines <- read.csv(file=str.file, header=TRUE, as.is=TRUE)
  max.int <- max(df.lines[,2])
  n.lines <- nrow(df.lines)
  if(do.debug==TRUE) print(n.lines)
  for(i in 1:n.lines){
    d.nm <- 0.1*df.lines[i,1]
    k    <- 2*pi/d.nm
    i.r  <- (1/max.int)*df.lines[i,2]*max.ht
    x.t  <- c(k,k)
    y.t  <- c(0,i.r)
    lines(x.t,y.t, col=l.col)
    if(do.legend){
      legend("topright", card,col=l.col,lty=1)
    }
  }
}
