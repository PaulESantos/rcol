# Getting started with rcol

`rcol` wraps the [ChecklistBank](https://www.checklistbank.org) API to
give R users idiomatic access to the [Catalogue of
Life](https://www.catalogueoflife.org) (COL) and every other public
dataset in ChecklistBank.

``` r

library(rcol)
```

## Two function families

Most functions come in two forms:

- **`col_*()`** target the latest extended COL release without needing a
  `dataset` argument. The `"3LXR"` release alias is resolved once to its
  integer dataset key and cached for the session via
  [`col_key()`](https://paulesantos.github.io/rcol/reference/col_key.md),
  so long-running work is not disrupted by a new release published
  midway. Use
  [`col_refresh()`](https://paulesantos.github.io/rcol/reference/col_refresh.md)
  to deliberately re-pin to the newest release.
- **`clb_*()`** take a `dataset =` argument and work against any dataset
  in ChecklistBank or historical COL releases.

``` r

col_key()      # Pinned integer dataset key of the latest extended release
#> [1] 315834
col_refresh()  # Re-resolve to the newest release
#> Pinned COL to "COL26.7 XR" (dataset 315834).
```

## Choosing a dataset

Almost every function takes a `dataset =` argument identifying which
checklist to work against. You can pass:

- a numeric dataset key, e.g. `3` (the COL project),
- a dataset alias such as `"COL25"` (the 2025 annual release), or
- one of the *magic* COL release aliases that always resolve to the most
  recent release (`"3LR"` for monthly base, `"3LXR"` for monthly
  extended).

``` r

clb_col_release("monthly")                  # "3LR"   latest monthly base release
#> [1] "3LR"
clb_col_release("monthly", extended = TRUE) # "3LXR"  latest monthly extended release
#> [1] "3LXR"
clb_col_release("annual")                   # e.g. "COL25"
#> [1] "COL25"

# List all available COL releases
clb_col_releases()
#> # A tibble: 52 × 23
#>    created   modified   key sourceKey type  origin attempt imported   size doi  
#>    <chr>     <chr>    <int>     <int> <chr> <chr>    <int> <chr>     <int> <chr>
#>  1 2021-07-… 2021-08…  2328         3 taxo… relea…      50 2021-07… 4.36e6 10.4…
#>  2 2021-11-… 2026-06…  2353        NA taxo… exter…       8 2022-03… 2.54e6 10.4…
#>  3 2021-11-… 2026-06…  2354        NA taxo… exter…       5 2022-03… 3.87e6 10.4…
#>  4 2021-12-… 2026-06…  2355        NA taxo… exter…       3 2022-03… 3.79e6 10.4…
#>  5 2021-12-… 2026-06…  2356        NA taxo… exter…       4 2022-03… 3.57e6 10.4…
#>  6 2021-12-… 2026-06…  2357        NA taxo… exter…       4 2022-03… 3.39e6 10.4…
#>  7 2021-12-… 2026-06…  2358        NA taxo… exter…       4 2022-03… 3.24e6 10.4…
#>  8 2021-12-… 2026-06…  2359        NA taxo… exter…       3 2022-03… 3.16e6 10.4…
#>  9 2022-02-… 2026-06…  9805        NA taxo… exter…       1 2022-05… 2.48e6 10.4…
#> 10 2022-08-… 2022-08…  9837         3 taxo… relea…     101 2022-08… 4.72e6 10.4…
#> # ℹ 42 more rows
#> # ℹ 13 more variables: title <chr>, alias <chr>, issued <chr>, version <chr>,
#> #   publisher <list>, taxonomicGroupScope <list>, license <chr>, label <chr>,
#> #   citation <chr>, private <lgl>, lastImportAttempt <chr>,
#> #   lastImportState <chr>, versionDoi <chr>
```

## Name verification and matching

[`col_check_name()`](https://paulesantos.github.io/rcol/reference/clb_resolve_name.md)
provides a clean, 9-column resolution summary showing the accepted name,
authorship, status, and ID for single or multiple species:

``` r

# Clean 9-column verification
col_check_name(c("Werneria nubigena", "Panthera leo", "Schinus molle"))
#> # A tibble: 3 × 9
#>   queried_name      matched_name      status   accepted_name accepted_authorship
#>   <chr>             <chr>             <chr>    <chr>         <chr>              
#> 1 Werneria nubigena Werneria nubigena synonym  Rockhausenia… (Kunth) D.J.N.Hind 
#> 2 Panthera leo      Panthera leo      accepted Panthera leo  (Linnaeus, 1758)   
#> 3 Schinus molle     Schinus molle     accepted Schinus molle L.                 
#> # ℹ 4 more variables: accepted_rank <chr>, accepted_id <chr>, match <lgl>,
#> #   match_type <chr>

# Full raw match (16 columns)
col_match("Panthera leo")
#> # A tibble: 1 × 17
#>   match match_type usage_id name         authorship     rank  status accepted_id
#>   <lgl> <chr>      <chr>    <chr>        <chr>          <chr> <chr>  <chr>      
#> 1 TRUE  variant    4CGXP    Panthera leo (Linnaeus, 17… spec… accep… 4CGXP      
#> # ℹ 9 more variables: accepted_name <chr>, accepted_authorship <chr>,
#> #   accepted_rank <chr>, code <chr>, label <chr>, parent_id <chr>,
#> #   names_index_id <int>, names_index_match_type <chr>, classification <list>

# Inspect homonym candidates
col_match_verbose("Oenanthe")
#> # A tibble: 2 × 16
#>   primary usage_id name     authorship    rank  status accepted_id accepted_name
#>   <lgl>   <chr>    <chr>    <chr>         <chr> <chr>  <chr>       <chr>        
#> 1 TRUE    679Q     Oenanthe L.            genus accep… 679Q        Oenanthe     
#> 2 FALSE   679P     Oenanthe Vieillot, 18… genus accep… 679P        Oenanthe     
#> # ℹ 8 more variables: accepted_authorship <chr>, accepted_rank <chr>,
#> #   code <chr>, label <chr>, parent_id <chr>, names_index_id <int>,
#> #   names_index_match_type <chr>, classification <list>

# Match many names in parallel
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

To match against a specific dataset rather than the latest COL release,
use
[`clb_match()`](https://paulesantos.github.io/rcol/reference/clb_match.md)
with a `dataset =` key or alias:

``` r

clb_match("Felis catus", dataset = "COL25")
#> # A tibble: 1 × 17
#>   match match_type usage_id name        authorship     rank   status accepted_id
#>   <lgl> <chr>      <chr>    <chr>       <chr>          <chr>  <chr>  <chr>      
#> 1 TRUE  variant    3DXV3    Felis catus Linnaeus, 1758 speci… accep… 3DXV3      
#> # ℹ 9 more variables: accepted_name <chr>, accepted_authorship <chr>,
#> #   accepted_rank <chr>, code <chr>, label <chr>, parent_id <chr>,
#> #   names_index_id <int>, names_index_match_type <chr>, classification <list>
clb_match("Bellis perennis", dataset = 2099)
#> # A tibble: 1 × 17
#>   match match_type usage_id name  authorship rank  status accepted_id
#>   <lgl> <chr>      <chr>    <chr> <chr>      <chr> <chr>  <chr>      
#> 1 FALSE none       NA       NA    NA         NA    NA     NA         
#> # ℹ 9 more variables: accepted_name <chr>, accepted_authorship <chr>,
#> #   accepted_rank <chr>, code <chr>, label <chr>, parent_id <chr>,
#> #   names_index_id <chr>, names_index_match_type <chr>, classification <list>
```

## Classification, synonyms, vernaculars and distribution

All relationship functions accept **direct scientific names**,
**character vectors of species**, **taxon IDs**, or **match data
frames**:

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

# Synonyms for single or multiple species
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
#> 12 Rockhausenia nubigena Werneria nubig… NA         heterotypic  vari… Werneria…
#> 13 Rockhausenia nubigena Werneria steub… Hieron.    heterotypic  spec… Werneria…
#> 14 Rockhausenia nubigena Werneria stueb… Hieron.    heterotypic  spec… Werneria…
#> 15 Panthera leo          Felis leo       Linnaeus,… homotypic    spec… Felis le…
#> 16 Panthera leo          Panthera leo n… (de Blain… heterotypic  subs… Panthera…

# Vernacular/common names with species traceability (scientific_name column)
col_vernacular(c("Werneria nubigena", "Panthera leo"))
#> # A tibble: 206 × 7
#>    scientific_name       name               language latin country area  remarks
#>    <chr>                 <chr>              <chr>    <chr> <chr>   <chr> <chr>  
#>  1 Rockhausenia nubigena Chicoria blanca    spa      Chic… NA      NA    NA     
#>  2 Rockhausenia nubigena Cóndor cebolla     spa      Cond… NA      NA    NA     
#>  3 Panthera leo          African Lion       eng      Afri… NA      NA    NA     
#>  4 Panthera leo          Afrikaanse Leeuw   nld      Afri… NA      NA    Contri…
#>  5 Panthera leo          Afrikanischer Löwe deu      Afri… DE      NA    NA     
#>  6 Panthera leo          Agrzam             shi      Agrz… NA      NA    Contri…
#>  7 Panthera leo          Ambessa            amh      Ambe… NA      NA    NA     
#>  8 Panthera leo          Arslon             uzb      Arsl… NA      NA    Contri…
#>  9 Panthera leo          Aslan              gag      Aslan NA      NA    Contri…
#> 10 Panthera leo          Dzata              ewe      Dzata NA      NA    Contri…
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
```

## Parsing

The ChecklistBank parsers parse scientific names and controlled values:

``` r

clb_parse_name("Abies alba Mill. var. alpina")
#> # A tibble: 1 × 9
#>   scientificName    rank  genus specificEpithet infraspecificEpithet type  label
#>   <chr>             <chr> <chr> <chr>           <chr>                <chr> <chr>
#> 1 Abies alba var. … vari… Abies alba            alpina               scie… Abie…
#> # ℹ 2 more variables: labelHtml <chr>, parsed <lgl>

clb_parsers()
#>  [1] "area"               "boolean"            "country"           
#>  [4] "datasettype"        "date"               "distributionstatus"
#>  [7] "gazetteer"          "geotime"            "integer"           
#> [10] "language"           "license"            "lifezone"          
#> [13] "mediatype"          "nomcode"            "nomreltype"        
#> [16] "nomstatus"          "rank"               "referencetype"     
#> [19] "sex"                "taxonomicstatus"    "treatmentformat"   
#> [22] "typestatus"         "uri"                "name"
clb_parse("rank", c("spec", "fam.", "ssp"))
#> # A tibble: 3 × 3
#>   original parsed     parsable
#>   <chr>    <chr>      <lgl>   
#> 1 spec     species    TRUE    
#> 2 fam.     family     TRUE    
#> 3 ssp      subspecies TRUE
```

## Datasets and Tree Navigation

``` r

# Dataset search & metadata
clb_dataset_search("mammal")
#> <clb> result: 50 rows (total: 607)
#> # A tibble: 50 × 24
#>    created       modified    key type  origin attempt imported lastImportAttempt
#>    <chr>         <chr>     <int> <chr> <chr>    <int> <chr>    <chr>            
#>  1 2025-12-11T2… 2026-03… 313445 taxo… exter…      23 2025-12… 2025-12-17T00:50…
#>  2 2026-02-12T1… 2026-02… 314225 taxo… exter…       1 2026-02… 2026-08-07T21:50…
#>  3 2024-02-29T1… 2026-07… 289588 other exter…       8 2026-07… 2026-08-07T23:31…
#>  4 2023-04-16T1… 2026-02… 248521 other exter…      10 2023-06… 2026-08-07T21:20…
#>  5 2022-04-04T1… 2026-06…  29593 other exter…     144 2026-06… 2026-08-07T21:31…
#>  6 2022-04-04T1… 2026-08…  28818 other exter…      85 2026-08… 2026-08-07T21:40…
#>  7 2023-03-27T1… 2026-02… 238879 other exter…      12 2023-06… 2026-08-07T21:15…
#>  8 2023-03-30T0… 2026-02… 240732 other exter…      12 2023-06… 2026-08-07T21:31…
#>  9 2023-04-16T1… 2026-02… 248520 other exter…      10 2023-06… 2026-08-07T21:10…
#> 10 2023-03-28T0… 2026-02… 239250 other exter…      12 2023-06… 2026-08-07T21:15…
#> # ℹ 40 more rows
#> # ℹ 16 more variables: lastImportState <chr>, size <int>, doi <chr>,
#> #   title <chr>, alias <chr>, issued <chr>, version <chr>,
#> #   taxonomicGroupScope <list>, license <chr>, label <chr>, citation <chr>,
#> #   private <lgl>, gbifKey <chr>, gbifPublisherKey <chr>, versionDoi <chr>,
#> #   publisher <list>
col_dataset_metrics()
#> # A tibble: 1 × 46
#>   datasetKey attempt job      state    started  finished createdBy bareNameCount
#>        <int>   <int> <chr>    <chr>    <chr>    <chr>        <int>         <int>
#> 1          3     607 XRelease finished 2026-07… 2026-07…       466             0
#> # ℹ 38 more variables: distributionCount <int>, estimateCount <int>,
#> #   mediaCount <int>, nameCount <int>, referenceCount <int>,
#> #   synonymCount <int>, taxonCount <int>, treatmentCount <int>,
#> #   typeMaterialCount <int>, vernacularCount <int>,
#> #   distributionsByGazetteerCount <list>, extinctTaxaByRankCount <list>,
#> #   issuesCount <list>, namesByCodeCount <list>, namesByRankCount <list>,
#> #   namesByStatusCount <list>, namesByTypeCount <list>, …

# Navigate the tree
roots <- col_tree()
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

# Search usages
col_usage_search("Felidae")
#> <clb> result: 1 rows (total: 1)
#> # A tibble: 1 × 11
#>   id    scientific_name authorship          rank  status label parent_id extinct
#>   <chr> <chr>           <chr>               <chr> <chr>  <chr> <chr>     <lgl>  
#> 1 623RM Felidae         Fischer de Waldhei… fami… accep… Feli… 4DL       FALSE  
#> # ℹ 3 more variables: name <list>, group <chr>, classification <list>
col_suggest("Panth")
#> # A tibble: 10 × 9
#>    match            context usageId nameId rank  status nomCode group suggestion
#>    <chr>            <chr>   <chr>   <chr>  <chr> <chr>  <chr>   <chr> <chr>     
#>  1 Pantheinae Smit… Noctui… KZBYK   aM1Z2… subf… accep… zoolog… lepi… Pantheina…
#>  2 Pantherinae Poc… Felidae 628LP   fukH7… subf… accep… zoolog… chor… Pantherin…
#>  3 Parapanthalis    Acoeti… V8XQL   ~23Iq  genus accep… NA      othe… Parapanth…
#>  4 Panthiades Hübn… Lycaen… 9CLKZ   YlR7Y… genus accep… zoolog… lepi… Panthiade…
#>  5 Pseudopanthera … Geomet… VJ7H5   a9sR_… genus accep… zoolog… lepi… Pseudopan…
#>  6 Neopanthea Anwe… Noctui… VCSWH   cDOhj… genus accep… zoolog… lepi… Neopanthe…
#>  7 †Palaeopanthera… Felidae RM7M3   ~2NFh  genus accep… zoolog… chor… †Palaeopa…
#>  8 Parapanthous Di… Reduvi… 6G2V    93OkI… genus accep… zoolog… hemi… Parapanth…
#>  9 Neopanthalis St… Acoeti… 84RRG   efUgT… genus accep… zoolog… othe… Neopantha…
#> 10 Pantherophis Fi… Colubr… 6DBX    SCvgH… genus accep… zoolog… chor… Pantherop…
```

## Custom API Endpoints

Set `CLB_BASE_URL` to target a different ChecklistBank deployment, such
as the development API:

``` r

Sys.setenv(CLB_BASE_URL = "https://api.dev.checklistbank.org")
```
