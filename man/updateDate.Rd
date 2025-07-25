% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/updateDate.R
\name{updateDate}
\alias{updateDate}
\title{Updates a Date property}
\usage{
updateDate(secret, id, property_name, value)
}
\arguments{
\item{secret}{API token}

\item{id}{Page id to be updated}

\item{property_name}{name of property to update (should be a date type property)}

\item{value}{value to update}
}
\value{
list
}
\description{
Id refers to a page in a database, and should be normalized using normalizeChromeId().
}
