devtools::load_all("/home/vitor/hlahaps")

hla_groups_df <- 
  readxl::read_excel("~/kelly/mmc1.xls", col_names = FALSE) %>% 
  tidyr::drop_na() %>%
  purrr::set_names(c("group", "allele")) %>%
  tidyr::separate_rows(allele, sep = ",") 

hla_groups <- hla_groups_df$group %>% `names<-`(hla_groups_df$allele)

nmdp <- 
  readr::read_tsv("~/kelly/HLA_freq_NMDP_ABCDR.txt") %>%
  dplyr::select(A, B, C, DRB1, AFA_freq, AFA_rank, API_freq, API_rank, CAU_freq,
		CAU_rank, HIS_freq, HIS_rank, NAM_freq, NAM_rank) %>%
  dplyr::mutate_at(dplyr::vars(dplyr::ends_with("freq")),
  . %>% readr::parse_double(locale = readr::locale(decimal_mark = ",")))

pag <- 
  readr::read_tsv("~/kelly/PAG_haplotypes_groups_2dig.txt") %>%
  format_haps_data()

devtools::use_data(hla_groups_df, hla_groups, nmdp, pag, 
		   internal = FALSE, overwrite = TRUE)
