When we attach the package, the [Gourraud et al. (2014)
data](http://dx.doi.org/10.1371/journal.pone.0097282) is loaded. We will
use the individual HG00096 to illustrate how the `get_hla_haps()`
function works:

    library(hlahaps)

    pag

    Source: local data frame [1,910 x 5]

       subject        A        C        B       DRB1
         <chr>    <chr>    <chr>    <chr>      <chr>
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
    ..     ...      ...      ...      ...        ...

    test_ind <- subset(pag, subject == "HG00096")
    test_ind

    Source: local data frame [2 x 5]

      subject        A        C        B       DRB1
        <chr>    <chr>    <chr>    <chr>      <chr>
    1 HG00096 A*01:01g C*07:01g B*08:01g DRB1*03:01
    2 HG00096  A*29:02  C*16:01  B*44:03 DRB1*07:01

    get_hla_haps(test_ind)

    $`original haplotypes:`
    Source: local data frame [2 x 5]

      subject        A        C        B       DRB1
        <chr>    <chr>    <chr>    <chr>      <chr>
    1 HG00096 A*01:01g C*07:01g B*08:01g DRB1*03:01
    2 HG00096  A*29:02  C*16:01  B*44:03 DRB1*07:01

    $`haplotypes found at NMDP table:`
    Source: local data frame [2 x 15]

      subject        A        C        B       DRB1         AFA_freq AFA_rank
        <chr>    <chr>    <chr>    <chr>      <chr>            <chr>    <int>
    1 HG00096 A*01:01g C*07:01g B*08:01g DRB1*03:01 0,01093801052397        2
    2 HG00096 A*29:02g  C*16:01  B*44:03 DRB1*07:01 0,00351599531553       14
    Variables not shown: API_freq <chr>, API_rank <int>, CAU_freq <chr>,
      CAU_rank <int>, HIS_freq <chr>, HIS_rank <int>, NAM_freq <chr>, NAM_rank
      <int>.

    $`haplotypes not found at NMDP table:`
    [1] NA

    $`possible haplotypes in NMDP table:`
    Source: local data frame [14 x 4]

              A        B        C       DRB1
          <chr>    <chr>    <chr>      <chr>
    1  A*01:01g B*08:01g C*07:01g DRB1*03:01
    2  A*01:01g B*08:01g C*07:01g DRB1*07:01
    3  A*01:01g B*08:01g  C*16:01 DRB1*03:01
    4  A*01:01g  B*44:03 C*07:01g DRB1*03:01
    5  A*01:01g  B*44:03 C*07:01g DRB1*07:01
    6  A*01:01g  B*44:03  C*16:01 DRB1*03:01
    7  A*01:01g  B*44:03  C*16:01 DRB1*07:01
    8  A*29:02g B*08:01g C*07:01g DRB1*03:01
    9  A*29:02g B*08:01g C*07:01g DRB1*07:01
    10 A*29:02g B*08:01g  C*16:01 DRB1*03:01
    11 A*29:02g  B*44:03 C*07:01g DRB1*03:01
    12 A*29:02g  B*44:03 C*07:01g DRB1*07:01
    13 A*29:02g  B*44:03  C*16:01 DRB1*03:01
    14 A*29:02g  B*44:03  C*16:01 DRB1*07:01

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

    n_cores <- 50
    doMC::registerDoMC(n_cores)

    results_list <- plyr::dlply(pag, ~subject, . %>% get_hla_haps, .parallel = TRUE)
