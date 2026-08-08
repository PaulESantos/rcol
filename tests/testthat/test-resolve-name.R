test_that("clb_resolve_name / col_resolve_name returns clean summary table for single name", {
  local_mocked_bindings(
    clb_match = function(name, ...) {
      tibble::tibble(
        match = TRUE,
        match_type = "variant",
        status = "synonym",
        name = name,
        accepted_name = "Rockhausenia nubigena",
        accepted_authorship = "(Kunth) D.J.N.Hind",
        accepted_rank = "species",
        accepted_id = "B87CR"
      )
    }
  )

  res <- col_resolve_name("Werneria nubigena")
  expect_s3_class(res, "tbl_df")
  expect_equal(nrow(res), 1L)
  expect_equal(res$queried_name, "Werneria nubigena")
  expect_equal(res$status, "synonym")
  expect_equal(res$accepted_name, "Rockhausenia nubigena")
  expect_equal(res$accepted_id, "B87CR")
  expect_equal(
    names(res),
    c("queried_name", "matched_name", "status", "accepted_name", "accepted_authorship", "accepted_rank", "accepted_id", "match", "match_type")
  )
})

test_that("col_check_name and clb_check_name aliases work identically for character vectors", {
  local_mocked_bindings(
    clb_match_checklist = function(data, ...) {
      tibble::tibble(
        verbatim_name = data$name,
        match = c(TRUE, TRUE),
        match_type = c("variant", "variant"),
        status = c("synonym", "accepted"),
        name = data$name,
        accepted_name = c("Rockhausenia nubigena", "Panthera leo"),
        accepted_authorship = c("(Kunth) D.J.N.Hind", "(Linnaeus, 1758)"),
        rank = c("species", "species"),
        accepted_rank = c("species", "species"),
        accepted_id = c("B87CR", "4CGXP")
      )
    }
  )

  res <- col_check_name(c("Werneria nubigena", "Panthera leo"))
  expect_equal(nrow(res), 2L)
  expect_equal(res$queried_name, c("Werneria nubigena", "Panthera leo"))

  res_clb <- clb_check_name(c("Werneria nubigena", "Panthera leo"))
  expect_equal(nrow(res_clb), 2L)
  expect_equal(res_clb$accepted_id, c("B87CR", "4CGXP"))
})
