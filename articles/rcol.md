# Getting started with rcolapi

`rcolapi` wraps the [ChecklistBank](https://www.checklistbank.org) API
to give R users idiomatic access to the [Catalogue of
Life](https://www.catalogueoflife.org) (COL) and every other public
dataset in ChecklistBank.

``` r

library(rcolapi)
```

The examples below that query ChecklistBank are displayed without being
run when this vignette is built, so package installation and checks do
not require access to the API. Run them in an interactive R session with
Internet access.

## Two function families

Most functions come in two forms:

- **`col_*()`** target the latest extended COL release without needing a
  `dataset` argument. The `"3LXR"` release alias is resolved once to its
  integer dataset key and cached for the session via
  [`col_key()`](https://paulesantos.github.io/rcolapi/reference/col_key.md),
  so long-running work is not disrupted by a new release published
  midway. Use
  [`col_refresh()`](https://paulesantos.github.io/rcolapi/reference/col_refresh.md)
  to deliberately re-pin to the newest release.
- **`clb_*()`** take a `dataset =` argument and work against any dataset
  in ChecklistBank or historical COL releases.

``` r

col_key()      # Pinned integer dataset key of the latest extended release
col_refresh()  # Re-resolve to the newest release
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
clb_col_release("monthly", extended = TRUE) # "3LXR"  latest monthly extended release
clb_col_release("annual")                   # e.g. "COL25"

# List all available COL releases
clb_col_releases()
```

## Name verification and matching

[`col_check_name()`](https://paulesantos.github.io/rcolapi/reference/clb_resolve_name.md)
provides a clean, 9-column resolution summary showing the accepted name,
authorship, status, and ID for single or multiple species:

``` r

# Clean 9-column verification
col_check_name(c("Werneria nubigena", "Panthera leo", "Schinus molle"))

# Detailed match with classification
col_match("Panthera leo")

# Inspect homonym candidates
col_match_verbose("Oenanthe")

# Match many names in parallel
col_match_checklist(c("Panthera leo", "Bufo bufo", "Abies alba"))
```

To match against a specific dataset rather than the latest COL release,
use
[`clb_match()`](https://paulesantos.github.io/rcolapi/reference/clb_match.md)
with a `dataset =` key or alias:

``` r

clb_match("Felis catus", dataset = "COL25")
clb_match("Bellis perennis", dataset = 2099)
```

## Classification, synonyms, vernaculars and distribution

The following relationship functions accept **direct scientific names**,
**character vectors of species**, **taxon IDs**, or **match data
frames**:

``` r

# Hierarchical classification in Wide or Long format
col_classification("Schinus molle", wide = TRUE)

# Synonyms for single or multiple species
col_synonyms(c("Werneria nubigena", "Panthera leo"))

# Vernacular/common names with species traceability (scientific_name column)
col_vernacular(c("Werneria nubigena", "Panthera leo"))

# Geographic distribution in tidy format
col_distribution(c("Werneria nubigena", "Schinus molle"))
```

## Parsing

The ChecklistBank parsers parse scientific names and controlled values:

``` r

clb_parse_name("Abies alba Mill. var. alpina")

clb_parsers()
clb_parse("rank", c("spec", "fam.", "ssp"))
```

## Datasets and Tree Navigation

``` r

# Dataset search & metadata
clb_dataset_search("mammal")
col_dataset_metrics()

# Navigate the tree
roots <- col_tree()
col_children("Panthera")

# Search usages
col_usage_search("Felidae")
col_suggest("Panth")
```

## Batch results and failures

[`col_match_checklist()`](https://paulesantos.github.io/rcolapi/reference/col_shortcuts.md)
and
[`clb_match_checklist()`](https://paulesantos.github.io/rcolapi/reference/clb_match_checklist.md)
keep one row per input and preserve input columns with a `verbatim_`
prefix. Inspect `match` and `error` before interpreting the results:

| `match` | `error` | Meaning                                       |
|---------|---------|-----------------------------------------------|
| `TRUE`  | `NA`    | A matching usage was returned.                |
| `FALSE` | `NA`    | The request succeeded but no match was found. |
| `NA`    | Message | The request or response parsing failed.       |

``` r

batch <- col_match_checklist(c("Panthera leo", "Schinus molle"))
failed <- batch[is.na(batch$match), ]
unmatched <- batch[!is.na(batch$match) & !batch$match, ]
matched <- batch[!is.na(batch$match) & batch$match, ]
failed[c("verbatim_name", "error")]
```

These per-row diagnostics apply to batch requests. Failures before
requests are submitted, such as resolving
[`col_key()`](https://paulesantos.github.io/rcolapi/reference/col_key.md),
still raise an error. The simpler
[`col_check_name()`](https://paulesantos.github.io/rcolapi/reference/clb_resolve_name.md)
summary retains `match = NA` for failed rows but does not include the
`error` column; use
[`col_match_checklist()`](https://paulesantos.github.io/rcolapi/reference/col_shortcuts.md)
when diagnosing failures.

## Distribution provenance and raw responses

For multiple inputs,
[`col_distribution()`](https://paulesantos.github.io/rcolapi/reference/clb_distribution.md)
includes `input_row` (the one-based position in the input),
`scientific_name`, and `area`. A species can have several rows after
splitting semicolon-separated areas. Species with no distribution
records contribute no rows, so use `input_row` rather than row position
to join results back to your input.

``` r

species <- c("Panthera leo", "Schinus molle")
distribution <- col_distribution(species)
distribution$queried_name <- species[distribution$input_row]

# Add status, gazetteer, remarks and reference metadata
col_distribution(species, full = TRUE)

# Resolve an ID or a verification result before formatting the classification
col_classification("4CGXP", wide = TRUE)
verified <- col_check_name("Schinus molle")
col_classification(verified, wide = TRUE)

# Keep nested API responses intact and aligned with each input
responses <- col_usage(species, .raw = TRUE)
responses[[1]]
```

For a single input, distribution output defaults to `area`;
`full = TRUE` also includes `scientific_name` and metadata. Usage,
classification, synonym, vernacular and distribution lookups with
multiple inputs and `.raw = TRUE` return a list of complete parsed
responses, including empty responses, instead of combining them into a
tibble. With one input, `.raw = TRUE` returns the single parsed
response. For classification, `.raw = TRUE` takes precedence over
`wide`.

When passing a result table to a taxon lookup, valid IDs are selected in
order from `accepted_id`, `usage_id`, and `id`, skipping missing or
empty values. Unresolved rows raise an error. Filter failed and
unmatched rows before passing a batch result to a downstream lookup.

## Building documentation and running tests

Online examples are displayed without execution when the README and
vignettes are built. This allows documentation builds without contacting
ChecklistBank. Unit tests run without API access; live integration tests
are opt-in and remain skipped on CRAN.

``` r

devtools::test()

# Run live integration tests in a development session with Internet access
withr::with_envvar(c(RCOL_LIVE_TESTS = "true"), devtools::test())

# Build and check the package, including its vignettes and PDF manual
devtools::check(cran = TRUE, manual = TRUE)
```

Documentation builds require Pandoc; the PDF manual also requires a
working LaTeX installation. These tools are separate from access to the
API.

## Custom API Endpoints

Set `CLB_BASE_URL` to target a different ChecklistBank deployment, such
as the development API:

``` r

Sys.setenv(CLB_BASE_URL = "https://api.dev.checklistbank.org")
```
