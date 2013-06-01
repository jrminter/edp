\name{edp-package}
\alias{edp-package}
\alias{edp}
\docType{package}
\title{
edp
}
\description{
Processes electron diffraction patterns.
}
\details{
\tabular{ll}{
Package: \tab edp\cr
Type: \tab Package\cr
Version: \tab 1.0.11\cr
Date: \tab 2013-04-03\cr
License: \tab GPL (>=2) | BSD\cr
}
To do \ldots
}
\author{
John Minter

Maintainer: John Minter <jrminter@gmail.com>
}
\references{
TO DO
}
\keyword{ package }
\examples{
require(edp)
make.test.ed.data(dir = './')
cc <- meas.camera.constant()
al.edp <- process.edp.dm(cc.mu.px.A=cc[1], do.log=FALSE)
add.icdd.lines()
}
