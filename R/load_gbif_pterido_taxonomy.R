# Download the GBIF backbone taxonomy and subset to pteridophytes
load_gbif_pterido_taxonomy <- function() {

  # Download most recent GBIF backbone taxonomy (2021-11-26) as of analysis
  # https://hosted-datasets.gbif.org/datasets/backbone/2021-11-26/backbone.zip
  gbif_zip_path <-
    contentid::resolve(
      "hash://sha256/1dfd8106e82d4cf270ac262cdf13d814002985523c44173c1e5026ce81065654", # nolint
      store = TRUE
    )

  # Unzip the taxon.tsv file to a temporary directory
  temp_dir <- tempdir()

  taxon_tsv_path <- utils::unzip(
    gbif_zip_path,
    files = c(file.path("backbone", "Taxon.tsv")),
    exdir = temp_dir
  )

  gbif_taxon_all <- readr::read_tsv(taxon_tsv_path)

  # Don't need unzipped file anymore
  fs::dir_delete(fs::path(temp_dir, "backbone"))

  # Filter to only pteridophytes
  gbif_taxon_all %>%
    filter(class %in% c("Lycopodiopsida", "Polypodiopsida"))
}
