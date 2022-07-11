#' Summarize GBIF richness patterns for Japanese ferns
#'
#' @param mesh_species Tibble with records of each species in each
#' 2nd degree mesh cell
#' @param japan_mesh2 2nd degree mesh of grid cells across Japan
#'
#' @return Tibble with richness and abundance stats for species in each
#' 2nd degree mesh cell
#'
summarize_ja_gbif_rich <- function(
	mesh_species, japan_mesh2
) {

	# Summarize richness and abundance
	mesh_rich <-
		mesh_species %>%
		mutate(
			is_endangered = str_detect(red_status, "CR|EN|VU|NT") %>%
				replace_na(FALSE)) %>%
		group_by(id) %>%
		summarize(
			rich = n_distinct(species),
			rich_endem = sum(is_endemic),
			rich_endan = sum(is_endangered),
			abun = sum(abun)
		)

	# Join back into spatial df
	japan_mesh2 %>%
		left_join(mesh_rich, by = "id")

}
