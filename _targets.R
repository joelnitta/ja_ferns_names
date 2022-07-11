## Load packages
source("packages.R")

## Load R files
lapply(list.files("./R", full.names = TRUE), source)

## Define workflow plan
tar_plan(
  # Load raw data ----
  # - Japan fern names including synonyms
  # from Index to Ferns and Lycophytes of Japan
  # http://jpfern.la.coocan.jp/names/
  tar_file_read(
    ja_fern_names_raw,
    "_targets/user/JpFernName220119.xlsx",
    read_excel(path = !!.x, col_types = "text")
  ),
  # - Japan fern names, accepted names only
  tar_file_read(
    green_list_raw,
    "_targets/user/FernGreenListV1.01.xls",
    read_excel(path = !!.x, col_types = "text")
  ),
  # - Japan fern occurrences downloaded from GBIF
  tar_file_read(
    ja_ferns_gbif_raw,
    "_targets/user/0172287-210914110416597.csv",
    read_tsv(!!.x)
  ),
  # - pteridocat taxonomic database
  tar_file_read(
    pteridocat,
    "_targets/user/pteridocat.RDS",
    readRDS(!!.x)
  ),
  # - GBIF backbone taxonomy for pteridophytes
  tar_file_read(
    gbif_pteridos,
    "_targets/user/gbif_pteridos.RDS",
    readRDS(!!.x)
  ),
  # Shape file downloaded from http://gis.biodic.go.jp/
  # http://gis.biodic.go.jp/BiodicWebGIS/Questionnaires?kind=mesh2&filename=mesh2.zip #nolint
  tar_file_read(
    japan_mesh2,
    "_targets/user/mesh2.zip",
    load_shape_from_zip(
      zip_file = !!.x,
      shp_file = "mesh2.shp",
      id = NAME
    )
  ),
  # Wrangle data ----

  # Scientific names
  # - Japan fern names, including synonyms
  ja_fern_names = clean_ja_fern_names(ja_fern_names_raw),
  # - Japan fern names, accepted names (green list)
  green_list = clean_green_list(green_list_raw),
  # - Japan fern names in Darwin Core format for resolving names
  ja_ferns_dwc = make_ja_dwc(ja_fern_names, green_list),

  # Spatial data
  # - filter GBIF data to only points occurring in Japan
  ja_ferns_gbif_filtered = filter_gbif(ja_ferns_gbif_raw, japan_mesh2),
  # - map GBIF names to accepted names in GBIF backbone taxonomy
  ja_ferns_gbif_accepted = map_raw_gbif_names_to_acc(
    ja_ferns_gbif_filtered, gbif_pteridos),
  # - make list of GBIF names for resolving
  ja_gbif_names = count(ja_ferns_gbif_accepted, scientificName),

  # Resolve names
  # - resolve Japan fern names to pteridocat
  ja_ferns_dwc_accepted = extract_ja_accepted(ja_ferns_dwc),
  ja_ferns_match_to_pt = ts_resolve_names(
    ja_ferns_dwc_accepted,
    pteridocat,
    max_dist = 5,
    match_no_auth = TRUE,
    match_canon = TRUE,
    collapse_infra = TRUE
  ),
  # - Resolve GBIF names to pteridocat
  gbif_names_resolved_pt = ts_resolve_names(
    ja_gbif_names$scientificName,
    pteridocat,
    max_dist = 5,
    match_no_auth = TRUE,
    match_canon = TRUE,
    collapse_infra = TRUE
  ),
  # - Map names resolved by pteridocat to Fern Index names
  gbif_names_resolved_mapped = map_resolved_pt_to_ja(
    gbif_names_resolved_pt,
    ja_ferns_match_to_pt
  ),
  # Summarize spatial data
  mesh_species = summarize_ja_gbif_species(
    gbif_names_resolved_mapped, ja_ferns_gbif_accepted, green_list, japan_mesh2
  ),
  mesh_rich = summarize_ja_gbif_rich(mesh_species, japan_mesh2)
)
