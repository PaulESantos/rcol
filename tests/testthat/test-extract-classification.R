test_that("clb_extract_classification works in long format and cleans labelHtml", {
  sample_data <- tibble::tibble(
    name = "Schinus molle",
    classification = list(list(
      list(id = "1", name = "Plantae", rank = "kingdom", labelHtml = "Plantae"),
      list(id = "2", name = "Anacardiaceae", rank = "family", labelHtml = "Anacardiaceae R.Br."),
      list(id = "3", name = "Schinus", rank = "genus", labelHtml = "<i>Schinus</i> L.")
    ))
  )

  long_df <- clb_extract_classification(sample_data, wide = FALSE)
  expect_s3_class(long_df, "tbl_df")
  expect_equal(nrow(long_df), 3)
  expect_equal(long_df$name, c("Plantae", "Anacardiaceae", "Schinus"))
  expect_equal(long_df$rank, c("kingdom", "family", "genus"))
  expect_equal(long_df$label, c("Plantae", "Anacardiaceae R.Br.", "Schinus L."))
  expect_false("labelHtml" %in% names(long_df))
  expect_equal(long_df$matched_name, rep("Schinus molle", 3))
})

test_that("clb_extract_classification works in wide format", {
  sample_data <- tibble::tibble(
    name = "Schinus molle",
    rank = "species",
    classification = list(list(
      list(id = "1", name = "Plantae", rank = "kingdom"),
      list(id = "2", name = "Anacardiaceae", rank = "family"),
      list(id = "3", name = "Schinus", rank = "genus")
    ))
  )

  wide_df <- clb_extract_classification(sample_data, wide = TRUE)
  expect_s3_class(wide_df, "tbl_df")
  expect_equal(nrow(wide_df), 1)
  expect_equal(wide_df$kingdom, "Plantae")
  expect_equal(wide_df$family, "Anacardiaceae")
  expect_equal(wide_df$genus, "Schinus")
  expect_equal(wide_df$species, "Schinus molle")
  expect_true(is.na(wide_df$phylum))
})

test_that("col_extract_classification is identical to clb_extract_classification", {
  sample_data <- tibble::tibble(
    classification = list(list(
      list(id = "1", name = "Animalia", rank = "kingdom")
    ))
  )
  expect_equal(
    col_extract_classification(sample_data),
    clb_extract_classification(sample_data)
  )
})

test_that("clb_extract_classification accepts character vectors directly", {
  res <- clb_extract_classification("Panthera leo", wide = TRUE)
  expect_s3_class(res, "tbl_df")
  expect_equal(nrow(res), 1)
  expect_equal(res$genus, "Panthera")
})

test_that("clb_extract_classification errors when classification column is missing", {
  expect_error(
    clb_extract_classification(tibble::tibble(x = 1)),
    "classification"
  )
})
