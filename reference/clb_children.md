# Direct children of a taxon

Lists the immediate child taxa of a node in the taxonomic tree. Accepts
a taxon ID, a scientific name, or a data frame from
[`col_check_name()`](https://paulesantos.github.io/rcol/reference/clb_resolve_name.md)
or
[`col_match()`](https://paulesantos.github.io/rcol/reference/col_shortcuts.md).

## Usage

``` r
clb_children(
  id,
  dataset = "3LXR",
  extinct = TRUE,
  ...,
  limit = 100L,
  max = limit,
  .raw = FALSE
)
```

## Arguments

- id:

  Taxon id (character), scientific name, or a data frame from
  [`col_match()`](https://paulesantos.github.io/rcol/reference/col_shortcuts.md)
  or
  [`col_check_name()`](https://paulesantos.github.io/rcol/reference/clb_resolve_name.md).

- dataset:

  Dataset key or alias. Defaults to `"3LXR"`.

- extinct:

  Logical; include extinct taxa. Defaults to `TRUE`.

- ...:

  Further query parameters (e.g. `insertPlaceholder`).

- limit:

  Page size per request.

- max:

  Maximum number of children to return. Use `Inf` to fetch all.

- .raw:

  Return the raw parsed JSON instead of a tibble?

## Value

A [tibble](https://tibble.tidyverse.org/reference/tibble.html) of child
tree nodes.

## See also

[`clb_tree()`](https://paulesantos.github.io/rcol/reference/clb_tree.md),
[`clb_classification()`](https://paulesantos.github.io/rcol/reference/clb_classification.md)

## Examples

``` r
if (FALSE) { # \dontrun{
roots <- clb_tree(dataset = "3LR")
clb_children(roots$id[1], dataset = "3LR")
clb_children("Panthera")
} # }
```
