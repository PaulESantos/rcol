# Name matching --------------------------------------------------------------

clb_match_req <- function(name = NULL, authorship = NULL, rank = NULL,
                          code = NULL, dataset = "3LXR", verbose = FALSE,
                          base_url = clb_base_url()) {
  req <- clb_request(base_url = base_url)
  req <- httr2::req_url_path_append(
    req, "dataset", as.character(dataset), "match", "nameusage"
  )
  q <- clb_query(
    q = name, authorship = authorship, rank = rank,
    code = code, verbose = verbose
  )
  if (length(q)) req <- httr2::req_url_query(req, !!!q)
  req
}

# Flatten a usage object (the matched usage or an alternative) into a row list.
clb_usage_row <- function(usage) {
  status <- usage$status %||% NA_character_
  class_first <- if (length(usage$classification)) usage$classification[[1]] else list()

  if (!is.na(status) && status == "synonym" && length(class_first)) {
    acc_id <- class_first$id %||% usage$parentId %||% NA_character_
    acc_name <- class_first$name %||% NA_character_
    acc_auth <- class_first$authorship %||% NA_character_
    acc_rank <- class_first$rank %||% usage$rank %||% NA_character_
  } else {
    acc_id <- usage$id %||% NA_character_
    acc_name <- usage$name %||% NA_character_
    acc_auth <- usage$authorship %||% NA_character_
    acc_rank <- usage$rank %||% NA_character_
  }

  list(
    usage_id = usage$id %||% NA_character_,
    name = usage$name %||% NA_character_,
    authorship = usage$authorship %||% NA_character_,
    rank = usage$rank %||% NA_character_,
    status = status,
    accepted_id = acc_id,
    accepted_name = acc_name,
    accepted_authorship = acc_auth,
    accepted_rank = acc_rank,
    code = usage$code %||% NA_character_,
    label = usage$label %||% NA_character_,
    parent_id = usage$parentId %||% NA_character_,
    names_index_id = usage$namesIndexId %||% NA_character_,
    names_index_match_type = usage$namesIndexMatchType %||% NA_character_,
    classification = list(usage$classification %||% list())
  )
}

# Build a one-row data list from a full match response.
clb_match_row <- function(resp) {
  usage <- resp$usage
  matched <- resp$match %||% !is.null(usage)
  row <- c(
    list(
      match = isTRUE(matched),
      match_type = resp$type %||% NA_character_
    ),
    clb_usage_row(usage %||% list())
  )
  row
}

#' Match a scientific name against a ChecklistBank dataset
#'
#' Looks up the single best-matching name usage for a scientific name in a
#' dataset, defaulting to the latest monthly extended Catalogue of Life release
#' (`"3LXR"`). This is the Catalogue of Life analogue of GBIF's name backbone
#' matching.
#'
#' @param name Scientific name to match. May include the authorship, or supply
#'   it separately via `authorship`.
#' @param authorship Optional authorship string.
#' @param rank Optional rank to disambiguate (e.g. `"species"`, `"genus"`).
#' @param code Optional nomenclatural code (`"zoological"`, `"botanical"`,
#'   `"bacterial"`, `"virus"`, ...).
#' @param dataset Dataset key or alias to match against. Defaults to `"3LXR"`.
#'   See [clb_col_release()] for the COL release aliases.
#' @param server Optional base URL of an alternative matching service, e.g. a
#'   locally running dockerized matching container
#'   (`"http://localhost:8080"`). Overrides `CLB_BASE_URL` for this call.
#' @param .raw Return the raw parsed JSON response instead of a tibble?
#'
#' @return A one-row [tibble][tibble::tibble] with the match outcome
#'   (`match`, `match_type`), the matched usage (`usage_id`, `name`,
#'   `authorship`, `rank`, `status`, ...) and a `classification` list-column.
#'   When nothing matches, `match` is `FALSE` and the usage columns are `NA`.
#' @seealso [clb_match_verbose()], [clb_match_checklist()]
#' @export
#' @examples
#' \dontrun{
#' clb_match("Panthera leo")
#' clb_match("Abies alba", rank = "species", code = "botanical")
#' clb_match("Felis catus", dataset = "COL25")
#' }
clb_match <- function(name, authorship = NULL, rank = NULL, code = NULL,
                      dataset = "3LXR", server = NULL, .raw = FALSE) {
  base_url <- server %||% clb_base_url()
  req <- clb_match_req(
    name = name, authorship = authorship, rank = rank, code = code,
    dataset = dataset, verbose = FALSE, base_url = base_url
  )
  resp <- httr2::resp_body_json(httr2::req_perform(req), simplifyVector = FALSE)
  if (isTRUE(.raw)) return(resp)
  tibble::as_tibble(clb_match_row(resp))
}

