% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/getNotionPageContent.R
\name{getNotionPageContent}
\alias{getNotionPageContent}
\title{Get a Page with it's Content}
\usage{
getNotionPageContent(secret, id)
}
\arguments{
\item{secret}{Notion API token}

\item{id}{page id}
}
\value{
list of response with blocks and content
}
\description{
Gets a Notion Page and the content inside it. Does not structure (yet) and instead provides a list of blocks and content.
}
\author{
Eduardo Flores
}
