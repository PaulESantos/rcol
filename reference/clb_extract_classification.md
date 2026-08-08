# Extract taxonomic classification from a match or usage result

Helper function to extract and unnest the nested `classification`
list-column returned by
[`clb_match()`](https://paulesantos.github.io/rcol/reference/clb_match.md),
[`clb_match_checklist()`](https://paulesantos.github.io/rcol/reference/clb_match_checklist.md),
[`col_match()`](https://paulesantos.github.io/rcol/reference/col_shortcuts.md),
or
[`clb_usage_search()`](https://paulesantos.github.io/rcol/reference/clb_usage_search.md)
into a tidy long or wide tibble. Also accepts a character vector of
scientific names directly.

## Usage

``` r
clb_extract_classification(data, wide = FALSE, dataset = "3LXR", ...)

col_extract_classification(data, wide = FALSE, dataset = "3LXR", ...)
```

## Arguments

- data:

  A character vector of scientific names, or a data frame / tibble
  returned by a matching or usage function that contains a
  `classification` list-column.

- wide:

  Logical. If `TRUE`, pivots the major ranks (`kingdom`, `phylum`,
  `class`, `order`, `family`, `genus`, `species`) into columns alongside
  each input row. If `FALSE` (the default), returns a long tibble of all
  classification levels.

- dataset:

  Dataset key or alias used when `data` is a character vector. Defaults
  to `"3LXR"`.

- ...:

  Further query parameters passed to
  [`clb_match()`](https://paulesantos.github.io/rcol/reference/clb_match.md)
  or
  [`clb_match_checklist()`](https://paulesantos.github.io/rcol/reference/clb_match_checklist.md)
  when `data` is a character vector.

## Value

A [tibble](https://tibble.tidyverse.org/reference/tibble.html).

## See also

[`clb_match()`](https://paulesantos.github.io/rcol/reference/clb_match.md),
[`col_match()`](https://paulesantos.github.io/rcol/reference/col_shortcuts.md),
[`clb_classification()`](https://paulesantos.github.io/rcol/reference/clb_classification.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Pass a character string directly:
col_extract_classification("Schinus molle")
col_extract_classification("Schinus molle", wide = TRUE)
col_extract_classification(c("Schinus molle", "Panthera leo"), wide = TRUE)

# Pass a match result data frame:
res <- col_match("Schinus molle")
col_extract_classification(res)
} # }
```