#' Match a name and return all candidate usages
#'
#' Like [clb_match()] but requests verbose output and returns the matched usage
#' together with all alternative candidates, one per row.
#'
#' @inheritParams clb_match
#'
#' @return A [tibble][tibble::tibble] of candidate usages with a logical
#'   `primary` column flagging the chosen match. Zero rows when nothing matched.
#' @seealso [clb_match()]
#' @export
#' @examples
#' \dontrun{
#' clb_match_verbose("Oenanthe")
#' }
clb_match_verbose <- function(name, authorship = NULL, rank = NULL, code = NULL,
                              dataset = "3LXR", server = NULL, .raw = FALSE) {
  base_url <- server %||% clb_base_url()
  req <- clb_match_req(
    name = name, authorship = authorship, rank = rank, code = code,
    dataset = dataset, verbose = TRUE, base_url = base_url
  )
  resp <- httr2::resp_body_json(httr2::req_perform(req), simplifyVector = FALSE)
  if (isTRUE(.raw)) return(resp)

  usages <- list()
  primary <- logical()
  if (!is.null(resp$usage)) {
    usages <- c(usages, list(resp$usage))
    primary <- c(primary, TRUE)
  }
  alts <- resp$alternatives %||% list()
  if (length(alts)) {
    usages <- c(usages, alts)
    primary <- c(primary, rep(FALSE, length(alts)))
  }
  if (!length(usages)) return(tibble::tibble())
  rows <- Map(function(u, p) {
    r <- clb_usage_row(u)
    r$primary <- p
    r
  }, usages, primary)
  out <- clb_bind_rows(rows)
  out[c("primary", setdiff(names(out), "primary"))]
}

#' Match a checklist of names in bulk
#'
#' Matches many names at once, issuing requests in parallel. Input columns are
#' echoed back on each row with a `verbatim_` prefix so results stay aligned
#' with the source.
#'
#' @param data A character vector of names, or a data frame. For a data frame,
#'   the columns named by `name`, `authorship`, `rank` and `code` are used
#'   (missing ones are ignored).
#' @param name,authorship,rank,code Column names in `data` (when `data` is a
#'   data frame) holding the respective fields.
#' @param dataset Dataset key or alias to match against. Defaults to `"3LXR"`.
#' @param server Optional alternative matching service base URL (see
#'   [clb_match()]).
#' @param max_active Maximum number of simultaneous HTTP requests.
#'
#' @return A [tibble][tibble::tibble] with one row per input, the `verbatim_*`
#'   input columns first followed by the match result columns of [clb_match()].
#' @seealso [clb_match()]
#' @export
#' @examples
#' \dontrun{
#' clb_match_checklist(c("Panthera leo", "Bufo bufo", "Abies alba"))
#'
#' df <- data.frame(
#'   sciname = c("Puma concolor", "Vulpes vulpes"),
#'   rank = c("species", "species")
#' )
#' clb_match_checklist(df, name = "sciname", rank = "rank")
#' }
clb_match_checklist <- function(data, name = "name", authorship = "authorship",
                                rank = "rank", code = "code", dataset = "3LXR",
                                server = NULL, max_active = 5L) {
  base_url <- server %||% clb_base_url()

  if (is.character(data) || is.factor(data)) {
    data <- tibble::tibble(name = as.character(data))
    name <- "name"
  }
  data <- tibble::as_tibble(data)

  pick <- function(col) if (!is.null(col) && col %in% names(data)) as.character(data[[col]]) else NULL
  names_v <- pick(name)
  if (is.null(names_v)) {
    cli::cli_abort("Column {.val {name}} not found in {.arg data}.")
  }
  auth_v <- pick(authorship)
  rank_v <- pick(rank)
  code_v <- pick(code)

  n <- nrow(data)
  reqs <- lapply(seq_len(n), function(i) {
    clb_match_req(
      name = names_v[[i]],
      authorship = if (!is.null(auth_v)) auth_v[[i]],
      rank = if (!is.null(rank_v)) rank_v[[i]],
      code = if (!is.null(code_v)) code_v[[i]],
      dataset = dataset, verbose = FALSE, base_url = base_url
    )
  })

  resps <- httr2::req_perform_parallel(reqs, max_active = max_active, on_error = "continue")
  rows <- lapply(resps, function(resp) {
    if (inherits(resp, "error") || inherits(resp, "condition")) {
      return(clb_match_row(list()))
    }
    clb_match_row(httr2::resp_body_json(resp, simplifyVector = FALSE))
  })
  result <- clb_bind_rows(rows)

  verbatim <- data
  names(verbatim) <- paste0("verbatim_", names(verbatim))
  tibble::as_tibble(c(as.list(verbatim), as.list(result)))
}

