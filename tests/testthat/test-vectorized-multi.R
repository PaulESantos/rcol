test_that("col_synonyms and col_vernacular return full row counts for vector inputs", {
  skip_on_cran()

  syns <- col_synonyms(c("Werneria nubigena", "Panthera leo"))
  expect_true(nrow(syns) >= 16)
  expect_true("Rockhausenia nubigena" %in% syns$accepted_name)
  expect_true("Panthera leo" %in% syns$accepted_name)

  verns <- col_vernacular(c("Werneria nubigena", "Panthera leo"))
  expect_true(nrow(verns) >= 200)
  expect_true("Chicoria blanca" %in% verns$name)
  expect_true("African Lion" %in% verns$name)
})
