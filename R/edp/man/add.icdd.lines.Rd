\name{add.icdd.lines}
\alias{
add.icdd.lines
}
\title{
Add diffraction lines from icdd card
}
\description{
Load the d-spacings and intensities for an icdd file
from a .csv file and plot them on the active graph.
}
\usage{
add.icdd.lines(path='./', card='04-0787-Al-Fm3m', max.ht=5000,
l.col='blue', do.legend=TRUE, do.debug=FALSE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{path}{
path to directory where .csv files with data are store,
Must end with a ``/''.
}
  \item{card}{
Base file name for the card (w/o the .csv) 
}
  \item{max.ht}{
Maximum plot height
}
  \item{l.col}{
Color for the lines
}
  \item{do.legend}{
TRUE or FALSE whether to print legend text
}

  \item{do.debug}{
TRUE or FALSE whether to print out diagnostice
}
}
\value{
No return value
}
\author{
J. R Minter
}

\examples{
require(edp)
make.test.ed.data(dir = './')
cc <- meas.camera.constant()
al.edp <- process.edp.dm(cc.mu.px.A=cc[1], do.log=FALSE)
add.icdd.lines()
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{icdd lines}