#' Extract taxonomic classification from a match or usage result
#'
#' Helper function to extract and unnest the nested `classification` list-column
#' returned by [clb_match()], [clb_match_checklist()], [col_match()], or
#' [clb_usage_search()] into a tidy long or wide tibble. Also accepts a character
#' vector of scientific names directly.
#'
#' @param data A character vector of scientific names, or a data frame / tibble
#'   returned by a matching or usage function that contains a `classification`
#'   list-column.
#' @param wide Logical. If `TRUE`, pivots the major ranks (`kingdom`, `phylum`,
#'   `class`, `order`, `family`, `genus`, `species`) into columns alongside each
#'   input row. If `FALSE` (the default), returns a long tibble of all
#'   classification levels.
#' @param dataset Dataset key or alias used when `data` is a character vector.
#'   Defaults to `"3LXR"`.
#' @param ... Further query parameters passed to [clb_match()] or
#'   [clb_match_checklist()] when `data` is a character vector.
#'
#' @return A [tibble][tibble::tibble].
#' @seealso [clb_match()], [col_match()], [clb_classification()]
#' @export
#' @examples
#' \dontrun{
#' # Pass a character string directly:
#' col_extract_classification("Schinus molle")
#' col_extract_classification("Schinus molle", wide = TRUE)
#' col_extract_classification(c("Schinus molle", "Panthera leo"), wide = TRUE)
#'
#' # Pass a match result data frame:
#' res <- col_match("Schinus molle")
#' col_extract_classification(res)
#' }
clb_extract_classification <- function(data, wide = FALSE, dataset = "3LXR", ...) {
  if (is.character(data) || is.factor(data)) {
    names_vec <- as.character(data)
    if (length(names_vec) == 1L) {
      data <- clb_match(names_vec, dataset = dataset, ...)
    } else {
      data <- clb_match_checklist(names_vec, dataset = dataset, ...)
    }
  }

  if (!"classification" %in% names(data)) {
    cli::cli_abort("Column {.val classification} not found in {.arg data}.")
  }

  class_list <- data[["classification"]]

  if (isFALSE(wide)) {
    rows <- lapply(seq_along(class_list), function(i) {
      item <- class_list[[i]]
      if (!length(item) || is.null(item)) return(tibble::tibble())
      tb <- clb_records_to_tibble(item)
      if ("name" %in% names(data)) tb$matched_name <- data$name[[i]]
      if ("verbatim_name" %in% names(data)) tb$verbatim_name <- data$verbatim_name[[i]]
      if ("labelHtml" %in% names(tb)) {
        tb$label <- gsub("<[^>]+>", "", tb$labelHtml)
        tb$labelHtml <- NULL
      } else if ("label" %in% names(tb)) {
        tb$label <- gsub("<[^>]+>", "", tb$label)
      }
      tb
    })
    rows <- rows[vapply(rows, nrow, integer(1)) > 0L]
    if (!length(rows)) return(tibble::tibble())
    all_keys <- unique(unlist(lapply(rows, names)))
    rows <- lapply(rows, function(df) {
      missing_keys <- setdiff(all_keys, names(df))
      for (k in missing_keys) df[[k]] <- NA
      df[all_keys]
    })
    return(tibble::as_tibble(do.call(rbind, rows)))
  } else {
    major_ranks <- c("kingdom", "phylum", "class", "order", "family", "genus", "species")
    wide_rows <- lapply(seq_along(class_list), function(i) {
      item <- class_list[[i]]
      row_list <- stats::setNames(as.list(rep(NA_character_, length(major_ranks))), major_ranks)
      if (length(item) && is.list(item)) {
        for (taxon in item) {
          rk <- tolower(taxon$rank %||% "")
          if (rk %in% major_ranks) {
            row_list[[rk]] <- taxon$name %||% NA_character_
          }
        }
      }
      # Populate the matched usage's own rank if it is one of the major ranks
      if ("rank" %in% names(data) && "name" %in% names(data)) {
        self_rk <- tolower(data$rank[[i]] %||% "")
        if (self_rk %in% major_ranks && is.na(row_list[[self_rk]])) {
          row_list[[self_rk]] <- data$name[[i]]
        }
      }
      row_list
    })
    wide_tb <- clb_bind_rows(wide_rows)
    data_clean <- data[setdiff(names(data), "classification")]
    tibble::as_tibble(c(as.list(data_clean), as.list(wide_tb)))
  }
}

