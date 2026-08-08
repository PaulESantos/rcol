test_that("clb_usage_row extracts accepted taxon info for synonyms and accepted usages", {
  # Usage object for an accepted taxon
  acc_usage <- list(
    id = "123",
    name = "Panthera leo",
    authorship = "(Linnaeus, 1758)",
    status = "accepted"
  )
  row_acc <- clb_usage_row(acc_usage)
  expect_equal(row_acc$accepted_id, "123")
  expect_equal(row_acc$accepted_name, "Panthera leo")
  expect_equal(row_acc$accepted_authorship, "(Linnaeus, 1758)")

  # Usage object for a synonym with classification containing the accepted taxon
  syn_usage <- list(
    id = "555",
    name = "Werneria nubigena",
    authorship = "Kunth",
    status = "synonym",
    parentId = "999",
    classification = list(
      list(id = "999", name = "Rockhausenia nubigena", authorship = "(Kunth) D.J.N.Hind", status = "accepted")
    )
  )
  row_syn <- clb_usage_row(syn_usage)
  expect_equal(row_syn$usage_id, "555")
  expect_equal(row_syn$accepted_id, "999")
  expect_equal(row_syn$accepted_name, "Rockhausenia nubigena")
  expect_equal(row_syn$accepted_authorship, "(Kunth) D.J.N.Hind")
})

test_that("clb_synonyms accepts match data frames and attaches accepted info", {
  match_df <- tibble::tibble(
    usage_id = "555",
    status = "synonym",
    accepted_id = "999",
    accepted_name = "Rockhausenia nubigena",
    accepted_authorship = "(Kunth) D.J.N.Hind"
  )

  local_mocked_bindings(
    clb_get = function(...) {
      list(
        homotypic = list(list(id = "555", name = list(scientificName = "Werneria nubigena"))),
        heterotypic = list()
      )
    }
  )

  res <- clb_synonyms(match_df, dataset = "3LXR", full = TRUE)
  expect_equal(res$accepted_id[[1]], "999")
  expect_equal(res$accepted_name[[1]], "Rockhausenia nubigena")
  expect_equal(res$accepted_authorship[[1]], "(Kunth) D.J.N.Hind")
})
