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
get_hla_haps <- function(ind) {
  
  hap_found <-
    ind %>% 
    split(1:nrow(.)) %>%
    lapply(. %>% hla_filter_hap) 
  
  hap_not_found <-
    hap_found %>%
    sapply(function(x) nrow(x) == 0)
  
  hap_found_df <- dplyr::bind_rows(hap_found[!hap_not_found])
    
  all_possible <-
    tidyr::expand(ind, subject, A, B, C, DRB1) %>% 
    split(1:nrow(.)) %>%
    lapply(. %>% hla_filter_hap() %>% dplyr::select(A:DRB1)) %>%
    .[sapply(., function(i) nrow(i) > 0)] %>%
    dplyr::bind_rows()
  
  out_list <- 
    list(`original haplotypes:` = ind,
         `haplotypes found at NMDP table:` = hap_found_df,
         `haplotypes not found at NMDP table:` = ind[hap_not_found, ],
         `possible haplotypes in NMDP table:` = all_possible)
  
  out_list[sapply(out_list, function(x) nrow(x) == 0)] <- NA
  
  out_list
}