#' @rdname clb_extract_classification
#' @export
col_extract_classification <- clb_extract_classification


#' Resolve and verify valid species names
#'
#' Provides a clean, simplified verification table for one or more scientific
#' names. Unlike [col_match()], which returns full raw API columns and list
#' columns, `col_resolve_name()` returns only the essential fields needed to
#' verify whether a name is accepted or a synonym, and what its accepted name is.
#'
#' @inheritParams clb_match
#' @param name A scientific name string or character vector of scientific names.
#' @return A [tibble::tibble] with columns:
#'   \item{queried_name}{The original scientific name queried.}
#'   \item{match}{Logical indicator of whether a match was found.}
#'   \item{match_type}{Type of match (`"exact"`, `"variant"`, `"fuzzy"`, etc.).}
#'   \item{status}{Taxonomic status of the queried name (`"accepted"`, `"synonym"`).}
#'   \item{matched_name}{Scientific name returned by the match service.}
#'   \item{accepted_name}{The valid/accepted scientific name.}
#'   \item{accepted_authorship}{Authorship of the accepted scientific name.}
#'   \item{accepted_rank}{Taxonomic rank of the accepted name.}
#'   \item{accepted_id}{ChecklistBank usage ID of the accepted name.}
#'
#' @export
#' @examples
#' \dontrun{
#' # Resolve a single name
#' col_resolve_name("Werneria nubigena")
#'
#' # Check multiple names at once
#' col_check_name(c("Werneria nubigena", "Panthera leo", "Schinus molle"))
#' }
clb_resolve_name <- function(name, authorship = NULL, rank = NULL, code = NULL, dataset = "3LXR", server = NULL) {
  if (is.character(name) && length(name) > 1) {
    df <- tibble::tibble(name = name)
    if (!is.null(authorship)) df$authorship <- authorship
    if (!is.null(rank)) df$rank <- rank
    if (!is.null(code)) df$code <- code
    res <- clb_match_checklist(df, name = "name", dataset = dataset, server = server)
    out <- tibble::tibble(
      queried_name = res$verbatim_name,
      matched_name = res$name,
      status = res$status,
      accepted_name = res$accepted_name,
      accepted_authorship = res$accepted_authorship,
      accepted_rank = res$accepted_rank %||% res$rank,
      accepted_id = res$accepted_id,
      match = res$match,
      match_type = res$match_type
    )
    return(out)
  }

  res <- clb_match(name = name, authorship = authorship, rank = rank, code = code, dataset = dataset, server = server)
  tibble::tibble(
    queried_name = name,
    matched_name = res$name,
    status = res$status,
    accepted_name = res$accepted_name,
    accepted_authorship = res$accepted_authorship,
    accepted_rank = res$accepted_rank %||% res$rank,
    accepted_id = res$accepted_id,
    match = res$match,
    match_type = res$match_type
  )
}

#' @rdname clb_resolve_name
#' @export
col_resolve_name <- function(name, authorship = NULL, rank = NULL, code = NULL, server = NULL) {
  clb_resolve_name(name = name, authorship = authorship, rank = rank, code = code, dataset = col_key(), server = server)
}

#' @rdname clb_resolve_name
#' @export
col_check_name <- col_resolve_name

#' @rdname clb_resolve_name
#' @export
clb_check_name <- clb_resolve_name


