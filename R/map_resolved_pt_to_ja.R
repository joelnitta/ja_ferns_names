
map_resolved_pt_to_ja <- function(gbif_names_resolved_pt, ja_ferns_match_to_pt) {
	# split into not matched and matched
	ja_ferns_match_to_pt_not_matched <-
		ja_ferns_match_to_pt %>%
		filter(match_type == "no_match")

	ja_ferns_match_to_pt_mult_match <-
		ja_ferns_match_to_pt %>%
		filter(match_type != "no_match") %>%
		add_count(query) %>%
		filter(n > 1)

	# Japan fern names that were uniquely matched to pteridocat names
	ja_ferns_match_to_pt_matched <-
		ja_ferns_match_to_pt %>%
		anti_join(ja_ferns_match_to_pt_not_matched, by = "query") %>%
		anti_join(ja_ferns_match_to_pt_mult_match, by = "query") %>%
		assert(is_uniq, query)

	# Map GBIF names resolved to pteridocat to JA names
	gbif_names_resolved_pt %>%
		select(gbif_name = query, pt_name = resolved_name) %>%
		filter(!is.na(pt_name)) %>%
		left_join(
			select(
				ja_ferns_match_to_pt_matched,
				ja_name = query, pt_name = resolved_name),
			by = "pt_name"
		) %>%
		filter(!is.na(ja_name))
}
