\name{al.lines}
\alias{al.lines}
\docType{data}
\title{
Al diffraction lines from ICDD card 04-0787
}
\description{
This contains the d-spacing (A), the relative intensity, and the
(h,k,l) indices for cubic Al.
}
\usage{data(al.lines)}
\format{
  A data frame with 9 observations on the following 5 variables.
  \describe{
    \item{\code{d.A.}}{a numeric vector with the d-spacing in A}
    \item{\code{Int}}{a numeric vector with the relative intensity}
    \item{\code{h}}{a numeric vector with the h index}
    \item{\code{k}}{a numeric vector with the k index}
    \item{\code{l}}{a numeric vector with the l index}
  }
}
\details{
These were obained from ICDD card number 04-0787
}
\source{
ICDD database 2003
}
\examples{
data(al.lines)
## maybe str(al.lines) ; plot(al.lines) ...
}
\keyword{datasets}
