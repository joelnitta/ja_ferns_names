# Download the occurrences of pteridophytes in Japan on GBIF
load_gbif_japan_occ <- function() {

  # Download Japan fern occurrences from GBIF
  # https://doi.org/10.15468/dl.d75p7s
  gbif_zip_path <-
    contentid::resolve(
      "hash://sha256/5cb1c53047c9b6a8350d3f364915071c5c51ea5a37d10830b41e8d7ee3048e6e", # nolint
      store = TRUE
    )

  # Unzip the csv file to a temporary directory
  temp_dir <- tempdir()

  tsv_path <- utils::unzip(
    gbif_zip_path,
    files = "0172287-210914110416597.csv",
    exdir = temp_dir
  )

  # Load occurrences
  occ <- readr::read_tsv(tsv_path)

  # Delete unzipped data
  fs::file_delete(fs::path(temp_dir, "0172287-210914110416597.csv"))

  occ
}
