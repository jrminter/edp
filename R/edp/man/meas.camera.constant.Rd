\name{meas.camera.constant}
\alias{meas.camera.constant}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Measure the camera constant
}
\description{
Measure the camera constant from the first five peaks in a pattern.
}
\usage{
meas.camera.constant(cnt.dir='./', cnt.base='Al', r.min=250, r.max=800,
sb.win = '15', sb.ord = '6', hw.hm = 4,
icdd.dir='./',icdd.no = '04-0787', compound = 'Al', sp.grp = 'Fm3m',
pk.sigma=4.0, pk.thres=0.8, ccd.px.mm=15,
do.plot=TRUE, do.log.y=FALSE, ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{cnt.dir}{
Directory for count data. Must terminate with ``/''
}
  \item{cnt.base}{
Base name for .csv file with count data
}
  \item{r.min}{
minimum radius [px]
}
  \item{r.max}{
maximum radius [px]
}
  \item{sb.win}{
Window size for spectrum background
one of 3,5,7,9,11,13,15
}
  \item{sb.ord}{
polynomial order for the spline
one of 2,4,6,8 - as a string
}
  \item{hw.hm}{
half-width at half max for fit
}
  \item{icdd.dir}{
location of lines (must terminate with a ``/'')
}
  \item{icdd.no}{
icdd number of the card, as a string - 00-0000
}
  \item{compound}{
Name of the compound as a string, i.e. Al
}
  \item{sp.grp}{
Space group as a string - Fm3m
}
  \item{pk.sigma}{
sigma for the peak detection
}
  \item{pk.thres}{
threshold value for the peak detection
}
  \item{ccd.px.mm}{
mm/px for the ccd
}
  \item{do.plot}{
Plot the results
}
  \item{do.log.y}{
Use a log intensity axis
}
  \item{\dots}{
other graphical parameters
}
}
\value{
A vector with cc.mu.px.A, cc.se.px.A, cc.mu.mm.A, cc.se.mm.A,
hw.hm from the fit
}
\references{
See peaks pkg
}
\author{
John Minter
}
\note{
Make certain to set the minimum radius just below the first strong
peak in the standard. This ensures proper detection and a good fit
for the camera constant. You will want to run tune.edp.baseline.dm()
first to be certain to get optimum background subtraction.
}

\examples{
rm(list=ls())
require(edp)
make.test.ed.data(dir = './')
cc <- meas.camera.constant ()
print(cc)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ camera constant }
\keyword{ peak fitting }% __ONLY ONE__ keyword per line
