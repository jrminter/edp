\name{process.edp.dm}
\alias{process.edp.dm}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Process a spectrum 
}
\description{
subtracts background, converts to k-space, optional plot
}
\usage{
process.edp.dm(dat.path="./", edp.base="Al", r.min=200, r.max=800, sb.win="15", sb.ord="4", cc.mu.px.A=787.844, do.plot=TRUE, do.log=TRUE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{dat.path}{
Data directory (teminate with "/")
}
  \item{edp.base}{
base name
}
  \item{r.min}{
minimum radius [px]
}
  \item{r.max}{
maximum radius [px]
}
  \item{sb.win}{
Window size for spectrum background
window=c("3","5","7","9","11","13","15")
}
  \item{sb.ord}{
polynomial order for the spline
order=c("2","4","6","8")
}
  \item{cc.mu.px.A}{
camera constant
}
  \item{do.plot}{
TRUE if you want a plot
}
  \item{do.log}{
TRUE if y axis as a log
}
}
\details{
Add later \ldots
}
\value{
cal.bks.data.frame
}
\references{
Peaks pkg
}
\author{
John Minter
}
\examples{
require(edp)
make.test.ed.data(dir = './')
process.edp.dm(do.log=FALSE)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{baseline}
\keyword{tune}% __ONLY ONE__ keyword per line
