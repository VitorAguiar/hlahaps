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
  data.table::setnames(1, "subject") %>%
  {
    dplyr::bind_rows(dplyr::select(., subject, A.1:DRB1.1) %>%
                       `names<-`(gsub("\\.\\d$", "", names(.))),
                     dplyr::select(., subject, A.2:DRB1.2) %>%
                       `names<-`(gsub("\\.\\d$", "", names(.)))) %>%
      dplyr::arrange(subject)
  } %>% 
  as.data.frame()

hla_filter_hap <- function(hap) {
  
  if (any(grepl("/", hap)))
    hap %<>%
    unlist %>% 
    strsplit("/") %>% 
    do.call(function(...) expand.grid(..., stringsAsFactors = FALSE), .)
  
  no_na <-
    sapply(hap, function(x) !all(is.na(x))) %>%
    which() %>% 
    names()
  
  nmdp_match <- dplyr::inner_join(hap[no_na], nmdp, by = no_na)
  
  if (nrow(nmdp_match) == 0)
    nmdp_match <- 
    dplyr::mutate_each_(hap[no_na], dplyr::funs(allele_to_group), no_na) %>%
    dplyr::inner_join(nmdp, by = no_na)

  nmdp_match
}