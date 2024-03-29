% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/updateMultiSelect.R
\name{updateMultiSelect}
\alias{updateMultiSelect}
\title{Updates a Select Property}
\usage{
updateMultiSelect(secret, id, property_name, value)
}
\description{
Id refers to a page in a database, and should be normalized using normalizeChromeId().
@param secret API token
@param id Page id to be updated
@param property_name name of property to update (should be a multiselect type property)
@param value value(s) to update. Could be 1 value or multiple, created with c().
}
\details{
@details This will rewrite whatever is already in the property. It will NOT append another select.
}
