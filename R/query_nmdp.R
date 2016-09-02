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
  
  hap_found <-
    ind %>% 
    split(seq_len(nrow(.))) %>%
    lapply(. %>% filter_hap()) 
  
  hap_not_found <- ind[sapply(hap_found, function(x) nrow(x) == 0), ]
  
  hap_found_df <- dplyr::bind_rows(hap_found) 
  
  ind <- ind[sapply(ind, function(x) !all(is.na(x)))]
  
  all_possible <-
    tidyr::expand_(ind, names(ind)) %>% 
    split(seq_len(nrow(.))) %>%
    lapply(. %>% filter_hap()) %>%
    dplyr::bind_rows() %>%
    dplyr::select(A, C, B, DRB1)
  
  list(`original haplotypes` = ind,
       `haplotypes found` = hap_found_df,
       `haplotypes not found` = hap_not_found,
       `possible haplotypes` = all_possible)
}
