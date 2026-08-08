test_that("clb_vernacular filters out internal database metadata columns", {
  local_mocked_bindings(
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
