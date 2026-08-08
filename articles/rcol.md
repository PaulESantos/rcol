# Getting started with rcol

`rcol` wraps the [ChecklistBank](https://www.checklistbank.org) API to
give R users idiomatic access to the [Catalogue of
Life](https://www.catalogueoflife.org) (COL) and every other public
dataset in ChecklistBank.

``` r

library(rcol)
```

## Two function families

Most functions come in two forms:

- **`col_*()`** target the latest extended COL release without needing a
  `dataset` argument. The `"3LXR"` release alias is resolved once to its
  integer dataset key and cached for the session via
  [`col_key()`](https://catalogueoflife.github.io/rcol/reference/col_key.md),
  so long-running work is not disrupted by a new release published
  midway. Use
  [`col_refresh()`](https://catalogueoflife.github.io/rcol/reference/col_refresh.md)
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

[`col_check_name()`](https://catalogueoflife.github.io/rcol/reference/clb_resolve_name.md)
provides a clean, 9-column resolution summary showing the accepted name,
authorship, status, and ID for single or multiple species:

``` r

# Clean 9-column verification
col_check_name(c("Werneria nubigena", "Panthera leo", "Schinus molle"))

# Full raw match (16 columns)
col_match("Panthera leo")

# Inspect homonym candidates
col_match_verbose("Oenanthe")

# Match many names in parallel
col_match_checklist(c("Panthera leo", "Bufo bufo", "Abies alba"))
```

To match against a specific dataset rather than the latest COL release,
use
[`clb_match()`](https://catalogueoflife.github.io/rcol/reference/clb_match.md)
with a `dataset =` key or alias:

``` r

clb_match("Felis catus", dataset = "COL25")
clb_match("Bellis perennis", dataset = 2099)
```

## Classification, synonyms, vernaculars and distribution

All relationship functions accept **direct scientific names**,
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

## Custom API Endpoints

Set `CLB_BASE_URL` to target a different ChecklistBank deployment, such
as the development API:

``` r

Sys.setenv(CLB_BASE_URL = "https://api.dev.checklistbank.org")
```
