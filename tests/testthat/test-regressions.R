test_that("taxon IDs skip missing candidates and reject unresolved inputs", {
  expect_identical(clb_resolve_taxon_id(data.frame(
    match = TRUE, accepted_id = NA_character_, usage_id = "VALID"
  )), "VALID")
  expect_identical(clb_resolve_taxon_id(data.frame(
    accepted_id = "", usage_id = NA_character_, id = "ID"
  )), "ID")
  expect_error(clb_resolve_taxon_id(data.frame(match = FALSE, usage_id = "X")), "valid taxon ID")
  expect_error(clb_resolve_taxon_id(data.frame(other = "X")), "valid taxon ID")
  expect_error(clb_resolve_taxon_id(data.frame(id = character())), "valid taxon ID")
  expect_error(clb_resolve_taxon_id(NA_character_), "valid taxon ID")
  expect_error(clb_resolve_taxon_id(character()), "valid taxon ID")
  expect_error(clb_resolve_taxon_id(" "), "valid taxon ID")
})

test_that("lookup failures propagate and only missing IDs fall back to names", {
  local_mocked_bindings(
    clb_get = function(...) rlang::abort("Unavailable", class = "httr2_http_503"),
    clb_match = function(...) stop("Unexpected matching")
  )
  expect_error(clb_resolve_taxon_id("ABC"), class = "httr2_http_503")
  local_mocked_bindings(
    clb_get = function(...) rlang::abort("Missing", class = "httr2_http_404"),
    clb_match = function(...) tibble::tibble(match = TRUE, accepted_id = "FOUND")
  )
  expect_identical(clb_resolve_taxon_id("Panthera"), "FOUND")
  expect_identical(clb_resolve_taxon_id("Panthera leo"), "FOUND")
})

test_that("batch matching distinguishes failure from non-match without losing order", {
  ok <- httr2::response(200, headers = list(`content-type` = "application/json"),
                       body = charToRaw('{"match":true,"usage":{"id":"A","name":"Aus bus"}}'))
  none <- httr2::response(200, headers = list(`content-type` = "application/json"),
                         body = charToRaw('{"match":false,"type":"none"}'))
  bad <- httr2::response(200, headers = list(`content-type` = "application/json"),
                        body = charToRaw('invalid json'))
  httr2::local_mocked_responses(list(
    ok, httr2::response(404, body = charToRaw("Not found")), none, bad
  ))
  out <- clb_match_checklist(c("Aus bus", "Failed name", "Absent name", "Bad JSON"))
  expect_identical(out$verbatim_name, c("Aus bus", "Failed name", "Absent name", "Bad JSON"))
  expect_identical(out$match, c(TRUE, NA, FALSE, NA))
  expect_true(is.na(out$error[[1]]))
  expect_match(out$error[[2]], "404")
  expect_true(is.na(out$error[[3]]))
  expect_true(nzchar(out$error[[4]]))
})

test_that("distribution batches retain provenance after splitting and empty responses", {
  local_mocked_bindings(clb_get = function(...) {
    path <- list(...)
    id <- path[[4]]
    if (tail(path, 1)[[1]] == "distribution") {
      if (id == "B") return(list())
      return(list(list(area = list(name = "Peru; Ecuador"))))
    }
    list(id = id, name = list(scientificName = paste("Species", id)))
  })
  out <- clb_distribution(c("A", "B", "C"))
  expect_identical(out$input_row, c(1L, 1L, 3L, 3L))
  expect_identical(out$scientific_name, c("Species A", "Species A", "Species C", "Species C"))
  expect_identical(out$area, rep(c("Peru", "Ecuador"), 2))
  df <- tibble::tibble(accepted_id = c("A", "C"), accepted_name = c("First", "Last"))
  expect_identical(clb_distribution(df, full = TRUE)$scientific_name, rep(c("First", "Last"), each = 2))
})

test_that("wide classification uses IDs and resolve results and raw takes precedence", {
  ancestors <- list(list(id = "G", name = "Panthera", rank = "genus"))
  local_mocked_bindings(
    clb_match = function(...) stop("IDs must not be matched as names"),
    clb_get = function(...) {
      path <- list(...)
      if (tail(path, 1)[[1]] == "classification") return(ancestors)
      list(id = "4CGXP", name = list(scientificName = "Panthera leo", rank = "species"))
    }
  )
  out <- clb_classification("4CGXP", wide = TRUE)
  expect_identical(out$genus, "Panthera")
  expect_identical(out$species, "Panthera leo")
  expect_equal(clb_classification(tibble::tibble(accepted_id = "4CGXP"), wide = TRUE), out)
  expect_identical(clb_classification(c("4CGXP", "4CGXP"), wide = TRUE)$species,
                   c("Panthera leo", "Panthera leo"))
  expect_identical(clb_classification("4CGXP", wide = TRUE, .raw = TRUE), ancestors)
})

test_that("raw batches preserve complete nested responses and empty entries", {
  payload <- list(id = "A", status = "accepted", name = list(
    scientificName = "Aus bus", authorship = "L.", rank = "species"
  ), nested = list(list(x = 1), list(x = 2)))
  local_mocked_bindings(
    clb_resolve_taxon_id = function(id, ...) if (is.data.frame(id)) id$id[[1]] else id,
    clb_get = function(...) {
      path <- list(...)
      if (path[[4]] == "B") list() else payload
    }
  )
  expected <- list(payload, list())
  expect_identical(clb_usage(c("A", "B"), .raw = TRUE), expected)
  expect_identical(clb_usage(data.frame(id = c("A", "B")), .raw = TRUE), expected)
  expect_identical(clb_synonyms(c("A", "B"), .raw = TRUE), expected)
  expect_identical(clb_synonyms(data.frame(id = c("A", "B")), .raw = TRUE), expected)
  expect_identical(clb_vernacular(c("A", "B"), .raw = TRUE), expected)
  expect_identical(clb_vernacular(data.frame(id = c("A", "B")), .raw = TRUE), expected)
  expect_identical(clb_distribution(c("A", "B"), .raw = TRUE), expected)
  expect_identical(clb_distribution(data.frame(id = c("A", "B")), .raw = TRUE), expected)
})
