#' Make a tibble of Japanese fern names in Darwin Core format
#'
#' @param ja_fern_names Tibble of Japanese fern names, including
#' synonyms
#' @param green_list Tibble of accepted Japanese fern names
#' @return Tibble in Darwin Core format, mapping synonyms
#' to accepted names
make_ja_dwc <- function(ja_fern_names, green_list) {

	# Ideally, scientific names between Green List and Fern Index should
	# match, but they don't. Can probably take care of this with more
	# cleaning, but trim to the matching set for now.

	# Trim green list to only names in ja_fern_names
	green_list <-
		green_list %>%
		inner_join(
			select(ja_fern_names, sci_name),
			by = "sci_name"
		)

	# Trim ja_fern_names to only those with IDs in green list
	ja_fern_names <-
		ja_fern_names %>%
		inner_join(
			select(green_list, gl_id),
			by = "gl_id"
		)

	ja_fern_names_with_status <-
		ja_fern_names %>%
		select(sci_name, gl_id) %>%
		# Missing some, but go with it for now
		left_join(
			select(green_list, accepted_sci_name = sci_name, gl_id),
			by = "gl_id") %>%
		mutate(taxonID = map_chr(sci_name, digest::digest))

	ja_fern_names_with_status %>%
		left_join(
			select(ja_fern_names_with_status, usageID = taxonID, sci_name),
			by = c(accepted_sci_name = "sci_name")
		) %>%
		mutate(
			is_accepted_by_sci_name = sci_name == accepted_sci_name,
			is_accepted_by_id = taxonID == usageID
		) %>%
		verify(all(is_accepted_by_sci_name == is_accepted_by_id)) %>%
		transmute(
			scientificName = sci_name,
			taxonomicStatus = if_else(is_accepted_by_id, "accepted", "synonym"),
			taxonID,
			acceptedNameUsageID = if_else(is_accepted_by_id, NA_character_, usageID)
		)
}
