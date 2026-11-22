# Classification hierarchy of a taxon

Retrieves the ordered classification hierarchy (ancestors) for a taxon
in a dataset. Accepts a taxon ID, a scientific name, or a data frame
from
[`col_check_name()`](https://paulesantos.github.io/rcolapi/reference/clb_resolve_name.md)
or
[`col_match()`](https://paulesantos.github.io/rcolapi/reference/col_shortcuts.md).

## Usage

``` r
clb_classification(id, dataset = "3LXR", wide = FALSE, .raw = FALSE)
```

## Arguments

- id:

  Taxon id (character), scientific name, or a data frame from
  [`col_match()`](https://paulesantos.github.io/rcolapi/reference/col_shortcuts.md)
  or
  [`col_check_name()`](https://paulesantos.github.io/rcolapi/reference/clb_resolve_name.md).

- dataset:

  Dataset key or alias. Defaults to `"3LXR"`.

- wide:

  Logical. If `TRUE`, returns major ranks in wide format columns
  (`kingdom` to `species`).

- .raw:

  Return the raw parsed JSON instead of a tibble?

## Value

A [tibble](https://tibble.tidyverse.org/reference/tibble.html) of
ancestors or classification. With `wide = TRUE`, IDs, names and result
tables are resolved before retrieving the classification; the resolved
usage's own rank is included when it is a major rank. Multiple inputs
are supported. `.raw = TRUE` takes precedence over `wide` and returns a
list of intact responses for multiple inputs.

## See also

[`clb_usage()`](https://paulesantos.github.io/rcolapi/reference/clb_usage.md),
[`clb_children()`](https://paulesantos.github.io/rcolapi/reference/clb_children.md),
[`clb_extract_classification()`](https://paulesantos.github.io/rcolapi/reference/clb_extract_classification.md)

## Examples

``` r
if (interactive()) {
clb_classification("4CGXP", dataset = "3LR")
clb_classification("Schinus molle")
clb_classification("Schinus molle", wide = TRUE)
}
```
