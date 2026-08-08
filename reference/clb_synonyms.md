# Synonyms of a taxon

Synonyms of a taxon

## Usage

``` r
clb_synonyms(id, dataset = "3LXR", full = FALSE, .raw = FALSE)
```

## Arguments

- id:

  Taxon id (character), scientific name, or a data frame from
  [`col_match()`](https://paulesantos.github.io/rcol/reference/col_shortcuts.md)
  or
  [`col_check_name()`](https://paulesantos.github.io/rcol/reference/clb_resolve_name.md).

- dataset:

  Dataset key or alias. Defaults to `"3LXR"`.

- full:

  Logical. If `FALSE` (default), returns the 6 essential columns:
  `accepted_name`, `scientific_name`, `authorship`, `synonym_type`,
  `rank`, `full_name`. If `TRUE`, includes secondary metadata.

- .raw:

  Return the raw parsed JSON instead of a tibble?

## Value

A [tibble](https://tibble.tidyverse.org/reference/tibble.html) of
synonym usages.

## See also

[`clb_usage()`](https://paulesantos.github.io/rcol/reference/clb_usage.md)

## Examples

``` r
if (FALSE) { # \dontrun{
clb_synonyms("6DBT", dataset = "3LR")
clb_synonyms("Werneria nubigena")
} # }
```
