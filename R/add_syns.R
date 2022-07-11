add_syns <- function(ja_ferns_dwc, pteridocat) {

	additional_syns_from_accepted <-
		ja_ferns_dwc %>%
		# Start with Japanese fern names
		filter(taxonomicStatus == "accepted") %>%
		select(ja_taxonID = taxonID, scientificName) %>%
		# filter to names in pteridocat
		inner_join(
			select(pteridocat, scientificName,
						 pt_taxonomicStatus = taxonomicStatus,
						 pt_taxonID = taxonID),
			by = "scientificName") %>%
		# filter to accepted names in pteridocat
		filter(pt_taxonomicStatus == "accepted") %>%
		# join pteridocat synonyms
		inner_join(
			select(
				pteridocat, pt_syn_taxonID = taxonID,
				pt_acceptedNameUsageID = acceptedNameUsageID,
				pt_syn_scientificName = scientificName),
			by = c(pt_taxonID = "pt_acceptedNameUsageID")
		) %>%
		# Remove any synonyms that are already in JA data
		anti_join(
			select(ja_ferns_dwc, scientificName),
			by = c(pt_syn_scientificName = "scientificName")
		) %>%
		select(
			taxonID = pt_syn_taxonID,
			scientificName = pt_syn_scientificName,
			acceptedNameUsageID = ja_taxonID
		) %>%
		anti_join(ja_ferns_dwc, by = "scientificName") %>%
		assert(is_uniq, taxonID, scientificName) %>%
		assert(not_na, everything())


	additional_syns_from_synonyms <-
		ja_ferns_dwc %>%
		# Start with Japanese fern synonyms
		filter(taxonomicStatus == "synonym") %>%
		select(ja_syn_taxonID = taxonID, scientificName) %>%
		verify(!all(
			scientificName %in% additional_syns_from_accepted$scientificName)) %>%
		# filter to names in pteridocat
		inner_join(
			select(
				pteridocat, scientificName, pt_taxonomicStatus = taxonomicStatus,
				pt_taxonID = taxonID),
			by = "scientificName") %>%
		# filter to accepted names in pteridocat
		filter(pt_taxonomicStatus == "accepted") %>%
		select(-pt_taxonomicStatus) %>%
		# join pteridocat synonyms
		inner_join(
			select(
				pteridocat, pt_syn_taxonID = taxonID,
				pt_acceptedNameUsageID = acceptedNameUsageID,
				pt_syn_scientificName = scientificName),
			by = c(pt_taxonID = "pt_acceptedNameUsageID")
		) %>%
		# Add accepted taxonID in ja data
		left_join(
			select(
				ja_ferns_dwc, taxonID, acceptedNameUsageID),
			by = c(ja_syn_taxonID = "taxonID")
		) %>%
		select(
			taxonID = pt_syn_taxonID,
			scientificName = pt_syn_scientificName,
			acceptedNameUsageID) %>%
		anti_join(ja_ferns_dwc, by = "scientificName") %>%
		assert(is_uniq, taxonID, scientificName) %>%
		assert(not_na, everything())

	ja_ferns_dwc %>%
		bind_rows(additional_syns_from_accepted) %>%
		bind_rows(additional_syns_from_synonyms) %>%
		unique() %>%
		assert(is_uniq, taxonID, scientificName) %>%
		filter(!scientificName %in% c(
			"Polypodium annuifrons Makino",
			"Polypodium japonense Makino"
		)) %>%
		dwctaxon::dct_validate(
			check_taxonomic_status = FALSE
		)

}
