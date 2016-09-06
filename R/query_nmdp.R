#' Retrieve haplotype information from NMDP data
#' 
#' @param ind data.frame. Named data.frame where the names are the loci names
#' and each row is a haplotype.
#' 
#' @return A list with the original haplotypes, haplotypes found at NMDP table,
#' haplotypes not found at NMDP table and possible haplotypes at NMDP table 
#' given all combinations of the individual's alleles.
#' @export
#'  
query_nmdp <- function(ind) {
  
  ind <- dplyr::select(ind, -subject)
  
  haps_found <-
    ind %>% 
    split(seq_len(nrow(.))) %>%
    purrr::map_df(filter_hap) 
  
  haps_not_found <- 
    dplyr::anti_join(ind, haps_found, by = c("A", "B", "C", "DRB1")) 

  ind <- purrr::discard(ind, ~all(is.na(.))) 
  
  all_possible <-
    tidyr::expand_(ind, names(ind)) %>% 
    split(seq_len(nrow(.))) %>%
    purrr::map_df(filter_hap) %>%
    dplyr::select(A, C, B, DRB1)
  
  list(`original haplotypes` = ind,
       `haplotypes found` = haps_found,
       `haplotypes not found` = haps_not_found,
       `possible haplotypes` = all_possible)
}
