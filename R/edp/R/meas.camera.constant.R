meas.camera.constant <-
function(cnt.dir='./', cnt.base='Al', r.min=250, r.max=800,
         sb.win='15', sb.ord='6', hw.hm=4,
         icdd.dir='./', icdd.no='04-0787', compound='Al', sp.grp='Fm3m',
         pk.sigma=4.0, pk.thres=0.8, ccd.px.mm=15,
         do.plot=TRUE, do.log.y=FALSE, ...){
  # measure the camera constant using the first
  # five lines of the standard
  
  # define std error for later
  stderr <- function(x) sqrt(var(x)/length(x))
  
  str.lines <- paste(icdd.dir,
                     icdd.no,'-', compound, '-',
                     sp.grp, '.csv', sep='')
  
  df.std <- read.csv(str.lines, header = T)
  # First 5 d-spacings of standard [A]
  v.d     <- df.std[1:5,1]
  v.h     <- df.std[1:5,2]
  # physical pixel spacing mm/px for the CCD camera [mm]
  pixel <- ccd.px.mm/1000
  count.file <- paste(cnt.dir,cnt.base,'-dc-ra.csv', sep='')
  df.dat <- read.csv(count.file, header = T, sep=',')
  names(df.dat) <-c("r.px","int.gross")
  df.dat <- subset(df.dat, df.dat[,1] > r.min)
  df.dat <- subset(df.dat, df.dat[,1] < r.max)
  x <- df.dat[,1]
  y <- df.dat[,2]
  # compute the slowly varying background
  y.bkg <- SpectrumBackground(y,
                              order=sb.ord,
                              window=sb.win)
  # compute and plot the net intensity
  y.bks <- y-y.bkg
  for(i in 1:length(y.bks)){
    y.bks[i] <- max(y.bks[i], 10)
  }
  # find the peaks
  pks   <- SpectrumSearch(y.bks, sigma=pk.sigma, threshold=pk.thres)
  # sort in increasing position
  pks   <- sort(unlist(pks$pos))
  
  # since we will do a fit, estimate the camera constant from the
  # first peak and use it to guess the centroids for the remaining
  # four
  p.one <- pks[1]
  cc.guess <- v.d[1]*(p.one + r.min)
  n.pks <- 5
  v.rad <- vector(mode='numeric', length=n.pks)
  v.ht <- vector(mode='numeric', length=n.pks)
  for (i in 1:n.pks){
    v.rad[i] = cc.guess / v.d[i]
    v.ht[i] <- y.bks[as.integer(floor(v.rad[i]-r.min))]
  } 
  # v.rad <- pks + r.min
  df.pks <- data.frame(rad=v.rad, ht=v.ht)
  
  pk.approx <- df.pks[,2]
  mu.approx <- df.pks[,1]
  s.approx  <- rep(hw.hm, n.pks)
  fit <- nls(y.bks ~
               pk1*exp(-log(2.0)*((x-mu1)/hwhm)^2)  +
               pk2*exp(-log(2.0)*((x-mu2)/hwhm)^2)  +
               pk3*exp(-log(2.0)*((x-mu3)/hwhm)^2)  +
               pk4*exp(-log(2.0)*((x-mu4)/hwhm)^2)  +
               pk5*exp(-log(2.0)*((x-mu5)/hwhm)^2),
             start=list( hwhm = hw.hm,
                         pk1 = pk.approx[1], mu1 = mu.approx[1],
                         pk2 = pk.approx[2], mu2 = mu.approx[2],
                         pk3 = pk.approx[3], mu3 = mu.approx[3],
                         pk4 = pk.approx[4], mu4 = mu.approx[4],
                         pk5 = pk.approx[5], mu5 = mu.approx[5]),
             trace=F)
  
  s <- summary(fit)
  c <- coef(s)
  
  hwhm <- c[[1]]
  pk1  <- c[[2]]
  mu1  <- c[[3]]
  pk2  <- c[[4]]
  mu2  <- c[[5]]
  pk3  <- c[[6]]
  mu3  <- c[[7]]
  pk4  <- c[[8]]
  mu4  <- c[[9]]
  pk5  <- c[[10]]
  mu5  <- c[[11]]
  
  y.fit <- pk1*exp(-log(2.0)*((x-mu1)/hwhm)^2)  +
    pk2*exp(-log(2.0)*((x-mu2)/hwhm)^2)  +
    pk3*exp(-log(2.0)*((x-mu3)/hwhm)^2)  +
    pk4*exp(-log(2.0)*((x-mu4)/hwhm)^2)  +
    pk5*exp(-log(2.0)*((x-mu5)/hwhm)^2)
   
  peak.centroids <- c(mu1, mu2, mu3, mu4, mu5)
  peak.heights   <- c(pk1, pk2, pk3, pk4, pk5)
  max.ht <- max(peak.heights)
  
  if(do.plot==TRUE){ 
    if(do.log.y==TRUE){
      plot(x, y.bks, type='l', xlab='radius [px]',
           ylab='net cts', log='y', ...)
    } else {
      plot(x, y.bks, type='l', xlab='radius [px]',
           ylab='net cts', ...)
    }
    # label the peaks on the graph & populate height vector
    for (i in 1:n.pks){
      x.t <- c(peak.centroids[i], peak.centroids[i])
      y.t <- c(1,(max.ht/100)*v.h[i])
      lines(x.t, y.t, col='blue')
    }
  
    x.c   <- df.dat[,1]
    y.c   <- df.dat[,2]
    n.lines <- length(v.h)
    n.pts <- length(y.c)
    for(i in 1:n.lines){
      for(j in 1:n.pts){
        y.c[j] <- peak.heights[i]*
          exp(-log(2.0)*
              ((x.c[j]-peak.centroids[i])/
                 hwhm)^2)
        if(y.c[j] < 2) y.c[j] <- NA
      }
      lines(x.c, y.c, col='red', lty=2)   
    }
  }
  
  # compute and output the results
  cc <- v.d * peak.centroids
  cc.mu <- mean(cc)
  cc.se <- stderr(cc)
  res <- round(c(cc.mu, cc.se,
                 pixel*cc.mu, pixel*cc.se, hwhm), 3)
  names(res) <- c('cc.mu.px.A', 'cc.se.px.A',
                  'cc.mu.mm.A', 'cc.se.mm.A',
                  'hw.hm')
  res
}
