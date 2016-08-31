allele_to_group <- function(alleles, groups = hla_groups) 
  alleles %>% 
  lapply(. %>% 
  {
    x <- 
      gsub("\\*", "\\\\*", .) %>% 
      paste0("^(", ., ")(:|$|[NQLS])") %>%
      grep(., names(groups))
    
    if (length(x)) {
      groups[x] %>% unique() %>% paste(collapse = "/")
    } else {
      .
    }
  }) %>%
  unlist()

format_haps_data <- function(dataset) 
  dataset %>%
    dplyr::rename(subject = X1) %>%
    {
      dplyr::bind_rows(dplyr::select(., subject, A.1:DRB1.1) %>%
                       `names<-`(gsub("\\.\\d$", "", names(.))),
		       dplyr::select(., subject, A.2:DRB1.2) %>%
		       `names<-`(gsub("\\.\\d$", "", names(.)))) %>%
      dplyr::arrange(subject)
    }

hla_filter_hap <- function(hap) {
  
  if (any(grepl("/", hap)))
    hap <- 
      hap %>%
      unlist() %>% 
      strsplit("/") %>% 
      do.call(function(...) expand.grid(..., stringsAsFactors = FALSE), .)
  
  hap <- hap[sapply(hap, function(x) !all(is.na(x)))]
  
  nmdp_match <- dplyr::inner_join(hap, nmdp, by = names(hap))
  
  if (nrow(nmdp_match) == 0) {
    hap_g <- 
      hap %>% 
      dplyr::mutate_each(dplyr::funs(. %>% allele_to_group())) %>%
      dplyr::bind_rows(hap) %>%
      tidyr::expand_(names(hap))
    
    nmdp_match <- dplyr::inner_join(hap_g, nmdp, by = names(hap_g))
  }

  nmdp_match %>%
    dplyr::select(A, C, B, DRB1, dplyr::everything())
}
