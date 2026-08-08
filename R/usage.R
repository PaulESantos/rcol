# Name usages, taxa and related information ----------------------------------

# Hoist the most useful name fields out of the nested `name` object so a usage
# becomes a tidy single row; keep the full name object as a list-column.
clb_flatten_usage <- function(u) {
  nm <- u$name %||% list()
  list(
    id = u$id %||% NA_character_,
    scientific_name = nm$scientificName %||% u$name$scientificName %||% NA_character_,
    authorship = nm$authorship %||% NA_character_,
    rank = nm$rank %||% NA_character_,
    status = u$status %||% NA_character_,
    label = u$label %||% NA_character_,
    parent_id = u$parentId %||% NA_character_,
    extinct = u$extinct %||% NA,
    name = list(nm)
  )
}

# Recursively collect usage-like objects from (possibly nested) JSON nodes.
clb_as_usage_list <- function(x) {
  if (is.null(x)) return(list())
  if (!is.null(names(x)) && any(c("name", "id") %in% names(x))) return(list(x))
  if (is.list(x)) return(unlist(lapply(x, clb_as_usage_list), recursive = FALSE))
  list()
}

#' Get a name usage (taxon or synonym) by id
#'
#' @param id Usage id within the dataset.
#' @param dataset Dataset key or alias. Defaults to `"3LXR"`.
#' @param .raw Return the raw parsed JSON instead of a tibble?
#'
#' @return A one-row [tibble][tibble::tibble] with the usage's `id`,
#'   `scientific_name`, `authorship`, `rank`, `status`, `label`, `parent_id`
#'   and the full nested `name` as a list-column.
#' @seealso [clb_usage_search()], [clb_classification()], [clb_synonyms()]
#' @export
#' @examples
#' \dontrun{
#' clb_usage("4CGXP", dataset = "3LR")
#' }
clb_usage <- function(id, dataset = "3LXR", .raw = FALSE) {
  if (is.data.frame(id) && nrow(id) > 1L) {
    rows <- lapply(seq_len(nrow(id)), function(i) clb_usage(id[i, ], dataset = dataset, .raw = .raw))
    return(clb_bind_rows(rows))
  }
  if (is.character(id) && length(id) > 1L) {
    rows <- lapply(id, function(item) clb_usage(item, dataset = dataset, .raw = .raw))
    return(clb_bind_rows(rows))
  }
  resolved_id <- clb_resolve_taxon_id(id, dataset = dataset)
  resp <- clb_get("dataset", as.character(dataset), "nameusage", as.character(resolved_id))
  if (isTRUE(.raw)) return(resp)
  tibble::as_tibble(clb_flatten_usage(resp))
}

#' Full-text search of name usages
#'
#' Searches name usages within a dataset (defaults to the latest extended COL
#' release). The accepted/synonym usage fields are hoisted to top-level columns;
#' the taxonomic classification and full name object are kept as list-columns.
#'
#' @param q Free-text query. Optional (omit to browse with filters only).
#' @param dataset Dataset key or alias. Defaults to `"3LXR"`.
#' @param rank Filter by rank (e.g. `"species"`).
#' @param status Filter by taxonomic status (e.g. `"accepted"`, `"synonym"`).
#' @param ... Further query parameters forwarded to the search endpoint
#'   (e.g. `extinct`, `nomCode`, `minRank`, `maxRank`, `type`).
#' @param limit Page size per request.
#' @param max Maximum number of usages to return. Use `Inf` to fetch all.
#'
#' @return A `clb` object: a list with `$data` (a [tibble][tibble::tibble] of
#'   usages) and `$meta` (with `total`).
#' @seealso [clb_match()], [clb_suggest()], [clb_usage()]
#' @export
#' @examples
#' \dontrun{
#' clb_usage_search("Felidae")
#' clb_usage_search("Panthera", rank = "species", status = "accepted")
#' }
clb_usage_search <- function(q = NULL, dataset = "3LXR", rank = NULL,
                             status = NULL, ..., limit = 50L, max = limit) {
  paged <- clb_get_paged(
    "dataset", as.character(dataset), "nameusage", "search",
    query = clb_query(q = q, rank = rank, status = status, ...),
    limit = limit, max = max
  )
  rows <- lapply(paged$result, function(w) {
    row <- clb_flatten_usage(w$usage %||% list())
    row$group <- w$group %||% NA_character_
    row$classification <- list(w$classification %||% list())
    row
  })
  new_clb(data = clb_bind_rows(rows), meta = list(total = paged$total))
}

