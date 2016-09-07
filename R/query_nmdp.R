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
 
  if (purrr::map_lgl(ind, ~all(is.na(.))) %>% any()) {

    haps_found <- tibble::tibble()
    haps_not_found <- ind
  
  } else {

    query_res <-
      ind %>% 
        split(seq_len(nrow(.))) %>%
        purrr::map(tidyr::drop_na) %>%
        purrr::map(filter_hap) 
  
    haps_found <- dplyr::bind_rows(query_res)

    haps_not_found <- 
      purrr::map_lgl(query_res, ~nrow(.) == 0) %>% 
      ind[., ]
  }

  ind_no_empty <- purrr::discard(ind, ~all(is.na(.))) 

  if (purrr::map_lgl(ind_no_empty, ~any(is.na(.))) %>% any()) {

    all_possible <-
      ind_no_empty %>%
	purrr::map_df(stringr::str_replace_na) %>%
	tidyr::expand_(names(.)) %>%
	purrr::map_df(~readr::parse_character(., na = "NA")) %>%
	split(seq_len(nrow(.))) %>%
	purrr::map_df(filter_hap) %>%
	dplyr::select(A, C, B, DRB1)
    
  } else {

    all_possible <-
      ind_no_empty %>%
      tidyr::expand_(names(.)) %>% 
      split(seq_len(nrow(.))) %>%
      purrr::map_df(filter_hap) %>%
      dplyr::select(A, C, B, DRB1)
  }
  
  list(`original haplotypes` = ind,
       `haplotypes found` = haps_found,
       `haplotypes not found` = haps_not_found,
       `possible haplotypes` = all_possible)
}
