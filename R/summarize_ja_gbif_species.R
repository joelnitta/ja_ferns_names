#' Map fern species to 2nd degree grid cells
#'
#' @param gbif_names_resolved_mapped Names of ferns in GBIF, mapping
#' from accepted GBIF name to name in pteridocat to name in JA fern index
#' @param ja_ferns_gbif_accepted GBIF data (one row per specimen) with
#' "scientificName" column containing accepted GBIF name
#' @param green_list Japan ferns "green list" with endangered and endemic status
#' @param japan_mesh2 2nd degree mesh of grid cells across Japan
#'
#' @return Tibble with richness and abundance stats for species in each
#' 2nd degree mesh cell
#'
summarize_ja_gbif_species <- function(
	gbif_names_resolved_mapped, ja_ferns_gbif_accepted, green_list, japan_mesh2
) {

	ja_ferns_gbif_accepted %>%
		rename(gbif_name = scientificName) %>%
		left_join(gbif_names_resolved_mapped, by = "gbif_name") %>%
		select(species = ja_name, longitude, latitude) %>%
		# Drop species that couldn't be resolved
		filter(!is.na(species)) %>%
		# Add meshID by spatial join
		sf::st_as_sf(
			coords = c("longitude", "latitude"),
			# Use same CRS as the mask
			crs = sf::st_crs(japan_mesh2)) %>%
		sf::st_join(japan_mesh2) %>%
		sf::st_drop_geometry() %>%
		# Count abundance of each species per cell
		group_by(id) %>%
		count(species, name = "abun") %>%
		ungroup() %>%
		# Add green list data
		left_join(
			select(green_list, species = sci_name, is_endemic, red_status),
			by = "species"
		) %>%
		verify(all(species %in% green_list$sci_name))

}
