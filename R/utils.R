allele_to_group <- function(alleles, groups = hla_groups) {
    
  f <- Vectorize(function(allele) {
   
   if (is.na(allele)) return(allele)

   x <-
      stringr::str_replace(allele, "\\*", "\\\\*") %>% 
      stringr::str_c("^(", ., ")(:|$|[NQLS])") %>%
      stringr::str_detect(names(groups), .)
    
    if (any(x)) {
      groups[x] %>% unique() %>% stringr::str_c(collapse = "/")
    } else {
      allele
    }
  }, vectorize.args = "allele")
  
  f(alleles)
}

format_haps_data <- function(df) {
  df <- dplyr::rename(df, subject = X1)
 
  df_1 <- 
    dplyr::select(df, subject, A.1:DRB1.1) %>%
    purrr::set_names(stringr::str_replace(names(.), "\\.\\d$", ""))

  df_2 <- 
    dplyr::select(df, subject, A.2:DRB1.2) %>%
    purrr::set_names(stringr::str_replace(names(.), "\\.\\d$", ""))

  dplyr::bind_rows(df_1, df_2) %>% dplyr::arrange(subject)
}

filter_hap <- function(hap) {
  
  hap <- hap %>% purrr::discard(~all(is.na(.)))
  
  if (any(stringr::str_detect(hap, "/")))
    hap <- 
      hap %>%  
      unlist() %>% 
      strsplit("/") %>% 
      do.call(function(...) expand.grid(..., stringsAsFactors = FALSE), .)
  
  nmdp_match <- dplyr::inner_join(hap, nmdp, by = names(hap))
  
  if (nrow(nmdp_match) == 0) {
    hap_g <- 
      hap %>%
      dplyr::mutate_all(allele_to_group) %>%
      dplyr::bind_rows(hap) %>%
      tidyr::expand_(names(hap))
    
    nmdp_match <- dplyr::inner_join(hap_g, nmdp, by = names(hap_g))
  }

  nmdp_match %>%
    dplyr::select(A, C, B, DRB1, dplyr::everything())
}
