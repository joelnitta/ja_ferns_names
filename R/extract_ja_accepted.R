extract_ja_accepted <- function(ja_ferns_dwc) {
	# Filter JA ferns list to accepted names,
	# check that none are hybrid formulas
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
		assert(is_uniq, scientificName) %>%
		pull(scientificName)
}