#' @rdname clb_usage_search
#' @export
clb_search <- clb_usage_search

#' Autocomplete suggestions for name usages
#'
#' Fast prefix-based suggestions, suitable for type-ahead lookups.
#'
#' @param q Partial name to complete.
#' @param dataset Dataset key or alias. Defaults to `"3LXR"`.
#' @param ... Further query parameters (e.g. `rank`, `status`).
#' @param .raw Return the raw parsed JSON instead of a tibble?
#'
#' @return A [tibble][tibble::tibble] of suggestions with columns such as
#'   `suggestion`, `usageId`, `rank`, `status` and `group`.
#' @seealso [clb_usage_search()]
#' @export
#' @examples
#' \dontrun{
#' clb_suggest("Panth")
#' }
clb_suggest <- function(q, dataset = "3LXR", ..., .raw = FALSE) {
  resp <- clb_get(
    "dataset", as.character(dataset), "nameusage", "suggest",
    query = clb_query(q = q, ...)
  )
  if (isTRUE(.raw)) return(resp)
  clb_records_to_tibble(resp)
}

#' Classification hierarchy of a taxon
#'
#' Retrieves the ordered classification hierarchy (ancestors) for a taxon in a dataset.
#' Accepts a taxon ID, a scientific name, or a data frame from [col_check_name()] or [col_match()].
#'
#' @param id Taxon id (character), scientific name, or a data frame from [col_match()] or [col_check_name()].
#' @param dataset Dataset key or alias. Defaults to `"3LXR"`.
#' @param wide Logical. If `TRUE`, returns major ranks in wide format columns (`kingdom` to `species`).
#' @param .raw Return the raw parsed JSON instead of a tibble?
#'
#' @return A [tibble][tibble::tibble] of ancestors or classification.
#' @seealso [clb_usage()], [clb_children()], [clb_extract_classification()]
#' @export
#' @examples
#' \dontrun{
#' clb_classification("4CGXP", dataset = "3LR")
#' clb_classification("Schinus molle")
#' clb_classification("Schinus molle", wide = TRUE)
#' }
clb_classification <- function(id, dataset = "3LXR", wide = FALSE, .raw = FALSE) {
  if (isTRUE(wide)) {
    return(clb_extract_classification(data = id, wide = TRUE, dataset = dataset))
  }

  resolved_id <- clb_resolve_taxon_id(id, dataset = dataset)
  resp <- clb_get("dataset", as.character(dataset), "taxon", as.character(resolved_id), "classification")
  if (isTRUE(.raw)) return(resp)

  out <- clb_records_to_tibble(resp)
  if (!is.data.frame(out) || !nrow(out)) return(out)

  if ("name" %in% names(out)) {
    names(out)[names(out) == "name"] <- "scientific_name"
  }
  if ("labelHtml" %in% names(out)) {
    names(out)[names(out) == "labelHtml"] <- "full_name"
  } else if ("label" %in% names(out)) {
    names(out)[names(out) == "label"] <- "full_name"
  }

  if ("full_name" %in% names(out)) {
    out$full_name <- gsub("<[^>]+>", "", out$full_name)
  }

  preferred_cols <- c("id", "scientific_name", "authorship", "rank", "full_name")
  present_cols <- intersect(preferred_cols, names(out))
  other_cols <- setdiff(names(out), present_cols)

  out[c(present_cols, other_cols)]
}

