tune.edp.baseline.dm <-
function(dat.path='./',
         edp.base='Al',
         r.min=200,
         r.max=800,
         sb.win='15',
         sb.ord='4',
         do.log=TRUE,
         ...){
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
  if(do.log==TRUE) {
    plot(df.dat[,1], df.dat[,2], type='l', col='black',
         xlab='r [px]', ylab='gross cts', log='y', ...)
  } else {
    plot(df.dat[,1], df.dat[,2], type='l', col='black',
         xlab='r [px]', ylab='gross cts', ...)
  }  
  #
  # SpectrumBackground(y, iterations=100, decreasing=FALSE,
  #                    order=c("2","4","6","8"),
  #                    smoothing=FALSE,
  #                    window=c("3","5","7","9","11","13","15"),
  #                    compton=FALSE)
  
  y.bkg <- SpectrumBackground(df.dat[,2], order=sb.ord,
                              window=sb.win)
  lines(df.dat[,1], y.bkg, col='red')
  
  plt.df <- data.frame(r=df.dat[,1], y.obs=df.dat[,2], y.bkg=y.bkg)
  
  edp.bkg.par=list(r.min, r.max, sb.win, sb.ord, plt.df )
  edp.bkg.par
}
# for testing
# tune.edp.baseline.dm( do.log=TRUE)
