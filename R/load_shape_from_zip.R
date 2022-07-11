#' Load a shape file from a zipped archive
#'
#' @param zip_file Path to zip file containing shape file (must end in ".zip")
#' @param shp_file Name of shape file
#' @param ... Arguments passed to `select()`: columns of data to select in the
#' spatial dataframe
#'
#' @return Spatial dataframe
#'
load_shape_from_zip <- function(zip_file, shp_file, ...) {
	# Unzip shape files to a temporary folder
	temp_dir <- fs::path(tempdir(), "shapes")
	zip_folder <- fs::path_file(zip_file) %>% fs::path_ext_remove()
	# Make sure it's empty
	if(dir.exists(temp_dir)) fs::dir_delete(temp_dir)
	fs::dir_create(temp_dir)
	# Unzip using `unar`, which won't mangle unicode filenames
	processx::run(
		command = "unar",
		args = fs::path_abs(zip_file),
		wd = temp_dir
	)
	# Load shape file
	shape <- sf::st_read(fs::path(temp_dir, zip_folder, shp_file)) %>%
		select(...)
	# Delete temporary data
	if(dir.exists(temp_dir)) fs::dir_delete(temp_dir)
	# Return shape
	shape
}
