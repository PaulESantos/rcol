test_that("Functions accept scientific names directly as input", {
  local_mocked_bindings(
    clb_match = function(name, ...) {
      tibble::tibble(
        match = TRUE,
        match_type = "exact",
        usage_id = "B87CR",
        name = name,
        accepted_id = "B87CR",
        accepted_name = "Rockhausenia nubigena",
        accepted_authorship = "(Kunth) D.J.N.Hind",
        status = "accepted"
      )
    },
    clb_get = function(..., query = NULL) {
      args <- list(...)
      endpoint <- args[[length(args)]]
      if (endpoint == "3LXR") {
        list(key = 3L, alias = "3LXR")
      } else if (endpoint == "synonyms") {
        list(homotypic = list(), heterotypic = list())
      } else if (endpoint == "vernacular") {
        list(list(name = "Plant", language = "eng"))
      } else if (endpoint == "distribution") {
        list(list(area = list(name = "Peru; Ecuador", gazetteer = "text")))
      } else if (endpoint == "classification") {
        list(list(id = "1", name = "Plantae", rank = "kingdom"))
      } else {
        list(id = "B87CR", scientificName = "Rockhausenia nubigena", status = "accepted")
      }
    }
  )

  # 1. clb_synonyms with scientific name string
  syn <- clb_synonyms("Werneria nubigena")
  expect_s3_class(syn, "tbl_df")

  # 2. clb_vernacular with scientific name string
  vern <- clb_vernacular(id = "Werneria nubigena")
  expect_s3_class(vern, "tbl_df")
  expect_equal(vern$name, "Plant")

  # 3. clb_distribution with scientific name string
  dist <- clb_distribution("Werneria nubigena")
  expect_s3_class(dist, "tbl_df")
  expect_equal(dist$area, c("Peru", "Ecuador"))

  # 4. clb_classification with scientific name string
  clas <- clb_classification("Werneria nubigena")
  expect_s3_class(clas, "tbl_df")
})
