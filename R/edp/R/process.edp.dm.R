process.edp.dm <-
function(dat.path="./",
         edp.base="Al",
         r.min=200,
         r.max=800,
         sb.win="15",
         sb.ord="4",
         cc.mu.px.A=787.844,
         do.plot=TRUE,
         do.log=TRUE){
  # tune the background for a radially-averaged EDP
  # assumes radial dist'n data from V. Hou/J. Minter DigitalMicrograph
  # plug-in 'EDP'
  require(Peaks)
  
  edp.file <- paste(dat.path, edp.base,
                    '-dc-ra.csv', sep='')
  df.dat <- read.csv(edp.file, header = T, sep=",")
  names(df.dat) <-c("r.px","int.gross")
  df.dat <- subset(df.dat, df.dat[,1] > r.min)
  df.dat <- subset(df.dat, df.dat[,1] < r.max)
  
  #
  # SpectrumBackground(y, iterations=100, decreasing=FALSE,
  #                    order=c("2","4","6","8"),
  #                    smoothing=FALSE,
  #                    window=c("3","5","7","9","11","13","15"),
  #                    compton=FALSE)
  
  y.bkg <- SpectrumBackground(df.dat[,2], order=sb.ord,
                              window=sb.win)
  n.pts <- length(y.bkg)
  # need to convert to reciprocal nm... so 20 instead of 2...
  factor <- 20*pi/cc.mu.px.A
  df.dat[,1] <- factor*df.dat[,1]
  y.bks <- df.dat[,2]-y.bkg
  for(i in 1:n.pts){
    df.dat[i,2] <- max(y.bks[i], 0.1)
  }

  names(df.dat) <-c("k","int.net")
  if(do.plot==TRUE){
     if(do.log==TRUE) {  
        plot(df.dat[,1], df.dat[,2], type='l', col='black',
          xlab='k (2*pi/d) [1/nm]', ylab='gross cts', log='y',
             ylim=c(5, max(df.dat[,2])))
     } else {
        plot(df.dat[,1], df.dat[,2], type='l', col='black',
          xlab='k (2*pi/d) [1/nm]', ylab='gross cts')
     }
  }
  # return a bkg corrected data frame
  df.dat
}
# for testing
# process.edp.dm(do.plot=TRUE, do.log=FALSE)