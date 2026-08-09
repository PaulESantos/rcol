# rcol

`rcol` is an R client for the [Catalogue of
Life](https://www.catalogueoflife.org) via the
[ChecklistBank](https://www.checklistbank.org) API
(<https://api.checklistbank.org>). It allows you to verify and match
scientific names, retrieve hierarchical classifications, look up
datasets, taxa, synonyms, vernacular names, and geographic
distributions, and run ChecklistBank parsers — against **any** public
dataset in ChecklistBank or the latest Catalogue of Life release. It is
modelled on the conventions of
[`rgbif`](https://docs.ropensci.org/rgbif/) and
[`taxadb`](https://docs.ropensci.org/taxadb/).

> **Note on Origin & Architectural Evolution**: This package builds upon
> the original [`rcol` project by Catalogue of
> Life](https://github.com/CatalogueOfLife/rcol)
> (<https://catalogueoflife.github.io/rcol/>). This version introduces
> substantial architectural enhancements to simplify scientific
> workflows, including: - **Direct Scientific Name Support**: Pass
> scientific names directly (e.g., `"Panthera leo"` or
> `"Werneria nubigena"`) to downstream functions without needing prior
> manual ID lookups. - **Vectorized Multi-Species Queries**: Seamlessly
> pass character vectors of multiple species (e.g.,
> `c("Werneria nubigena", "Panthera leo")`) and receive clean,
> concatenated tidy data frames. - **Species Traceability**: Preserves
> species association (`scientific_name` column) across synonyms,
> vernacular/common names, and distribution records. - **Clean Name
> Verification**:
> [`col_check_name()`](https://paulesantos.github.io/rcol/reference/clb_resolve_name.md)
> returns an essential 9-column resolution summary showing accepted
> names, status, and IDs. - **Flexible Classification Extraction**:
> [`col_classification()`](https://paulesantos.github.io/rcol/reference/col_shortcuts.md)
> supports both Long format and desanided Wide format (`wide = TRUE`).

There are two parallel families of functions:

- **`col_*()`** convenience functions that target the **latest extended
  Catalogue of Life release** (`"3LXR"`). On first use, the release key
  is pinned in session
  ([`col_key()`](https://paulesantos.github.io/rcol/reference/col_key.md)),
  ensuring long-running jobs are never disrupted by mid-session release
  updates. Use
  [`col_refresh()`](https://paulesantos.github.io/rcol/reference/col_refresh.md)
  to re-pin.
- **`clb_*()`** universal low-level functions that accept an explicit
  `dataset =` argument (e.g., `"COL25"`, `2099`) to query any dataset in
  ChecklistBank.

## Installation

Install the package from GitHub:

``` r

# install.packages("pak")
pak::pak("PaulESantos/rcol")

# or
# install.packages("remotes")
remotes::install_github("PaulESantos/rcol")
```

Documentation is published at <https://paulesantos.github.io/rcol/>.

## Quick start

### 1. Name Verification & Matching

``` r

library(rcol)

# High-level clean verification (9 columns) for 1 or multiple species
col_check_name(c("Werneria nubigena", "Panthera leo", "Schinus molle"))
#> # A tibble: 3 × 9
#>   queried_name      matched_name      status   accepted_name accepted_authorship
#>   <chr>             <chr>             <chr>    <chr>         <chr>              
#> 1 Werneria nubigena Werneria nubigena synonym  Rockhausenia… (Kunth) D.J.N.Hind 
#> 2 Panthera leo      Panthera leo      accepted Panthera leo  (Linnaeus, 1758)   
#> 3 Schinus molle     Schinus molle     accepted Schinus molle L.                 
#> # ℹ 4 more variables: accepted_rank <chr>, accepted_id <chr>, match <lgl>,
#> #   match_type <chr>

# Raw matching against the latest Catalogue of Life release
col_match("Panthera leo")
#> # A tibble: 1 × 17
#>   match match_type usage_id name         authorship     rank  status accepted_id
#>   <lgl> <chr>      <chr>    <chr>        <chr>          <chr> <chr>  <chr>      
#> 1 TRUE  variant    4CGXP    Panthera leo (Linnaeus, 17… spec… accep… 4CGXP      
#> # ℹ 9 more variables: accepted_name <chr>, accepted_authorship <chr>,
#> #   accepted_rank <chr>, code <chr>, label <chr>, parent_id <chr>,
#> #   names_index_id <int>, names_index_match_type <chr>, classification <list>

# Disambiguate with rank and nomenclatural code
col_match("Abies alba", rank = "species", code = "botanical")
#> # A tibble: 1 × 17
#>   match match_type usage_id name       authorship rank    status   accepted_id
#>   <lgl> <chr>      <chr>    <chr>      <chr>      <chr>   <chr>    <chr>      
#> 1 TRUE  variant    8K9Y     Abies alba Mill.      species accepted 8K9Y       
#> # ℹ 9 more variables: accepted_name <chr>, accepted_authorship <chr>,
#> #   accepted_rank <chr>, code <chr>, label <chr>, parent_id <chr>,
#> #   names_index_id <int>, names_index_match_type <chr>, classification <list>

# See all candidate matches (homonyms), not just the best one
col_match_verbose("Oenanthe")
#> # A tibble: 2 × 16
#>   primary usage_id name     authorship    rank  status accepted_id accepted_name
#>   <lgl>   <chr>    <chr>    <chr>         <chr> <chr>  <chr>       <chr>        
#> 1 TRUE    679Q     Oenanthe L.            genus accep… 679Q        Oenanthe     
#> 2 FALSE   679P     Oenanthe Vieillot, 18… genus accep… 679P        Oenanthe     
#> # ℹ 8 more variables: accepted_authorship <chr>, accepted_rank <chr>,
#> #   code <chr>, label <chr>, parent_id <chr>, names_index_id <int>,
#> #   names_index_match_type <chr>, classification <list>

# Match many names at once in parallel
col_match_checklist(c("Panthera leo", "Bufo bufo", "Abies alba"))
#> # A tibble: 3 × 18
#>   verbatim_name match match_type usage_id name         authorship   rank  status
#>   <chr>         <lgl> <chr>      <chr>    <chr>        <chr>        <chr> <chr> 
#> 1 Panthera leo  TRUE  variant    4CGXP    Panthera leo (Linnaeus, … spec… accep…
#> 2 Bufo bufo     TRUE  variant    NP2D     Bufo bufo    (Linnaeus, … spec… accep…
#> 3 Abies alba    TRUE  variant    8K9Y     Abies alba   Mill.        spec… accep…
#> # ℹ 10 more variables: accepted_id <chr>, accepted_name <chr>,
#> #   accepted_authorship <chr>, accepted_rank <chr>, code <chr>, label <chr>,
#> #   parent_id <chr>, names_index_id <int>, names_index_match_type <chr>,
#> #   classification <list>
```

To match against a specific dataset instead of the latest COL release,
use the `clb_*()` form with a `dataset =` key or alias:

``` r

clb_match("Felis catus", dataset = "COL25")          # 2025 annual release
#> # A tibble: 1 × 17
#>   match match_type usage_id name        authorship     rank   status accepted_id
#>   <lgl> <chr>      <chr>    <chr>       <chr>          <chr>  <chr>  <chr>      
#> 1 TRUE  variant    3DXV3    Felis catus Linnaeus, 1758 speci… accep… 3DXV3      
#> # ℹ 9 more variables: accepted_name <chr>, accepted_authorship <chr>,
#> #   accepted_rank <chr>, code <chr>, label <chr>, parent_id <chr>,
#> #   names_index_id <int>, names_index_match_type <chr>, classification <list>
clb_match("Macrocystis pyrifera", dataset = 2099)    # public dataset by key
#> # A tibble: 1 × 17
#>   match match_type usage_id name  authorship rank  status accepted_id
#>   <lgl> <chr>      <chr>    <chr> <chr>      <chr> <chr>  <chr>      
#> 1 FALSE none       <NA>     <NA>  <NA>       <NA>  <NA>   <NA>       
#> # ℹ 9 more variables: accepted_name <chr>, accepted_authorship <chr>,
#> #   accepted_rank <chr>, code <chr>, label <chr>, parent_id <chr>,
#> #   names_index_id <chr>, names_index_match_type <chr>, classification <list>
```

### 2. Classification, Synonyms, Vernaculars & Distribution

All functions work seamlessly with direct scientific names, IDs,
character vectors, or match data frames:

``` r

# Hierarchical classification in Wide or Long format
col_classification("Schinus molle", wide = TRUE)
#> # A tibble: 1 × 23
#>   match match_type usage_id name          authorship rank    status  accepted_id
#>   <lgl> <chr>      <chr>    <chr>         <chr>      <chr>   <chr>   <chr>      
#> 1 TRUE  variant    4V8GC    Schinus molle L.         species accept… 4V8GC      
#> # ℹ 15 more variables: accepted_name <chr>, accepted_authorship <chr>,
#> #   accepted_rank <chr>, code <chr>, label <chr>, parent_id <chr>,
#> #   names_index_id <int>, names_index_match_type <chr>, kingdom <chr>,
#> #   phylum <chr>, class <chr>, order <chr>, family <chr>, genus <chr>,
#> #   species <chr>

# Synonyms for 1 or multiple species
col_synonyms(c("Werneria nubigena", "Panthera leo"))
#> # A tibble: 16 × 6
#>    accepted_name         scientific_name authorship synonym_type rank  full_name
#>    <chr>                 <chr>           <chr>      <chr>        <chr> <chr>    
#>  1 Rockhausenia nubigena Werneria nubig… Kunth      homotypic    spec… Werneria…
#>  2 Rockhausenia nubigena Oresigonia gra… Willd. ex… heterotypic  spec… Oresigon…
#>  3 Rockhausenia nubigena Oresigonia lat… Willd. ex… heterotypic  spec… Oresigon…
#>  4 Rockhausenia nubigena Oribasia acaul… DC.        heterotypic  spec… Oribasia…
#>  5 Rockhausenia nubigena Werneria disti… Kunth      heterotypic  spec… Werneria…
#>  6 Rockhausenia nubigena Werneria dombe… (Wedd.) H… heterotypic  spec… Werneria…
#>  7 Rockhausenia nubigena Werneria mocin… DC.        heterotypic  spec… Werneria…
#>  8 Rockhausenia nubigena Werneria nubig… Wedd.      heterotypic  subv… Werneria…
#>  9 Rockhausenia nubigena Werneria nubig… Wedd.      heterotypic  subv… Werneria…
#> 10 Rockhausenia nubigena Werneria nubig… Wedd.      heterotypic  vari… Werneria…
#> 11 Rockhausenia nubigena Werneria nubig… Wedd.      heterotypic  vari… Werneria…
#> 12 Rockhausenia nubigena Werneria nubig… <NA>       heterotypic  vari… Werneria…
#> 13 Rockhausenia nubigena Werneria steub… Hieron.    heterotypic  spec… Werneria…
#> 14 Rockhausenia nubigena Werneria stueb… Hieron.    heterotypic  spec… Werneria…
#> 15 Panthera leo          Felis leo       Linnaeus,… homotypic    spec… Felis le…
#> 16 Panthera leo          Panthera leo n… (de Blain… heterotypic  subs… Panthera…

# Vernacular / common names with species association (scientific_name column)
col_vernacular(c("Werneria nubigena", "Panthera leo"))
#> # A tibble: 206 × 7
#>    scientific_name       name               language latin country area  remarks
#>    <chr>                 <chr>              <chr>    <chr> <chr>   <chr> <chr>  
#>  1 Rockhausenia nubigena Chicoria blanca    spa      Chic… <NA>    <NA>  <NA>   
#>  2 Rockhausenia nubigena Cóndor cebolla     spa      Cond… <NA>    <NA>  <NA>   
#>  3 Panthera leo          African Lion       eng      Afri… <NA>    <NA>  <NA>   
#>  4 Panthera leo          Afrikaanse Leeuw   nld      Afri… <NA>    <NA>  Contri…
#>  5 Panthera leo          Afrikanischer Löwe deu      Afri… DE      <NA>  <NA>   
#>  6 Panthera leo          Agrzam             shi      Agrz… <NA>    <NA>  Contri…
#>  7 Panthera leo          Ambessa            amh      Ambe… <NA>    <NA>  <NA>   
#>  8 Panthera leo          Arslon             uzb      Arsl… <NA>    <NA>  Contri…
#>  9 Panthera leo          Aslan              gag      Aslan <NA>    <NA>  Contri…
#> 10 Panthera leo          Dzata              ewe      Dzata <NA>    <NA>  Contri…
#> # ℹ 196 more rows

# Geographic distribution in tidy format
col_distribution(c("Werneria nubigena", "Schinus molle"))
#> # A tibble: 54 × 1
#>    area                                
#>    <chr>                               
#>  1 Mexico (Chiapas)                    
#>  2 Guatemala                           
#>  3 Costa Rica                          
#>  4 Panama                              
#>  5 Ecuador                             
#>  6 Peru                                
#>  7 Bolivia (Cochabamba, La Paz, Tarija)
#>  8 Portugal [I]                        
#>  9 Spain [I]                           
#> 10 Gibraltar [I]                       
#> # ℹ 44 more rows

# Details of a name usage
col_usage("Panthera leo")
#> # A tibble: 1 × 9
#>   id    scientific_name authorship       rank    status  label parent_id extinct
#>   <chr> <chr>           <chr>            <chr>   <chr>   <chr> <chr>     <lgl>  
#> 1 4CGXP Panthera leo    (Linnaeus, 1758) species accept… Pant… 6DBT      FALSE  
#> # ℹ 1 more variable: name <list>
```

### 3. Tree Navigation & Search

``` r

# Walk the COL tree roots (Domains / Realms)
roots <- col_tree()

# Get direct child species under a genus
col_children("Panthera")
#> # A tibble: 18 × 10
#>    datasetKey id    parentId rank    status    count childCount name  authorship
#>         <int> <chr> <chr>    <chr>   <chr>     <int>      <int> <chr> <chr>     
#>  1     315834 TZBNY 6DBT     species provisio…     0          0 Leo … Brehm, 18…
#>  2     315834 TZ9SL 6DBT     species provisio…     0          0 Leo … Brehm, 18…
#>  3     315834 TZ8S4 6DBT     species provisio…     0          0 Leo … Gray, 1843
#>  4     315834 V32ZM 6DBT     species provisio…     0          0 Leo … Kretzoi, …
#>  5     315834 R9G88 6DBT     species provisio…     0          0 Pant… Fitzinger…
#>  6     315834 R9G8X 6DBT     species provisio…     0          0 Pant… Stinnesbe…
#>  7     315834 R9G95 6DBT     species provisio…     0          0 Pant… Tseng, Wa…
#>  8     315834 R9GBB 6DBT     species accepted      0          0 Pant… Kretzoï, …
#>  9     315834 4CGXP 6DBT     species accepted      0          3 Pant… (Linnaeus…
#> 10     315834 4CGXQ 6DBT     species accepted      0          1 Pant… (Linnaeus…
#> 11     315834 4CGXR 6DBT     species accepted      0         10 Pant… (Linnaeus…
#> 12     315834 V2VKY 6DBT     species provisio…     0          0 Pant… Hemmer, 2…
#> 13     315834 R9GXP 6DBT     species accepted      0          0 Pant… (Goldfuss…
#> 14     315834 4CGXS 6DBT     species accepted      0          2 Pant… (Linnaeus…
#> 15     315834 4CGXT 6DBT     species accepted      0          1 Pant… (Schreber…
#> 16     315834 R9H53 6DBT     species provisio…     0          1 Pant… Schreber,…
#> 17     315834 R9H5S 6DBT     species provisio…     0          0 Pant… Mazák, Ch…
#> 18     315834 T673T 6DBT     species provisio…     0          0 Tigr… Fitzinger…
#> # ℹ 1 more variable: full_name <chr>

# Full-text search with rank and status filters
col_usage_search("Panthera", rank = "species", status = "accepted")
#> <clb> result: 46 rows (total: 46)
#> # A tibble: 46 × 11
#>    id    scientific_name         authorship rank  status label parent_id extinct
#>    <chr> <chr>                   <chr>      <chr> <chr>  <chr> <chr>     <lgl>  
#>  1 4P5TS Pseudopanthera oberthu… (Alphérak… spec… accep… Pseu… VJ7H5     FALSE  
#>  2 VYR7  Clemensia panthera      Schaus, 1… spec… accep… Clem… 925L7     NA     
#>  3 4MYJF Prosthechea panthera    (Rchb.f.)… spec… accep… Pros… 8W2Q9     NA     
#>  4 4CGXS Panthera tigris         (Linnaeus… spec… accep… Pant… 6DBT      FALSE  
#>  5 4CGXR Panthera pardus         (Linnaeus… spec… accep… Pant… 6DBT      FALSE  
#>  6 N36PJ Cryptorhopalum panthera Herrmann,… spec… accep… Cryp… N366K     NA     
#>  7 R9GBB Panthera gombaszoegens… Kretzoï, … spec… accep… Pant… 6DBT      NA     
#>  8 4P5TL Pseudopanthera chrysop… Wehrli, 1… spec… accep… Pseu… VJ7H5     FALSE  
#>  9 6WVYL Rhotana panthera        Zelazny, … spec… accep… Rhot… SLV3F     NA     
#> 10 4CGXQ Panthera onca           (Linnaeus… spec… accep… Pant… 6DBT      FALSE  
#> # ℹ 36 more rows
#> # ℹ 3 more variables: name <list>, group <chr>, classification <list>
```

### 4. Parsers

``` r

# Parse a scientific name into its atomic components
clb_parse_name("Abies alba Mill. var. alpina")
#> # A tibble: 1 × 9
#>   scientificName    rank  genus specificEpithet infraspecificEpithet type  label
#>   <chr>             <chr> <chr> <chr>           <chr>                <chr> <chr>
#> 1 Abies alba var. … vari… Abies alba            alpina               scie… Abie…
#> # ℹ 2 more variables: labelHtml <chr>, parsed <lgl>
```

## Catalogue of Life Releases

The Catalogue of Life is published in two cadences (monthly and annual)
and two flavours (base and extended `XR`). Every `clb_*()` function
takes a `dataset =` argument; helpful aliases resolve to the latest of
each:

``` r

clb_col_release("monthly")                  # "3LR"   latest monthly base
#> [1] "3LR"
clb_col_release("monthly", extended = TRUE) # "3LXR"  latest monthly extended
#> [1] "3LXR"
clb_col_release("annual")                   # e.g. "COL25"
#> [1] "COL25"

clb_usage_search("Felidae", dataset = "COL25")
#> <clb> result: 1 rows (total: 1)
#> # A tibble: 1 × 11
#>   id    scientific_name authorship          rank  status label parent_id extinct
#>   <chr> <chr>           <chr>               <chr> <chr>  <chr> <chr>     <lgl>  
#> 1 623RM Felidae         Fischer de Waldhei… fami… accep… Feli… 4DL       FALSE  
#> # ℹ 3 more variables: name <list>, group <chr>, classification <list>
```

## Configuration

The base URL defaults to the production API and can be redirected with
the `CLB_BASE_URL` environment variable:

``` r

Sys.setenv(CLB_BASE_URL = "https://api.dev.checklistbank.org")
```

## Citation

To cite `rcol` in publications, please use:

``` r

citation("rcol")
#> To cite rcol in publications, please use:
#> 
#> To cite the rcol package in publications, please use:
#> 
#>   Santos Andrade, P. E., & Döring, M. (2026). rcol: R Client for the
#>   Catalogue of Life / ChecklistBank API. R package version 0.1.0.
#>   https://paulesantos.github.io/rcol/
#> 
#> The taxonomic data and API services accessed by this package are
#> provided by:
#> 
#>   Bánki, O., Döring, M., & Ower, G. (2026). Catalogue of Life /
#>   ChecklistBank API. ChecklistBank Infrastructure.
#>   https://doi.org/10.48580/d4tm
#> 
#> To see these entries in BibTeX format, use 'print(<citation>,
#> bibtex=TRUE)', 'toBibtex(.)', or set
#> 'options(citation.bibtex.max=999)'.
```

- **Package Citation**: Santos Andrade, P. E. & Döring, M. (2026).
  *rcol: R Client for the Catalogue of Life / ChecklistBank API*. R
  package version 0.0.1. URL: <https://github.com/PaulESantos/rcol>
- **Catalogue of Life Data Citation**: Bánki, O., Döring, M., Ower, G.,
  et al. (2026). *Catalogue of Life ChecklistBank API*.
  <https://doi.org/10.48580/d4tm>

## License

- **R Code**: Released under the [MIT
  License](https://opensource.org/licenses/MIT) © 2026 Paul Efren Santos
  Andrade, Markus Döring & Catalogue of Life.
- **Catalogue of Life Data**: Distributed under the [Creative Commons
  Attribution 4.0 International License (CC BY
  4.0)](https://creativecommons.org/licenses/by/4.0/).
