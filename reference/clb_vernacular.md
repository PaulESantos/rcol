# Vernacular (common) names

Looks up vernacular names either for a single taxon (when `id` or
scientific name is given) or across a dataset by free-text query.

## Usage

``` r
clb_vernacular(
  id = NULL,
  dataset = "3LXR",
  q = NULL,
  lang = NULL,
  ...,
  limit = 50L,
  max = limit,
  full = FALSE,
  .raw = FALSE
)
```

## Arguments

- id:

  Optional taxon id, scientific name, or a data frame from
  [`col_match()`](https://paulesantos.github.io/rcol/reference/col_shortcuts.md).
  When supplied, returns the vernacular names of that taxon; otherwise
  performs a dataset-wide search using `q`.

- dataset:

  Dataset key or alias. Defaults to `"3LXR"`.

- q:

  Free-text query for the dataset-wide search (ignored when `id` is
  supplied).

- lang:

  Optional ISO language filter (e.g. `"eng"`, `"deu"`).

- ...:

  Further query parameters.

- limit:

  Page size for the dataset-wide search.

- max:

  Maximum rows for the dataset-wide search.

- full:

  Logical; if `FALSE` (default), returns clean essential columns. If
  `TRUE`, includes full metadata.

- .raw:

  Return the raw parsed JSON instead of a tibble?

## Value

A [tibble](https://tibble.tidyverse.org/reference/tibble.html) of
vernacular names.

## Examples

``` r
if (FALSE) { # \dontrun{
clb_vernacular(id = "4CGXP", dataset = "3LR")
clb_vernacular(id = "Panthera leo")
clb_vernacular(q = "lion", lang = "eng")
} # }
```
