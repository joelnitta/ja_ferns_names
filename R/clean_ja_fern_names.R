#' Clean the list of Japanese fern scientific names,
#' including accepted names and synonyms.
#'
#' The original data are from the Index to Ferns and Lycophytes
#' of Japan website http://jpfern.la.coocan.jp/names/index.html
#'
#' @param ja_fern_names_raw Tibble; taxonomic data read in
#' from an excel file with readxl::read_excel()
#' @return Tibble; cleaned data
#
clean_ja_fern_names <- function(ja_fern_names_raw) {

	ja_fern_names_raw %>%
		rename(
			ja_name = `和名_G_List_`,
			sci_name = Name,
			is_basionym = basionym_status,
			ja_name_var = `品種等和名`,
			gl_id = `FernGreenListV1.01::ID20160331`
		) %>%
		mutate(is_basionym = if_else(is_basionym == "1", TRUE, FALSE))

}
