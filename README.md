

<!-- README.md is generated from README.Rmd. Please edit that file -->

# rcol

<!-- badges: start -->

[![R-CMD-check](https://github.com/CatalogueOfLife/rcol/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/CatalogueOfLife/rcol/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

`rcol` is an R client for the [Catalogue of
Life](https://www.catalogueoflife.org) via the
[ChecklistBank](https://www.checklistbank.org) API
(<https://api.checklistbank.org>). It lets you match scientific names,
look up datasets, taxa and name usages, navigate the taxonomic tree,
extract classifications, retrieve synonyms, vernacular names, geographic
distribution records, and run the ChecklistBank parsers — against
**any** public dataset in ChecklistBank or the latest Catalogue of Life
release. It is modelled on the conventions of
[`rgbif`](https://docs.ropensci.org/rgbif/) and
[`taxadb`](https://docs.ropensci.org/taxadb/).

There are two parallel families of functions:

- **`clb_*()`** work against **any** dataset and take a `dataset =`
  argument.
- **`col_*()`** are convenience siblings that always target the **latest
  extended Catalogue of Life release** and drop the `dataset` argument.
  On first use the release alias `"3LXR"` is resolved to its concrete
  integer key and pinned for the rest of the session (via `col_key()`),
  so a release published mid-session never changes the data under a
  long-running job. Call `col_refresh()` to pick up a new release on
  purpose.

## Key Features

1.  **Flexible Inputs**: All downstream functions (`col_synonyms()`,
    `col_vernacular()`, `col_distribution()`, `col_classification()`,
    `col_usage()`, `col_children()`) accept **direct scientific names**
    (e.g. `"Werneria nubigena"`), **taxon IDs** (e.g. `"4CGXP"`), or
    **match data frames** interchangeably.
2.  **Vectorized Multi-Name Support**: Pass single names or character
    vectors with multiple species
    (e.g. `c("Werneria nubigena", "Panthera leo")`) and receive clean,
    concatenated tidy data frames with species traceability.
3.  **Clean Name Verification**: `col_check_name()` / `clb_check_name()`
    provide a clean 9-column resolution summary showing accepted names,
    status, and IDs without raw JSON overhead.
4.  **HTML-Free Full Names**: Full name fields and tree navigation
    columns (`full_name`) are stripped of HTML formatting for direct use
    in reports and publications.

## Installation

Install the development version from GitHub:

``` r
# install.packages("pak")
pak::pak("CatalogueOfLife/rcol")

# or
# install.packages("remotes")
remotes::install_github("CatalogueOfLife/rcol")
```

Documentation is published at <https://catalogueoflife.github.io/rcol/>.

## Quick start

### 1. Name Verification & Matching

``` r
library(rcol)

# High-level clean verification (9 columns) for 1 or multiple species
col_check_name(c("Werneria nubigena", "Panthera leo", "Schinus molle"))

# Raw matching against the latest Catalogue of Life release
col_match("Panthera leo")

# Disambiguate with rank and nomenclatural code
col_match("Abies alba", rank = "species", code = "botanical")

# See all candidate matches (homonyms), not just the best one
col_match_verbose("Oenanthe")

# Match many names at once in parallel
col_match_checklist(c("Panthera leo", "Bufo bufo", "Abies alba"))
```

To match against a specific dataset instead of the latest COL release,
use the `clb_*()` form with a `dataset =` key or alias:

``` r
clb_match("Felis catus", dataset = "COL25")          # the 2025 annual release
clb_match("Macrocystis pyrifera", dataset = 2099)    # any public dataset by key
```

### 2. Classification, Synonyms, Vernaculars & Distribution

All functions work seamlessly with direct scientific names, IDs, or
character vectors:

``` r
# Hierarchical classification in Wide or Long format
col_classification("Schinus molle", wide = TRUE)

# Synonyms for 1 or multiple species
col_synonyms(c("Werneria nubigena", "Panthera leo"))

# Vernacular / common names with species association
col_vernacular(c("Werneria nubigena", "Panthera leo"))

# Geographic distribution in tidy format
col_distribution(c("Werneria nubigena", "Schinus molle"))

# Details of a name usage
col_usage("Panthera leo")
```

### 3. Tree Navigation & Search

``` r
# Walk the COL tree roots (Domains / Reinos)
roots <- col_tree()

# Get direct child species under a genus
col_children("Panthera")

# Full-text search with rank and status filters
col_usage_search("Panthera", rank = "species", status = "accepted")
```

### 4. Parsers

``` r
# Parse a scientific name into its atomic components
clb_parse_name("Abies alba Mill. var. alpina")
```

## Catalogue of Life Releases

The Catalogue of Life is published in two cadences (monthly and annual)
and two flavours (a base release and an extended release `XR`). Every
`clb_*()` function takes a `dataset =` argument; helpful aliases resolve
to the latest of each:

``` r
clb_col_release("monthly")                  # "3LR"   latest monthly base
clb_col_release("monthly", extended = TRUE) # "3LXR"  latest monthly extended
clb_col_release("annual")                   # e.g. "COL25"

clb_usage_search("Felidae", dataset = "COL25")
```

## Configuration

The base URL defaults to the production API and can be redirected with
the `CLB_BASE_URL` environment variable, e.g. to the development server:

``` r
Sys.setenv(CLB_BASE_URL = "https://api.dev.checklistbank.org")
```

## License

MIT © Catalogue of Life