#' Synonyms of a taxon
#'
#' @param id Taxon id (character), scientific name, or a data frame from [col_match()] or [col_check_name()].
#' @param dataset Dataset key or alias. Defaults to `"3LXR"`.
#' @param full Logical. If `FALSE` (default), returns the 6 essential columns: `accepted_name`, `scientific_name`, `authorship`, `synonym_type`, `rank`, `full_name`. If `TRUE`, includes secondary metadata.
#' @param .raw Return the raw parsed JSON instead of a tibble?
#'
#' @return A [tibble][tibble::tibble] of synonym usages.
#' @seealso [clb_usage()]
#' @export
#' @examples
#' \dontrun{
#' clb_synonyms("6DBT", dataset = "3LR")
#' clb_synonyms("Werneria nubigena")
#' }
clb_synonyms <- function(id, dataset = "3LXR", full = FALSE, .raw = FALSE) {
  if (is.data.frame(id) && nrow(id) > 1L) {
    rows <- lapply(seq_len(nrow(id)), function(i) clb_synonyms(id[i, ], dataset = dataset, full = full, .raw = .raw))
    return(clb_bind_rows(rows))
  }
  if (is.character(id) && length(id) > 1L) {
    rows <- lapply(id, function(item) clb_synonyms(item, dataset = dataset, full = full, .raw = .raw))
    return(clb_bind_rows(rows))
  }
  acc_id <- clb_resolve_taxon_id(id, dataset = dataset)
  acc_name <- NA_character_
  acc_auth <- NA_character_

  if (is.data.frame(id)) {
    df <- id
    acc_name <- df$accepted_name[[1]] %||% NA_character_
    acc_auth <- df$accepted_authorship[[1]] %||% NA_character_
  }

  if (is.null(acc_id) || is.na(acc_id)) {
    cli::cli_abort("Could not resolve a valid taxon ID from {.arg id}.")
  }

  # If acc_id is a synonym ID, automatically resolve its accepted taxon
  usage_info <- tryCatch(clb_usage(acc_id, dataset = dataset), error = function(e) NULL)
  if (!is.null(usage_info) && nrow(usage_info) > 0) {
    if (identical(usage_info$status[[1]], "synonym") && !is.na(usage_info$parent_id[[1]])) {
      acc_id <- usage_info$parent_id[[1]]
      parent_info <- tryCatch(clb_usage(acc_id, dataset = dataset), error = function(e) NULL)
      if (!is.null(parent_info) && nrow(parent_info) > 0) {
        acc_name <- parent_info$scientific_name[[1]] %||% NA_character_
        acc_auth <- parent_info$authorship[[1]] %||% NA_character_
      }
    } else if (identical(usage_info$status[[1]], "accepted")) {
      acc_name <- usage_info$scientific_name[[1]] %||% NA_character_
      acc_auth <- usage_info$authorship[[1]] %||% NA_character_
    }
  }

  resp <- clb_get("dataset", as.character(dataset), "taxon", as.character(acc_id), "synonyms")
  if (isTRUE(.raw)) return(resp)

  homo <- clb_as_usage_list(resp$homotypic)
  het <- clb_as_usage_list(resp$heterotypic)
  if (!length(het) && !is.null(resp$heterotypicGroups)) {
    het <- clb_as_usage_list(resp$heterotypicGroups)
  }
  tag <- function(lst, type) lapply(lst, function(s) {
    r <- clb_flatten_usage(s)
    r$synonym_type <- type
    r$accepted_id <- acc_id
    r$accepted_name <- acc_name
    r$accepted_authorship <- acc_auth
    r
  })
  rows <- c(tag(homo, "homotypic"), tag(het, "heterotypic"))
  if (!length(rows)) {
    return(tibble::tibble(
      accepted_name = character(),
      scientific_name = character(),
      authorship = character(),
      synonym_type = character(),
      rank = character(),
      full_name = character()
    ))
  }
  out <- clb_bind_rows(rows)

  if ("label" %in% names(out)) {
    names(out)[names(out) == "label"] <- "full_name"
  }

  preferred_6 <- c("accepted_name", "scientific_name", "authorship", "synonym_type", "rank", "full_name")
  present_6 <- intersect(preferred_6, names(out))

  if (!isTRUE(full)) {
    return(out[present_6])
  }

  other_cols <- setdiff(names(out), present_6)
  out[c(present_6, other_cols)]
}

