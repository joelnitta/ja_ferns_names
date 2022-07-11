#' Map GBIF data to accepted names in the GBIF backbone taxonomy
#'
#' Also filters occurrence data to those at the species level or below
#'
#' @param ja_ferns_gbif Tibble with columns "scientificName" (sci name in data
#' downloaded from GBIF, includes GBIF synonyms and accepted names), "longitude",
#' and "latitude"
#' @param gbif_pteridos GBIF backbone taxonomy for pteridophytes
#'
#' @return Tibble
map_raw_gbif_names_to_acc <- function(ja_ferns_gbif, gbif_pteridos) {

	gbif_species_level_tax <-
		gbif_pteridos %>%
		# Filter to species level and below
		filter(taxonRank %in% c("species", "subspecies", "variety", "form")) %>%
		select(taxonID, acceptedNameUsageID, scientificName, taxonRank, taxonomicStatus) %>%
		unique() %>%
		# taxonID is unique, but not scientificName
		assert(is_uniq, taxonID)

	# Filter GBIF occurrences to names at the species level
	ja_ferns_gbif_species <-
		ja_ferns_gbif %>%
		inner_join(
			unique(select(gbif_species_level_tax, scientificName)),
			by = "scientificName"
		)

	# Make tibble of accepted names
	accepted <- gbif_species_level_tax %>%
		filter(is.na(acceptedNameUsageID))

	# Resolve names that are synonyms to the accepted name
	ja_ferns_gbif_resolved_syns <-
		ja_ferns_gbif_species %>%
		anti_join(accepted, by = "scientificName") %>%
		left_join(
			select(
				gbif_species_level_tax,
				scientificName,
				acceptedNameUsageID),
			by = "scientificName") %>%
		assert(not_na, acceptedNameUsageID) %>%
		left_join(
			select(
				gbif_species_level_tax,
				acc_scientificName = scientificName,
				taxonID),
			by = c(acceptedNameUsageID = "taxonID")
		) %>%
		select(
			scientificName = acc_scientificName,
			longitude, latitude
		)

	# Filter GBIF occurrences to accepted names
	ja_ferns_gbif_accepted <-
		ja_ferns_gbif_species %>%
		inner_join(
			select(accepted, scientificName),
			by = "scientificName"
		)

  # Combine accepted names and resolved synonyms
	bind_rows(
			ja_ferns_gbif_resolved_syns,
			ja_ferns_gbif_accepted
		) %>%
		unique() %>%
		arrange(scientificName) %>%
		verify(all(scientificName %in% accepted$scientificName))

}
