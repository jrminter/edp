\name{make.test.ed.data}
\alias{make.test.ed.data}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Make test electron diffraction data from Al
}
\description{
This creates the required electron diffraction radial profile file
('Al-dc-ra.csv') and the required ICDD diffraction line
file('04-0787-Al-Fm3m.csv') in the specified directory to permit a
user to test the other functions.
}
\usage{
make.test.ed.data(dir = './')
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{dir}{
This is the desired directory. The default is the current directory.
}
}
\value{
None returned, but the data frames al.edp and al.lines are loaded
into the workspace.
}

\author{
John Minter
}

\examples{
# Make the test data in the current directory
require(edp)
make.test.ed.data('./')

}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{test data}
\keyword{Al}% __ONLY ONE__ keyword per line
