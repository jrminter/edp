\name{tune.edp.baseline.dm}
\alias{tune.edp.baseline.dm}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Tune the baseline for the pattern
}
\description{
plots background with parameters
}
\usage{
tune.edp.baseline.dm(dat.path="./", edp.base="Al", r.min=200, r.max=800, sb.win="15", sb.ord="4", do.log=TRUE, ...)
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
  \item{do.log}{
TRUE if y axis as a log
}
  \item{\dots}{
other graphical parameters
}
}
\details{
Add later \ldots
}
\value{

\item{r.min}{min radius used}
\item{r.max}{max radius used}
\item{sb.win}{window used for bkg}
\item{sb.ord}{background spline order used }
\item{plt.df}{dataframe with r, y.obs, y.bkg}

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
tune.edp.baseline.dm(main=NA)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ baseline }
\keyword{ tune }% __ONLY ONE__ keyword per line
