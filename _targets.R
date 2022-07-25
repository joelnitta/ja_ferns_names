## Load packages
source("packages.R")

## Load R files
lapply(list.files("./R", full.names = TRUE), source)

## Define workflow plan
tar_plan(
  # Load raw data ----
  # - GreenList: Japan fern names, including conservation status
  tar_file_read(
    green_list_raw,
    "_targets/user/FernGreenListV1.01.xls",
    read_excel(path = !!.x, col_types = "text")
  ),
  # - Japan fern occurrences downloaded from GBIF
  # https://doi.org/10.15468/dl.d75p7s
  tar_target(
    ja_ferns_gbif_raw,
    load_gbif_japan_occ()
  ),
  # - pteridocat taxonomic database
  pteridocat = pteridocat::pteridocat,
  # - GBIF backbone taxonomy for pteridophytes
  tar_target(
    gbif_pteridos,
    load_gbif_pterido_taxonomy()
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
  # - Japan fern names, accepted names (green list)
  green_list = clean_green_list(green_list_raw),
  # - remove hybrids (taxastand can't handle)
  green_list_no_hybrids = filter(
    green_list,
    str_detect(sci_name, " x | × ", negate = TRUE)
  ),

  # Spatial data
  # - filter GBIF data to only points occurring in Japan
  ja_ferns_gbif_filtered = filter_gbif(ja_ferns_gbif_raw, japan_mesh2),
  # - map GBIF names to accepted names in GBIF backbone taxonomy
  ja_ferns_gbif_accepted = map_raw_gbif_names_to_acc(
    ja_ferns_gbif = ja_ferns_gbif_filtered,
    gbif_pteridos = gbif_pteridos),
  # - make list of GBIF names for resolving
  ja_gbif_names = count(ja_ferns_gbif_accepted, scientificName),

  # Resolve names
  # - Resolve GreenList names to pteridocat,
  # filter to single matches
  green_names_resolved_pt = ts_resolve_names(
    green_list_no_hybrids$sci_name,
    pteridocat,
    max_dist = 5,
    match_no_auth = TRUE,
    match_canon = TRUE,
    collapse_infra = TRUE,
    docker = TRUE
  ),
  green_names_resolved_pt_single = get_single_matches(green_names_resolved_pt),
  # - Resolve GBIF names to pteridocat,
  # filter to single matches
  gbif_names_resolved_pt = ts_resolve_names(
    ja_gbif_names$scientificName,
    pteridocat,
    max_dist = 5,
    match_no_auth = TRUE,
    match_canon = TRUE,
    collapse_infra = TRUE,
    docker = TRUE
  ),
  gbif_names_resolved_pt_single = get_single_matches(gbif_names_resolved_pt),
  # - Merge GreenList and GBIF names by their resolved names in pteridocat
  gbif_names_resolved_mapped = map_resolved_pt_to_ja(
    green_names_resolved_pt_single,
    gbif_names_resolved_pt_single
  ),
  # Summarize spatial data
  mesh_species = summarize_ja_gbif_species(
    gbif_names_resolved_mapped, ja_ferns_gbif_accepted, green_list, japan_mesh2
  ),
  mesh_rich = summarize_ja_gbif_rich(mesh_species, japan_mesh2),
  # Render report
  tar_quarto(
    report,
    path = "index.qmd"
  )
)
