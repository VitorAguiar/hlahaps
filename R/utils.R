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

hla_filter_hap <- function(hap) {
  
  if (any(grepl("/", hap)))
    hap %<>%
    unlist %>% 
    strsplit("/") %>% 
    do.call(function(...) expand.grid(..., stringsAsFactors = FALSE), .)
  
  no_na <-
    hap %>% 
    dplyr::select(-subject) %>%
    .[sapply(., function(x) !all(is.na(x)))] %>%
    names()
  
  nmdp_match <- dplyr::inner_join(hap, nmdp, by = no_na)
  
  if (nrow(nmdp_match) == 0)
    nmdp_match <- 
    dplyr::mutate_each(hap, dplyr::funs(allele_to_group), A:DRB1) %>%
    dplyr::inner_join(nmdp, by = no_na)
  
  nmdp_match %>%
    .[!grepl("\\.x$", names(.))] %>%
    `names<-`(gsub("\\.y", "", names(.))) %>%
    dplyr::select(subject, A, B, C, DRB1, AFA_freq, AFA_rank, API_freq, API_rank, 
                  CAU_freq, CAU_rank, HIS_freq, HIS_rank, NAM_freq, NAM_rank)
}