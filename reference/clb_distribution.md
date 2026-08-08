# Geographic distribution for a taxon

Retrieves geographic distribution records (regions, countries) for a
taxon. By default, returns only the clean `area` column in tidy format.

## Usage

``` r
clb_distribution(id, dataset = "3LXR", tidy = TRUE, full = FALSE, .raw = FALSE)

col_distribution(id, tidy = TRUE, full = FALSE, .raw = FALSE)
```

## Arguments

- id:

  Taxon id (character), scientific name, or a data frame from
  [`col_match()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  or
  [`col_check_name()`](https://catalogueoflife.github.io/rcol/reference/clb_resolve_name.md).

- dataset:

  Dataset key or alias. Defaults to `"3LXR"`.

- tidy:

  Logical. If `TRUE` (default), splits semicolon-delimited areas into
  distinct rows.

- full:

  Logical. If `FALSE` (default), returns only the essential `area`
  column. If `TRUE`, includes secondary metadata (`gazetteer`, `status`,
  `remarks`, `reference_id`).

- .raw:

  Return the raw parsed JSON instead of a tibble?

## Value

A [tibble](https://tibble.tidyverse.org/reference/tibble.html) of
distribution records.

## Examples

``` r
if (FALSE) { # \dontrun{
# Distribution for Panthera leo (by ID or Scientific Name)
clb_distribution("4CGXP")
clb_distribution("Panthera leo")

# Distribution by passing col_check_name result directly
sp_info <- col_check_name("Schinus molle")
col_distribution(sp_info)
} # }
```
