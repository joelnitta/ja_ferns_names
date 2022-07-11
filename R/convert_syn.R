
#' Convert a single name from synonym to accepted
#'
#' Also re-maps any synonyms from the former accepted name to the new accepted
#' name
#'
#' @param tax_dat Dataframe; taxonomic database in Darwin Core format.
#' @param name_convert Character vector of length 1;
#' scientific name to convert from synonym to accepted name.
#' @param strict Logical; should taxonomic checks be run on the updated taxonomic database with dct_validate()?
#' @param ... Additional arguments passed to dct_validate().
#'
#' @return Dataframe; taxonomic database in Darwin Core format.
#'
#' @examples
convert_syn_single <- function(tax_dat, name_convert, strict = TRUE, ...) {

	# First check that name is in the taxonomic data
	if (!name_convert %in% tax_dat$scientificName) {
		warning(
			glue::glue("Name '{name_convert}' not in tax_dat, returning original data")) # nolint
		return(tax_dat)
	}

	# Lookup the scientific name to make into a synonym
	name_to_make_syn_tbl <-
		tax_dat %>%
		filter(scientificName == name_convert)

	# No change to make if name_convert is already accepted
	# (has no synonyms to look up)
	if (is.na(name_to_make_syn_tbl$acceptedNameUsageID)) {
		warning(
			glue::glue("Name '{name_convert}' already accepted, returning original data")) # nolint
		return(tax_dat)
	}

	name_to_make_syn <-
		name_to_make_syn_tbl %>%
		select(taxonID = acceptedNameUsageID) %>%
		left_join(tax_dat, by = "taxonID") %>%
		pull(scientificName)


	res <- tax_dat %>%
		# Change target name to accepted
		dct_change_status(
			sci_name = name_convert,
			new_status = "accepted"
		) %>%
		# Change accepted name to synonym
		dct_change_status(
			sci_name = name_to_make_syn,
			new_status = "synonym",
			usage_name = name_convert
		)

	if(strict == TRUE) {
		res %>% dct_validate(...)
	}

	res
}

#' Convert names from synonym to accepted
#'
#' Also re-maps any synonyms from the former accepted names to the new accepted
#' names
#'
#' @param tax_dat Dataframe; taxonomic database in Darwin Core format
#' @param name_convert Character vector; scientific name(s) to convert from
#' synonym to accepted name
#' @param strict Logical; should taxonomic checks be run on the updated
#' taxonomic database with dct_validate()?
#' @param ... Additional arguments passed to dct_validate()
#'
#' @return Dataframe; taxonomic database in Darwin Core format.
#'
#' @examples
dct_convert_syn <- function(tax_dat, name_convert, strict, ...) {
	for(i in seq_along(name_convert)) {
		tax_dat <- convert_syn_single(tax_dat, name_convert[[i]], strict = strict)
	}
	tax_dat
}
