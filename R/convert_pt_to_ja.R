#' Convert pteridocat database to use with Japan ferns
#'
#' @param ja_ferns_dwc Japanese fern names in Darwin Core format
#' @param pteridocat Pteridocat fern names in Darwin Core format
#'
#' @return Fern names in Darwin Core format: pteridocat names but the accepted
#' name has been converted to the name used in ja_ferns_dwc
#'
convert_pt_to_ja <- function(ja_ferns_dwc, pteridocat) {

	# Filter JA ferns list to accepted names,
	# check that none are hybrid formulas
	ja_ferns_acc <-
		ja_ferns_dwc %>%
		filter(taxonomicStatus == "accepted") %>%
		# Double check that no hybrids are formulas
		separate(
			scientificName,
			c("hyb_part_1", "hyb_part_2"),
			fill = "left", extra = "drop",
			sep = " x | ｘ ", remove = FALSE) %>%
		assert(function(x) str_count(x, " ") == 0 | is.na(x), hyb_part_1) %>%
		select(-contains("hyb_part")) %>%
		assert(is_uniq, scientificName)

	# Match the JA ferns list to pteridocat
	ja_ferns_match_to_pt <-
		ts_resolve_names(
			ja_ferns_acc$scientificName,
			pteridocat,
			max_dist = 5,
			match_no_auth = TRUE,
			match_canon = TRUE,
			collapse_infra = TRUE
		)

	# Resolving results:
	# - matched `ja_ferns_match_to_pt_matched`
	#   - match accepted `ja_ferns_match_to_pt_matched_accepted_in_pt`
	#   - match synonym `ja_ferns_match_to_pt_matched_syn_in_pt`
	#      - convert these to accepted
	# - not matched `ja_ferns_match_to_pt_not_matched`

	# split into not matched and matched
	ja_ferns_match_to_pt_not_matched <-
		ja_ferns_match_to_pt %>%
		filter(match_type == "no_match")

	ja_ferns_match_to_pt_mult_match <-
		ja_ferns_match_to_pt %>%
		filter(match_type != "no_match") %>%
		add_count(query) %>%
		filter(n > 1)

	ja_ferns_match_to_pt_matched <-
		ja_ferns_match_to_pt %>%
		anti_join(ja_ferns_match_to_pt_not_matched, by = "query") %>%
		anti_join(ja_ferns_match_to_pt_mult_match, by = "query") %>%
		assert(is_uniq, query)

	# split matched into accepted and synonym
	ja_ferns_match_to_pt_matched_accepted_in_pt <-
		ja_ferns_match_to_pt_matched %>%
		filter(
			matched_status == "accepted" |
				matched_status == "provisionally accepted") %>%
		assert(is_uniq, query)

	ja_ferns_match_to_pt_matched_syn_in_pt <-
		ja_ferns_match_to_pt_matched %>%
		anti_join(
			ja_ferns_match_to_pt_matched_accepted_in_pt,
			by = "query") %>%
		assert(is_uniq, query)

	# convert matched synonyms to accepted
	converted_names <- dct_convert_syn(
		pteridocat,
		ja_ferns_match_to_pt_matched_syn_in_pt$matched_name, FALSE) %>%
		dct_validate(check_taxonomic_status = FALSE)

	# use JA names for accepted scientific names
	# drop cases where multiple sci names in pteridocat
	# map to the same JA name
	converted_names_acc_ja <-
		converted_names %>%
		filter(scientificName %in% ja_ferns_match_to_pt_matched$matched_name) %>%
		left_join(
			select(ja_ferns_match_to_pt_matched, query, matched_name),
			by = c(scientificName = "matched_name")
		) %>%
		add_count(scientificName) %>%
		filter(n == 1) %>%
		mutate(scientificName = query) %>%
		select(-query, -n) %>%
		dct_validate(check_taxonomic_status = FALSE)

	# combine converted names using JA name for accepted with other synonyms
	converted_names_other <-
		converted_names %>%
		anti_join(converted_names_acc_ja, by = "taxonID")

	bind_rows(
		converted_names_acc_ja,
		converted_names_other
	) %>%
		dct_validate(check_taxonomic_status = FALSE)
}
