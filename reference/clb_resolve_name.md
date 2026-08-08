# Resolve and verify valid species names

Provides a clean, simplified verification table for one or more
scientific names. Unlike
[`col_match()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md),
which returns full raw API columns and list columns,
`col_resolve_name()` returns only the essential fields needed to verify
whether a name is accepted or a synonym, and what its accepted name is.

## Usage

``` r
clb_resolve_name(
  name,
  authorship = NULL,
  rank = NULL,
  code = NULL,
  dataset = "3LXR",
  server = NULL
)

col_resolve_name(
  name,
  authorship = NULL,
  rank = NULL,
  code = NULL,
  server = NULL
)

col_check_name(
  name,
  authorship = NULL,
  rank = NULL,
  code = NULL,
  server = NULL
)

clb_check_name(
  name,
  authorship = NULL,
  rank = NULL,
  code = NULL,
  dataset = "3LXR",
  server = NULL
)
```

## Arguments

- name:

  A scientific name string or character vector of scientific names.

- authorship:

  Optional authorship string.

- rank:

  Optional rank to disambiguate (e.g. `"species"`, `"genus"`).

- code:

  Optional nomenclatural code (`"zoological"`, `"botanical"`,
  `"bacterial"`, `"virus"`, ...).

- dataset:

  Dataset key or alias to match against. Defaults to `"3LXR"`. See
  [`clb_col_release()`](https://catalogueoflife.github.io/rcol/reference/clb_col_release.md)
  for the COL release aliases.

- server:

  Optional base URL of an alternative matching service, e.g. a locally
  running dockerized matching container (`"http://localhost:8080"`).
  Overrides `CLB_BASE_URL` for this call.

## Value

A [tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
with columns:

- queried_name:

  The original scientific name queried.

- match:

  Logical indicator of whether a match was found.

- match_type:

  Type of match (`"exact"`, `"variant"`, `"fuzzy"`, etc.).

- status:

  Taxonomic status of the queried name (`"accepted"`, `"synonym"`).

- matched_name:

  Scientific name returned by the match service.

- accepted_name:

  The valid/accepted scientific name.

- accepted_authorship:

  Authorship of the accepted scientific name.

- accepted_rank:

  Taxonomic rank of the accepted name.

- accepted_id:

  ChecklistBank usage ID of the accepted name.

## Examples

``` r
# \donttest{
# Resolve a single name
col_resolve_name("Werneria nubigena")
#> # A tibble: 1 × 9
#>   queried_name      matched_name      status  accepted_name  accepted_authorship
#>   <chr>             <chr>             <chr>   <chr>          <chr>              
#> 1 Werneria nubigena Werneria nubigena synonym Rockhausenia … (Kunth) D.J.N.Hind 
#> # ℹ 4 more variables: accepted_rank <chr>, accepted_id <chr>, match <lgl>,
#> #   match_type <chr>

# Check multiple names at once
col_check_name(c("Werneria nubigena", "Panthera leo", "Schinus molle"))
#> # A tibble: 3 × 9
#>   queried_name      matched_name      status   accepted_name accepted_authorship
#>   <chr>             <chr>             <chr>    <chr>         <chr>              
#> 1 Werneria nubigena Werneria nubigena synonym  Rockhausenia… (Kunth) D.J.N.Hind 
#> 2 Panthera leo      Panthera leo      accepted Panthera leo  (Linnaeus, 1758)   
#> 3 Schinus molle     Schinus molle     accepted Schinus molle L.                 
#> # ℹ 4 more variables: accepted_rank <chr>, accepted_id <chr>, match <lgl>,
#> #   match_type <chr>
# }
```
