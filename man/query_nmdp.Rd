% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/query_nmdp.R
\name{query_nmdp}
\alias{query_nmdp}
\title{Retrieve haplotype information from NMDP data}
\usage{
query_nmdp(ind)
}
\arguments{
\item{ind}{data.frame. Named data.frame where the names are the loci names
and each row is a haplotype.}
}
\value{
A list with the original haplotypes, haplotypes found at NMDP table,
haplotypes not found at NMDP table and possible haplotypes at NMDP table 
given all combinations of the individual's alleles.
}
\description{
Retrieve haplotype information from NMDP data
}

