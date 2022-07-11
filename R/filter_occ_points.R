#' Filter occurrence points using a polygon mask
#'
#' @param occ_point_data Occurrence points dataframe,
#' including columns for taxon, longitude, and latitude
#' @param mask Shape file read in from `mesh2.shp` zip file, used for cropping
#'
#' @return Filtered data points
filter_occ_points <- function(occ_point_data, mask) {

	# Remove duplicates (same species collected on same day at same site)
	occ_point_data <-
		occ_point_data %>%
		# only about 3,000 have date missing. conservatively consider these the same day.
		mutate(date = replace_na(date, "missing")) %>%
		assert(not_na, taxon, longitude, latitude, date) %>%
		group_by(taxon, longitude, latitude, date) %>%
		summarize(
			n = n(),
			.groups = "drop"
		)

	# Convert point data to SF object,
	# with same projection as shape file
	occ_point_data <- sf::st_as_sf(occ_point_data, coords = c("longitude", "latitude"), crs = st_crs(mask))

	# Join point data to mesh map
	sf::st_join(occ_point_data, mask, join = sf::st_within) %>%
		# Filter to only those with a grid ID (so, those that are within the mesh map)
		filter(!is.na(id)) %>%
		# Convert to tibble with columns for taxon, longitude, and latitude
		as_tibble() %>%
		mutate(coords = sf::st_coordinates(geometry)) %>%
		select(taxon, coords) %>%
		mutate(
			coords = as.data.frame(coords),
			longitude = coords$X,
			latitude = coords$Y) %>%
		select(-coords)

}
