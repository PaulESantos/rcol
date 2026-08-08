# Package index

## Name Verification and Matching (COL)

Core functions for scientific name matching, clean 9-column
verification, and homonym candidate inspection using the Catalogue of
Life extended release.

- [`clb_resolve_name()`](https://catalogueoflife.github.io/rcol/reference/clb_resolve_name.md)
  [`col_resolve_name()`](https://catalogueoflife.github.io/rcol/reference/clb_resolve_name.md)
  [`col_check_name()`](https://catalogueoflife.github.io/rcol/reference/clb_resolve_name.md)
  [`clb_check_name()`](https://catalogueoflife.github.io/rcol/reference/clb_resolve_name.md)
  : Resolve and verify valid species names
- [`col_match()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_match_verbose()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_match_checklist()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_dataset()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_dataset_metrics()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_usage()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_usage_search()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_search()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_suggest()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_classification()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_synonyms()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_vernacular()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_usage_metrics()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_tree()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_children()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  : Catalogue of Life shortcuts

## Classification, Synonyms and Relationships (COL)

Functions to extract hierarchical classifications (Wide/Long), synonyms,
vernacular/common names, and geographic distributions.

- [`col_match()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_match_verbose()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_match_checklist()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_dataset()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_dataset_metrics()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_usage()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_usage_search()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_search()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_suggest()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_classification()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_synonyms()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_vernacular()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_usage_metrics()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_tree()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_children()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  : Catalogue of Life shortcuts
- [`clb_extract_classification()`](https://catalogueoflife.github.io/rcol/reference/clb_extract_classification.md)
  [`col_extract_classification()`](https://catalogueoflife.github.io/rcol/reference/clb_extract_classification.md)
  : Extract taxonomic classification from a match or usage result
- [`clb_distribution()`](https://catalogueoflife.github.io/rcol/reference/clb_distribution.md)
  [`col_distribution()`](https://catalogueoflife.github.io/rcol/reference/clb_distribution.md)
  : Geographic distribution for a taxon

## Taxonomic Tree and Search (COL)

Navigate tree root domains/realms, retrieve immediate child taxa, and
perform free-text usage searches.

- [`col_match()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_match_verbose()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_match_checklist()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_dataset()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_dataset_metrics()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_usage()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_usage_search()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_search()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_suggest()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_classification()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_synonyms()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_vernacular()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_usage_metrics()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_tree()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_children()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  : Catalogue of Life shortcuts

## Session and Release Management

Inspect and pin the active Catalogue of Life release for the current R
session.

- [`col_key()`](https://catalogueoflife.github.io/rcol/reference/col_key.md)
  : The pinned Catalogue of Life release key
- [`col_refresh()`](https://catalogueoflife.github.io/rcol/reference/col_refresh.md)
  : Re-pin the Catalogue of Life release
- [`col_match()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_match_verbose()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_match_checklist()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_dataset()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_dataset_metrics()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_usage()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_usage_search()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_search()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_suggest()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_classification()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_synonyms()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_vernacular()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_usage_metrics()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_tree()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  [`col_children()`](https://catalogueoflife.github.io/rcol/reference/col_shortcuts.md)
  : Catalogue of Life shortcuts

## Universal ChecklistBank Interface (CLB)

Low-level complementary functions (`clb_*` family) for advanced queries
against any specific ChecklistBank dataset or historical COL release.

- [`clb_resolve_name()`](https://catalogueoflife.github.io/rcol/reference/clb_resolve_name.md)
  [`col_resolve_name()`](https://catalogueoflife.github.io/rcol/reference/clb_resolve_name.md)
  [`col_check_name()`](https://catalogueoflife.github.io/rcol/reference/clb_resolve_name.md)
  [`clb_check_name()`](https://catalogueoflife.github.io/rcol/reference/clb_resolve_name.md)
  : Resolve and verify valid species names
- [`clb_match()`](https://catalogueoflife.github.io/rcol/reference/clb_match.md)
  : Match a scientific name against a ChecklistBank dataset
- [`clb_match_checklist()`](https://catalogueoflife.github.io/rcol/reference/clb_match_checklist.md)
  : Match a checklist of names in bulk
- [`clb_match_verbose()`](https://catalogueoflife.github.io/rcol/reference/clb_match_verbose.md)
  : Match a name and return all candidate usages
- [`clb_classification()`](https://catalogueoflife.github.io/rcol/reference/clb_classification.md)
  : Classification hierarchy of a taxon
- [`clb_extract_classification()`](https://catalogueoflife.github.io/rcol/reference/clb_extract_classification.md)
  [`col_extract_classification()`](https://catalogueoflife.github.io/rcol/reference/clb_extract_classification.md)
  : Extract taxonomic classification from a match or usage result
- [`clb_synonyms()`](https://catalogueoflife.github.io/rcol/reference/clb_synonyms.md)
  : Synonyms of a taxon
- [`clb_vernacular()`](https://catalogueoflife.github.io/rcol/reference/clb_vernacular.md)
  : Vernacular (common) names
- [`clb_distribution()`](https://catalogueoflife.github.io/rcol/reference/clb_distribution.md)
  [`col_distribution()`](https://catalogueoflife.github.io/rcol/reference/clb_distribution.md)
  : Geographic distribution for a taxon
- [`clb_usage()`](https://catalogueoflife.github.io/rcol/reference/clb_usage.md)
  : Get a name usage (taxon or synonym) by id
- [`clb_usage_search()`](https://catalogueoflife.github.io/rcol/reference/clb_usage_search.md)
  [`clb_search()`](https://catalogueoflife.github.io/rcol/reference/clb_usage_search.md)
  : Full-text search of name usages
- [`clb_suggest()`](https://catalogueoflife.github.io/rcol/reference/clb_suggest.md)
  : Autocomplete suggestions for name usages
- [`clb_usage_metrics()`](https://catalogueoflife.github.io/rcol/reference/clb_usage_metrics.md)
  : Metrics for a taxon
- [`clb_tree()`](https://catalogueoflife.github.io/rcol/reference/clb_tree.md)
  : Navigate the taxonomic tree
- [`clb_children()`](https://catalogueoflife.github.io/rcol/reference/clb_children.md)
  : Direct children of a taxon
- [`clb_dataset()`](https://catalogueoflife.github.io/rcol/reference/clb_dataset.md)
  : Get dataset metadata
- [`clb_dataset_search()`](https://catalogueoflife.github.io/rcol/reference/clb_dataset_search.md)
  : Search datasets in ChecklistBank
- [`clb_dataset_metrics()`](https://catalogueoflife.github.io/rcol/reference/clb_dataset_metrics.md)
  : Dataset metrics
- [`clb_col_release()`](https://catalogueoflife.github.io/rcol/reference/clb_col_release.md)
  : Resolve a Catalogue of Life release
- [`clb_col_releases()`](https://catalogueoflife.github.io/rcol/reference/clb_col_releases.md)
  : List all Catalogue of Life releases
- [`clb_base_url()`](https://catalogueoflife.github.io/rcol/reference/clb_base_url.md)
  : The ChecklistBank API base URL

## ChecklistBank Parsers

Tools for parsing scientific names into atomic epithets and parsing
controlled values.

- [`clb_parse_name()`](https://catalogueoflife.github.io/rcol/reference/clb_parse_name.md)
  : Parse scientific names
- [`clb_parsers()`](https://catalogueoflife.github.io/rcol/reference/clb_parsers.md)
  : List the available ChecklistBank parsers
- [`clb_parse()`](https://catalogueoflife.github.io/rcol/reference/clb_parse.md)
  : Parse values with a ChecklistBank value parser
