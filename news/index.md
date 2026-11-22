# Changelog

## rcolapi 0.0.2

- Renamed the package to `rcolapi` to avoid the archived CRAN package
  name `rcol`. Existing `col_*()` and `clb_*()` function names are
  unchanged.

- Both getting-started vignettes build without API access; online
  examples are displayed without execution.

- Batch matching now distinguishes failed requests (`match = NA`, with
  an `error` message) from genuine non-matches (`match = FALSE`).

- Taxon resolution skips missing IDs, rejects unresolved inputs and
  propagates service failures instead of interpreting them as missing
  names.

- Distribution batches retain `input_row` and `scientific_name`;
  single-input distributions also retain `scientific_name` when
  `full = TRUE`.

- Wide classifications resolve IDs and match-result tables before
  formatting.

- Raw batch lookups return lists of intact responses, including empty
  responses.

- Unit tests no longer require the API. Live integration tests require
  `RCOL_LIVE_TESTS=true` and remain skipped on CRAN. \# rcol 0.0.1

- Initial release.

- `col_*()` shortcut functions
  ([`col_match()`](https://paulesantos.github.io/rcolapi/reference/col_shortcuts.md),
  [`col_usage()`](https://paulesantos.github.io/rcolapi/reference/col_shortcuts.md),
  [`col_tree()`](https://paulesantos.github.io/rcolapi/reference/col_shortcuts.md),
  …) that always target the latest extended COL release without a
  `dataset` argument. The release is resolved once to its integer key
  and pinned for the session via
  [`col_key()`](https://paulesantos.github.io/rcolapi/reference/col_key.md);
  [`col_refresh()`](https://paulesantos.github.io/rcolapi/reference/col_refresh.md)
  re-pins to a newer release.

- Name matching against any dataset or COL release:
  [`clb_match()`](https://paulesantos.github.io/rcolapi/reference/clb_match.md),
  [`clb_match_verbose()`](https://paulesantos.github.io/rcolapi/reference/clb_match_verbose.md),
  [`clb_match_checklist()`](https://paulesantos.github.io/rcolapi/reference/clb_match_checklist.md).

- COL release discovery:
  [`clb_col_release()`](https://paulesantos.github.io/rcolapi/reference/clb_col_release.md),
  [`clb_col_releases()`](https://paulesantos.github.io/rcolapi/reference/clb_col_releases.md)
  covering the monthly base (`3LR`), monthly extended (`3LXR`) and
  annual (`COL<YY>`) releases.

- Parsers:
  [`clb_parsers()`](https://paulesantos.github.io/rcolapi/reference/clb_parsers.md),
  [`clb_parse_name()`](https://paulesantos.github.io/rcolapi/reference/clb_parse_name.md),
  [`clb_parse()`](https://paulesantos.github.io/rcolapi/reference/clb_parse.md).

- Datasets:
  [`clb_dataset_search()`](https://paulesantos.github.io/rcolapi/reference/clb_dataset_search.md),
  [`clb_dataset()`](https://paulesantos.github.io/rcolapi/reference/clb_dataset.md),
  [`clb_dataset_metrics()`](https://paulesantos.github.io/rcolapi/reference/clb_dataset_metrics.md).

- Name usages and taxa:
  [`clb_usage()`](https://paulesantos.github.io/rcolapi/reference/clb_usage.md),
  [`clb_usage_search()`](https://paulesantos.github.io/rcolapi/reference/clb_usage_search.md)
  /
  [`clb_search()`](https://paulesantos.github.io/rcolapi/reference/clb_usage_search.md),
  [`clb_suggest()`](https://paulesantos.github.io/rcolapi/reference/clb_suggest.md),
  [`clb_classification()`](https://paulesantos.github.io/rcolapi/reference/clb_classification.md),
  [`clb_synonyms()`](https://paulesantos.github.io/rcolapi/reference/clb_synonyms.md),
  [`clb_vernacular()`](https://paulesantos.github.io/rcolapi/reference/clb_vernacular.md),
  [`clb_usage_metrics()`](https://paulesantos.github.io/rcolapi/reference/clb_usage_metrics.md).

- Tree navigation:
  [`clb_tree()`](https://paulesantos.github.io/rcolapi/reference/clb_tree.md),
  [`clb_children()`](https://paulesantos.github.io/rcolapi/reference/clb_children.md).