#' Vernacular (common) names
#'
#' Looks up vernacular names either for a single taxon (when `id` or scientific name is given) or
#' across a dataset by free-text query.
#'
#' @param id Optional taxon id, scientific name, or a data frame from [col_match()]. When supplied,
#'   returns the vernacular names of that taxon; otherwise performs a dataset-wide search using `q`.
#' @param dataset Dataset key or alias. Defaults to `"3LXR"`.
#' @param q Free-text query for the dataset-wide search (ignored when `id` is supplied).
#' @param lang Optional ISO language filter (e.g. `"eng"`, `"deu"`).
#' @param ... Further query parameters.
#' @param limit Page size for the dataset-wide search.
#' @param max Maximum rows for the dataset-wide search.
#' @param full Logical; if `FALSE` (default), returns clean essential columns. If `TRUE`, includes full metadata.
#' @param .raw Return the raw parsed JSON instead of a tibble?
#'
#' @return A [tibble][tibble::tibble] of vernacular names.
#' @export
#' @examples
#' \dontrun{
#' clb_vernacular(id = "4CGXP", dataset = "3LR")
#' clb_vernacular(id = "Panthera leo")
#' clb_vernacular(q = "lion", lang = "eng")
#' }
clb_vernacular <- function(id = NULL, dataset = "3LXR", q = NULL, lang = NULL,
                           ..., limit = 50L, max = limit, full = FALSE, .raw = FALSE) {
  if (!is.null(id) && is.data.frame(id) && nrow(id) > 1L) {
    rows <- lapply(seq_len(nrow(id)), function(i) {
      clb_vernacular(id = id[i, ], dataset = dataset, q = q, lang = lang, ..., limit = limit, max = max, full = full, .raw = .raw)
    })
    return(clb_bind_rows(rows))
  }
  if (!is.null(id) && is.character(id) && length(id) > 1L) {
    rows <- lapply(id, function(item) {
      clb_vernacular(id = item, dataset = dataset, q = q, lang = lang, ..., limit = limit, max = max, full = full, .raw = .raw)
    })
    return(clb_bind_rows(rows))
  }

  sciname <- NA_character_
  if (!is.null(id) && is.data.frame(id)) {
    sciname <- id$accepted_name[[1]] %||% id$matched_name[[1]] %||% id$queried_name[[1]] %||% NA_character_
  }

  raw_tb <- if (!is.null(id)) {
    resolved_id <- clb_resolve_taxon_id(id, dataset = dataset)
    if (is.na(sciname)) {
      u <- tryCatch(clb_usage(resolved_id, dataset = dataset), error = function(e) NULL)
      if (!is.null(u) && "scientific_name" %in% names(u)) {
        sciname <- u$scientific_name[[1]]
      }
    }
    resp <- clb_get(
      "dataset", as.character(dataset), "taxon", as.character(resolved_id), "vernacular",
      query = clb_query(lang = lang)
    )
    if (isTRUE(.raw)) return(resp)
    tb <- clb_records_to_tibble(resp)
    if (is.data.frame(tb) && nrow(tb) > 0 && !is.na(sciname)) {
      tb$scientific_name <- sciname
    }
    tb
  } else {
    paged <- clb_get_paged(
      "dataset", as.character(dataset), "vernacular",
      query = clb_query(q = q, lang = lang, ...),
      limit = limit, max = max
    )
    if (isTRUE(.raw)) return(paged)
    clb_records_to_tibble(paged$result)
  }

  if (!is.data.frame(raw_tb) || !nrow(raw_tb)) return(raw_tb)

  preferred_cols <- c("scientific_name", "name", "language", "country", "area", "latin", "taxonID", "taxon_id", "remarks")
  present_cols <- intersect(preferred_cols, names(raw_tb))
  metadata_cols <- c("created", "createdBy", "modified", "modifiedBy", "datasetKey", "id", "sectorKey", "verbatimKey", "verbatimSourceKey", "referenceId", "reference_id")

  if (!isTRUE(full) && length(present_cols) > 0) {
    return(raw_tb[present_cols])
  }

  clean_cols <- setdiff(names(raw_tb), metadata_cols)
  ordered_cols <- unique(c(present_cols, clean_cols))

  raw_tb[ordered_cols]
}

#' Metrics for a taxon
#'
#' Returns subtree metrics for a taxon: tree depth, child and species counts,
#' and a by-rank breakdown of descendants.
#'
#' @param id Taxon id, scientific name, or a data frame from [col_match()].
#' @param dataset Dataset key or alias. Defaults to `"3LXR"`.
#' @param .raw Return the raw parsed JSON instead of a tibble?
#'
#' @return A one-row [tibble][tibble::tibble] of metrics. Map fields such as
#'   `taxaByRankCount` are returned as list-columns.
#' @seealso [clb_dataset_metrics()], [clb_children()]
#' @export
#' @examples
#' \dontrun{
#' clb_usage_metrics("4CGXP", dataset = "3LR")
#' clb_usage_metrics("Panthera leo")
#' }
clb_usage_metrics <- function(id, dataset = "3LXR", .raw = FALSE) {
  resolved_id <- clb_resolve_taxon_id(id, dataset = dataset)
  resp <- clb_get("dataset", as.character(dataset), "taxon", as.character(resolved_id), "metrics")
  if (isTRUE(.raw)) return(resp)
  clb_records_to_tibble(list(resp))
}


