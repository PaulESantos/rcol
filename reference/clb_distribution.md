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
  [`col_match()`](https://paulesantos.github.io/rcolapi/reference/col_shortcuts.md)
  or
  [`col_check_name()`](https://paulesantos.github.io/rcolapi/reference/clb_resolve_name.md).

- dataset:

  Dataset key or alias. Defaults to `"3LXR"`.

- tidy:

  Logical. If `TRUE` (default), splits semicolon-delimited areas into
  distinct rows.

- full:

  Logical. If `FALSE` (default), returns `area` for one input, or
  `input_row`, `scientific_name` and `area` for multiple inputs. If
  `TRUE`, also includes `scientific_name` for one input and secondary
  metadata (`gazetteer`, `status`, `remarks`, `reference_id`).

- .raw:

  Return the raw parsed JSON instead of a tibble?

## Value

A [tibble](https://tibble.tidyverse.org/reference/tibble.html) of
distribution records. Multiple inputs include `input_row` (the one-based
input position) and `scientific_name`. `full = TRUE` also retains
`scientific_name` for a single input. With `.raw = TRUE`, multiple
inputs return a list of intact responses. Inputs without distribution
records contribute no rows to the tibble; `input_row` preserves the
original position of inputs that have records.

## Examples

``` r
if (interactive()) {
# Distribution for Panthera leo (by ID or Scientific Name)
clb_distribution("4CGXP")
clb_distribution("Panthera leo")

# Distribution by passing col_check_name result directly
sp_info <- col_check_name("Schinus molle")
col_distribution(sp_info)
}
```
