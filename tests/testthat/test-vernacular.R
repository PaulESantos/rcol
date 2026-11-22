test_that("clb_vernacular filters out internal database metadata columns", {
  local_mocked_bindings(
    col_key = function(...) 999L,
    clb_match = function(...) stop("Unexpected name lookup in this test"),
    clb_resolve_taxon_id = function(id, ...) {
      if (is.data.frame(id)) id$accepted_id[[1]] else id
    },
    clb_get = function(...) {
      list(
        list(
          created = "2026-01-01",
          createdBy = 10,
          datasetKey = 315834,
          name = "Puma",
          language = "spa",
          country = "PE",
          latin = "Puma"
        )
      )
    }
  )

  res <- clb_vernacular(id = "123")
  expect_s3_class(res, "tbl_df")
  expect_equal(names(res), c("name", "language", "country", "latin"))
  expect_false("created" %in% names(res))
  expect_false("datasetKey" %in% names(res))
})
