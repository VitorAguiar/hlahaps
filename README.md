#### install

First, we need to install `devtools`, if not already installed.

    > install.packages("devtools")

Then, we install `hlahaps` using the `install_github()` function.

    > devtools::install_github("VitorAguiar/hlahaps")

Now, we can attach `hlahaps` as any other R package using the base
function `library()`.

    > library(hlahaps)

#### usage

When we attach the package, the [Gourraud et al. (2014)
data](http://dx.doi.org/10.1371/journal.pone.0097282) is loaded.

    > # showing data as dplyr's tibble diff for better visualization
    > pag %>% dplyr::tbl_df()

    # A tibble: 1,910 x 5
       subject        A        C        B       DRB1
    *    <chr>    <chr>    <chr>    <chr>      <chr>
    1  HG00096 A*01:01g C*07:01g B*08:01g DRB1*03:01
    2  HG00096  A*29:02  C*16:01  B*44:03 DRB1*07:01
    3  HG00097 A*03:01g C*07:02g B*07:02g DRB1*13:03
    4  HG00097 A*24:02g C*07:02g B*07:02g DRB1*15:01
    5  HG00099 A*68:01g C*07:04g B*44:02g DRB1*03:01
    6  HG00099 A*01:01g C*07:01g B*08:01g DRB1*11:01
    7  HG00100 A*01:01g C*07:01g B*08:01g DRB1*03:01
    8  HG00100 A*01:01g  C*06:02  B*57:01 DRB1*07:01
    9  HG00101  A*32:01  C*02:02 B*27:05g DRB1*04:04
    10 HG00101 A*11:01g  C*06:02  B*57:01 DRB1*15:01
    # ... with 1,900 more rows

We will use the individual HG00096 to illustrate how the
`get_hla_haps()` function works:

    > test_ind <- subset(pag, subject == "HG00096")
    > test_ind

      subject        A        C        B       DRB1
    1 HG00096 A*01:01g C*07:01g B*08:01g DRB1*03:01
    2 HG00096  A*29:02  C*16:01  B*44:03 DRB1*07:01

Applying `get_hla_haps`:

    > get_hla_haps(test_ind)

    $`original haplotypes:`
             A        C        B       DRB1
    1 A*01:01g C*07:01g B*08:01g DRB1*03:01
    2  A*29:02  C*16:01  B*44:03 DRB1*07:01

    $`haplotypes found at NMDP table:`
             A        C        B       DRB1         AFA_freq AFA_rank
    1 A*01:01g C*07:01g B*08:01g DRB1*03:01 0,01093801052397        2
    2 A*29:02g  C*16:01  B*44:03 DRB1*07:01 0,00351599531553       14
              API_freq API_rank         CAU_freq CAU_rank         HIS_freq
    1 0,00111271432069      107 0,05986511109347        1 0,01797314328555
    2 0,00023149761030      714 0,01432935490209        5 0,01800969639555
      HIS_rank         NAM_freq NAM_rank
    1        2 0,04333617079119        1
    2        1 0,01273771451614        5

    $`haplotypes not found at NMDP table:`
    [1] A    C    B    DRB1
    <0 rows> (or 0-length row.names)

    $`possible haplotypes in NMDP table:`
    # A tibble: 14 x 4
              A        C        B       DRB1
          <chr>    <chr>    <chr>      <chr>
    1  A*01:01g C*07:01g B*08:01g DRB1*03:01
    2  A*01:01g C*07:01g B*08:01g DRB1*07:01
    3  A*01:01g C*07:01g  B*44:03 DRB1*03:01
    4  A*01:01g C*07:01g  B*44:03 DRB1*07:01
    5  A*01:01g  C*16:01 B*08:01g DRB1*03:01
    6  A*01:01g  C*16:01  B*44:03 DRB1*03:01
    7  A*01:01g  C*16:01  B*44:03 DRB1*07:01
    8  A*29:02g C*07:01g B*08:01g DRB1*03:01
    9  A*29:02g C*07:01g B*08:01g DRB1*07:01
    10 A*29:02g C*07:01g  B*44:03 DRB1*03:01
    11 A*29:02g C*07:01g  B*44:03 DRB1*07:01
    12 A*29:02g  C*16:01 B*08:01g DRB1*03:01
    13 A*29:02g  C*16:01  B*44:03 DRB1*03:01
    14 A*29:02g  C*16:01  B*44:03 DRB1*07:01

`get_hla_haps` returns a list with 4 elements:

1.  A data.frame with the original haplotypes
2.  A data.frame with the haplotypes found at the `nmdp` table
3.  A data.frame with the haplotypes which were not found at the `nmdp`
    table
4.  A data.frame with possible haplotypes at `nmdp` table given the
    individual's alleles

It is possible to apply `get_hla_haps()` to the whole data, e.g. by
using `plyr::dlply()` with a parallel backend provided by
`doMC::registerDoMC()`:

    > n_cores <- 50
    > doMC::registerDoMC(n_cores)
    > 
    > results_list <- plyr::dlply(pag, ~subject, . %>% get_hla_haps, .parallel = TRUE)

With a little hack using `purrr::transpose` and `plyr::ldply` it is
possible to compile a data.frame with info for all individuals. For
example, let's create a data.frame with all the haplotypes found in the
NMDP table:

    > haps_found <-
    +   purrr::transpose(results_list)$`haplotypes found at NMDP table:` %>%
    +   plyr::ldply(rbind, .id = "subject")
    > 
    > haps_found %>% dplyr::tbl_df()

    # A tibble: 24,932 x 15
       subject        A        C        B        DRB1         AFA_freq
        <fctr>    <chr>    <chr>    <chr>       <chr>            <chr>
    1  HG00096 A*01:01g C*07:01g B*08:01g  DRB1*03:01 0,01093801052397
    2  HG00096 A*29:02g  C*16:01  B*44:03  DRB1*07:01 0,00351599531553
    3  HG00097 A*03:01g C*07:02g B*07:02g  DRB1*13:03 0,00008835382251
    4  HG00097 A*24:02g C*07:02g B*07:02g  DRB1*15:01 0,00147120635098
    5  HG00099 A*68:01g C*07:04g B*44:02g  DRB1*03:01 0,00007084284408
    6  HG00099 A*01:01g C*07:01g B*08:01g DRB1*11:01g 0,00023267289505
    7  HG00100 A*01:01g C*07:01g B*08:01g  DRB1*03:01 0,01093801052397
    8  HG00100 A*01:01g C*06:02g B*57:01g  DRB1*07:01 0,00208686967270
    9  HG00101  A*32:01 C*02:02g B*27:05g  DRB1*04:04 0,00000551248803
    10 HG00101 A*11:01g C*06:02g B*57:01g  DRB1*15:01 0,00000000000000
    # ... with 24,922 more rows, and 9 more variables: AFA_rank <int>,
    #   API_freq <chr>, API_rank <int>, CAU_freq <chr>, CAU_rank <int>,
    #   HIS_freq <chr>, HIS_rank <int>, NAM_freq <chr>, NAM_rank <int>
