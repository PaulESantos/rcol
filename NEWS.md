# rcolapi 0.0.2

* Renamed the package to `rcolapi` to avoid the archived CRAN package name
  `rcol`. Existing `col_*()` and `clb_*()` function names are unchanged.
* Both getting-started vignettes build without API access; online examples are
  displayed without execution.

* Batch matching now distinguishes failed requests (`match = NA`, with an
  `error` message) from genuine non-matches (`match = FALSE`).
* Taxon resolution skips missing IDs, rejects unresolved inputs and propagates
  service failures instead of interpreting them as missing names.
* Distribution batches retain `input_row` and `scientific_name`; single-input
  distributions also retain `scientific_name` when `full = TRUE`.
* Wide classifications resolve IDs and match-result tables before formatting.
* Raw batch lookups return lists of intact responses, including empty responses.
* Unit tests no longer require the API. Live integration tests require
  `RCOL_LIVE_TESTS=true` and remain skipped on CRAN.
# rcol 0.0.1

* Initial release.
* `col_*()` shortcut functions (`col_match()`, `col_usage()`, `col_tree()`, ...)
  that always target the latest extended COL release without a `dataset`
  argument. The release is resolved once to its integer key and pinned for the
  session via `col_key()`; `col_refresh()` re-pins to a newer release.
* Name matching against any dataset or COL release: `clb_match()`,
  `clb_match_verbose()`, `clb_match_checklist()`.
* COL release discovery: `clb_col_release()`, `clb_col_releases()` covering the
  monthly base (`3LR`), monthly extended (`3LXR`) and annual (`COL<YY>`)
  releases.
* Parsers: `clb_parsers()`, `clb_parse_name()`, `clb_parse()`.
* Datasets: `clb_dataset_search()`, `clb_dataset()`, `clb_dataset_metrics()`.
* Name usages and taxa: `clb_usage()`, `clb_usage_search()` / `clb_search()`,
  `clb_suggest()`, `clb_classification()`, `clb_synonyms()`,
  `clb_vernacular()`, `clb_usage_metrics()`.
* Tree navigation: `clb_tree()`, `clb_children()`.