#' Geographic distribution for a taxon
#'
#' Retrieves geographic distribution records (regions, countries) for a taxon.
#' By default, returns only the clean `area` column in tidy format.
#'
#' @param id Taxon id (character), scientific name, or a data frame from [col_match()] or [col_check_name()].
#' @param dataset Dataset key or alias. Defaults to `"3LXR"`.
#' @param tidy Logical. If `TRUE` (default), splits semicolon-delimited areas into distinct rows.
#' @param full Logical. If `FALSE` (default), returns only the essential `area` column. If `TRUE`, includes secondary metadata (`gazetteer`, `status`, `remarks`, `reference_id`).
#' @param .raw Return the raw parsed JSON instead of a tibble?
#'
#' @return A [tibble][tibble::tibble] of distribution records.
#' @export
#' @examples
#' \dontrun{
#' # Distribution for Panthera leo (by ID or Scientific Name)
#' clb_distribution("4CGXP")
#' clb_distribution("Panthera leo")
#'
#' # Distribution by passing col_check_name result directly
#' sp_info <- col_check_name("Schinus molle")
#' col_distribution(sp_info)
#' }
clb_distribution <- function(id, dataset = "3LXR", tidy = TRUE, full = FALSE, .raw = FALSE) {
  if (is.data.frame(id) && nrow(id) > 1L) {
    rows <- lapply(seq_len(nrow(id)), function(i) {
      clb_distribution(id = id[i, ], dataset = dataset, tidy = tidy, full = full, .raw = .raw)
    })
    return(clb_bind_rows(rows))
  }
  if (is.character(id) && length(id) > 1L) {
    rows <- lapply(id, function(item) {
      clb_distribution(id = item, dataset = dataset, tidy = tidy, full = full, .raw = .raw)
    })
    return(clb_bind_rows(rows))
  }

  sciname <- NA_character_
  if (is.data.frame(id)) {
    sciname <- id$accepted_name[[1]] %||% id$matched_name[[1]] %||% id$queried_name[[1]] %||% NA_character_
  }

  resolved_id <- clb_resolve_taxon_id(id, dataset = dataset)

  if (is.null(resolved_id) || is.na(resolved_id)) {
    cli::cli_abort("Could not resolve a valid taxon ID from {.arg id}.")
  }

  if (is.na(sciname)) {
    u <- tryCatch(clb_usage(resolved_id, dataset = dataset), error = function(e) NULL)
    if (!is.null(u) && "scientific_name" %in% names(u)) {
      sciname <- u$scientific_name[[1]]
    }
  }

  resp <- clb_get("dataset", as.character(dataset), "taxon", as.character(resolved_id), "distribution")
  if (isTRUE(.raw)) return(resp)
  if (!length(resp)) return(tibble::tibble(area = character()))

  rows <- lapply(resp, function(item) {
    area_name <- if (!is.null(item$area)) item$area$name %||% NA_character_ else NA_character_
    gazetteer <- if (!is.null(item$area)) item$area$gazetteer %||% NA_character_ else NA_character_
    status <- item$status %||% NA_character_
    remarks <- item$remarks %||% NA_character_
    ref_id <- item$referenceId %||% NA_character_

    list(
      scientific_name = sciname,
      area = area_name,
      gazetteer = gazetteer,
      status = status,
      remarks = remarks,
      reference_id = ref_id
    )
  })

  out <- clb_bind_rows(rows)

  if (isTRUE(tidy) && nrow(out) > 0 && "area" %in% names(out)) {
    split_rows <- lapply(seq_len(nrow(out)), function(i) {
      row <- out[i, , drop = FALSE]
      area_val <- row$area[[1]]
      if (is.na(area_val) || !nchar(area_val)) return(row)
      areas <- unlist(strsplit(area_val, ";\\s*"))
      areas <- trimws(areas)
      areas <- areas[nchar(areas) > 0]
      if (length(areas) <= 1) return(row)

      res <- row[rep(1, length(areas)), , drop = FALSE]
      res$area <- areas
      res
    })
    out <- clb_bind_rows(split_rows)
  }

  preferred_cols <- if (!is.na(sciname) && (is.data.frame(id) && nrow(id) > 1L || is.character(id) && length(id) > 1L)) c("scientific_name", "area") else "area"
  if (!isTRUE(full)) {
    present_cols <- intersect(preferred_cols, names(out))
    if (length(present_cols) > 0) return(out[present_cols])
  }

  full_cols <- if (!is.na(sciname) && (is.data.frame(id) && nrow(id) > 1L || is.character(id) && length(id) > 1L)) {
    c("scientific_name", "area", "gazetteer", "status", "remarks", "reference_id")
  } else {
    c("area", "gazetteer", "status", "remarks", "reference_id")
  }
  out[intersect(full_cols, names(out))]
}

#' @rdname clb_distribution
#' @export
col_distribution <- function(id, tidy = TRUE, full = FALSE, .raw = FALSE) {
  clb_distribution(id = id, dataset = col_key(), tidy = tidy, full = full, .raw = .raw)
}

