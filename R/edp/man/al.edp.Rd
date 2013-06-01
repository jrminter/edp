\name{al.edp}
\alias{al.edp}
\docType{data}
\title{
electron diffraction profile from Al
}
\description{
A radial profile from a distortion-corrected electron diffraction
pattern from polycrystalline Al recorded at 200 kV with an nominal
camera length of 340 mm using a FEI CM20UT and a Gatan 894 Ultrascan
CCD camera.
}
\usage{data(al.edp)}
\format{
  A data frame with 900 observations on the following 2 variables.
  \describe{
    \item{\code{r.px}}{a numeric vector containing the radius in pixels}
    \item{\code{i}}{a numeric vector containing the radially-averaged
                    raw intesity}
  }
}
\source{
J. R Minter, recorded 15-Jan-2013
}
\references{
Sample was Ted Pella part number 619.
}
\examples{
data(al.edp)
## maybe data(al.lines) ; make.example.data() ...
}
\keyword{datasets}
