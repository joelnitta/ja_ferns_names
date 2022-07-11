filter_gbif <- function(gbif_raw, mask) {

	# Convert gbif data to spatial dataframe
	occ_point_data <-
		gbif_raw %>%
		filter(!is.na(decimalLatitude), !is.na(decimalLongitude)) %>%
		select(
			gbifID, scientificName,
			latitude = decimalLatitude, longitude = decimalLongitude) %>%
		sf::st_as_sf(
			coords = c("longitude", "latitude"),
			# Use same CRS as the mask
			crs = sf::st_crs(mask))

	# Join point data to mesh map
	sf::st_join(occ_point_data, mask, join = sf::st_within) %>%
		# Filter to only those with a grid ID (so, those that are within the mesh map)
		filter(!is.na(id)) %>%
		# Convert to tibble with columns for taxon, longitude, and latitude
		as_tibble() %>%
		mutate(coords = sf::st_coordinates(geometry)) %>%
		select(scientificName, coords) %>%
		mutate(
			coords = as.data.frame(coords),
			longitude = coords$X,
			latitude = coords$Y) %>%
		select(-coords)

}



