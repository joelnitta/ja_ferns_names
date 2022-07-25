# Filter taxonomic resolution results to just single matches
get_single_matches <- function(resolved_pt) {
  # split into not matched and matched
  resolved_pt_not_matched <-
    resolved_pt %>%
    filter(match_type == "no_match")

  resolved_pt_mult_match <-
    resolved_pt %>%
    filter(match_type != "no_match") %>%
    add_count(query) %>%
    filter(n > 1)

  # Japan fern names that were uniquely matched to pteridocat names
    resolved_pt %>%
    anti_join(resolved_pt_not_matched, by = "query") %>%
    anti_join(resolved_pt_mult_match, by = "query") %>%
    assert(is_uniq, query)
}
