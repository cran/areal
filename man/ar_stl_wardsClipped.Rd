% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ar_stl_wardsClipped.R
\docType{data}
\name{ar_stl_wardsClipped}
\alias{ar_stl_wardsClipped}
\title{Clipped Ward Boundaries in St. Louis, 2010}
\format{
A data frame with 28 rows and 2 variables:
\describe{
  \item{WARD}{Ward number}
  \item{geometry}{simple features geometry}
  }
}
\source{
City of St. Louis
}
\usage{
data(ar_stl_wardsClipped)
}
\description{
A simple features data set containing the 2010 Ward boundaries, which
    are used as districts for Alderpersons who serve as elected representatives.
    This version of the ward boundary has been modified so that the wards only
    extend to the Mississippi River shoreline.
}
\examples{
str(ar_stl_wardsClipped)
head(ar_stl_wardsClipped)

}
\keyword{datasets}
