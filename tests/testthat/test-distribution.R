test_that("clb_distribution and col_distribution parse distribution records into clean tibble", {
  local_mocked_bindings(
    clb_get = function(...) {
      list(
        list(
          area = list(name = "South America; Peru; Ecuador", gazetteer = "text"),
          status = "native",
          remarks = "High altitude Andean region"
        )
      )
    }
  )

  # full = FALSE (default): returns only area column
  res_simple <- col_distribution("B87CR", tidy = TRUE, full = FALSE)
  expect_s3_class(res_simple, "tbl_df")
  expect_equal(names(res_simple), "area")
  expect_equal(nrow(res_simple), 3L)
  expect_equal(res_simple$area, c("South America", "Peru", "Ecuador"))

  # full = TRUE: returns area + metadata columns
  res_full <- col_distribution("B87CR", tidy = TRUE, full = TRUE)
  expect_equal(ncol(res_full), 5L)
  expect_equal(res_full$gazetteer, c("text", "text", "text"))

  # tidy = FALSE: keeps original 1-row string
  res_raw <- col_distribution("B87CR", tidy = FALSE, full = FALSE)
  expect_equal(nrow(res_raw), 1L)
  expect_equal(res_raw$area, "South America; Peru; Ecuador")
})

test_that("col_distribution accepts match dataframe input directly", {
  match_df <- tibble::tibble(
    accepted_id = "B87CR",
    accepted_name = "Rockhausenia nubigena"
  )

  local_mocked_bindings(
    clb_get = function(...) {
      list(
        list(
          area = list(name = "Andean region", gazetteer = "text")
        )
      )
    }
  )

  res <- col_distribution(match_df)
  expect_equal(names(res), "area")
  expect_equal(res$area, "Andean region")
})
