library(magrittr)

hla_groups <- 
  readxl::read_excel("~/kelly/mmc1.xls", col_names = FALSE) %>%
  split(cumsum(grepl("-- [^ ] --", .[[1]]))) %>%
  lapply(. %>% `names<-`(c("group", "allele"))) %>%
  lapply(. %>% dplyr::filter(complete.cases(.))) %>%
  dplyr::bind_rows() %>% 
  split(.$group) %>%
  lapply(. %>% dplyr::select(allele) %>% unlist() %>% 
           strsplit(",") %>% unlist()) %>%
  plyr::ldply(as.data.frame) %>%
  `names<-`(c("group", "allele")) %>%
  purrr::map_if(is.factor, as.character) %>%
  {
    g <- .$group
    names(g) <- .$allele
    g
  }

nmdp <- 
  data.table::fread("~/kelly/HLA_freq_NMDP_ABCDR.txt") %>% 
  dplyr::select(A, B, C, DRB1, AAFA_freq:VIET_rank) %>%
  dplyr::tbl_df()

devtools::use_data(hla_groups, nmdp, internal = FALSE, overwrite = TRUE)