# Join GreenList and GBIF names by their resolved names in pteridocat
map_resolved_pt_to_ja <- function(
  green_names_resolved_pt_single, gbif_names_resolved_pt_single) {
  green_names_resolved_pt_single %>%
  select(ja_name = query, pt_name = resolved_name) %>%
  inner_join(
    select(gbif_names_resolved_pt_single,
      gbif_name = query,
      pt_name = resolved_name
    ),
    by = "pt_name"
  )
}
