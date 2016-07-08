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
  data.table::fread("~/kelly/HLA_freq_NMDP_ABCDR.txt", sep = "\t", 
                    select = c("A", "B", "C", "DRB1", "AFA_freq", "AFA_rank", 
                               "API_freq", "API_rank", "CAU_freq", "CAU_rank", 
                               "HIS_freq", "HIS_rank", "NAM_freq", "NAM_rank")) 

pag <- 
  data.table::fread("~/kelly/PAG_haplotypes_groups_2dig.txt", sep = "\t") %>%
  data.table::setnames("V1", "subject") %>%
  {
    dplyr::bind_rows(dplyr::select(., subject, A.1:DRB1.1) %>%
                       `names<-`(gsub("\\.\\d$", "", names(.))),
                     dplyr::select(., subject, A.2:DRB1.2) %>%
                       `names<-`(gsub("\\.\\d$", "", names(.)))) %>%
      dplyr::arrange(subject)
  }

devtools::use_data(hla_groups, nmdp, pag, internal = FALSE, overwrite = TRUE)
