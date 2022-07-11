#' Clean the list of Japanese fern accepted scientific names
#'
#' The "Fern Green List" should be downloaded from
#' http://www.rdplants.org/gl/
#'
#' @param green_list_raw Tibble; fern green list read in
#' from an excel file with readxl::read_excel()
#' @return Tibble; cleaned green list
#
clean_green_list <- function(green_list_raw) {

	green_list_raw %>%
		rename(
			gl_id = ID20160331,
			form_hybrid = `雑種・品種`,
			ja_name = `新リスト和名`,
			ja_name_old = `和名異名`,
			sci_name = `GreenList学名`,
			ppgi_family_num = `PPG科番号`,
			ppgi_family_ja = `PPG科和名`,
			ppgi_family = `PPG科名`,
			is_endemic = `固有`,
			red_status = RL2012
		) %>%
		mutate(
			is_endemic = case_when(
				is_endemic == "固有" ~ TRUE,
				TRUE ~ FALSE
			),
			is_hybrid = case_when(
				str_detect(form_hybrid, "h") ~ TRUE,
				TRUE ~ FALSE
			),
			is_form = case_when(
				str_detect(form_hybrid, "f") ~ TRUE,
				TRUE ~ FALSE
			)
		) %>%
		select(-form_hybrid) %>%
		assert(not_na, contains("is_"))

}
