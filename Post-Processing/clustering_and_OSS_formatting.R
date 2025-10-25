OSS_format <- function(data) {
  data |>
    filter((!is.na(prob_species) & prob_species > 0.8) | is.na(prob_species)) |>
    select(start_sec, end_sec, filename, predicted_category) |>
    mutate(
      start_time = filename |>
        str_extract("^\\d{8}_\\d{6}_\\d{6}") |>
        str_replace_all("_", "") |>
        str_replace("(\\d{8})(\\d{6})(\\d+)", "\\1 \\2.\\3") |>
        str_replace("(\\d{4})(\\d{2})(\\d{2}) (\\d{2})(\\d{2})(\\d+\\.\\d+)",
                    "\\1-\\2-\\3 \\4:\\5:\\6"),
      start_timestamp = as.POSIXct(
        start_time,
        format = "%Y-%m-%d %H:%M:%OS",
        tz = "UTC"
      ) + start_sec
    ) |>
    pivot_wider(
      id_cols = c(filename, start_sec, end_sec, start_time, start_timestamp),
      names_from = predicted_category,
      values_from = predicted_category,
      values_fn = length,
      values_fill = 0
    ) |>
    mutate(across(where(is.numeric) & !c(start_sec, end_sec), ~ ifelse(is.na(.x), 0, .x))) |>
    relocate(filename, .before = 1)
}

## Code below needs to be made modular so it can run for each day folder

combOctnint <- read.csv("C:/Users/mmaro/Downloads/20251019_combined.csv")

OctNintForm <- combOctnint |>
  filter(!grepl("[A-Za-z]", start_sec), !grepl("[A-Za-z]", end_sec)) |>
  mutate(start_sec = as.numeric(start_sec)) |>
  mutate(end_sec = as.numeric(end_sec)) |>
  filter(grepl("*T\\.flac$|*TH\\.flac$", filename))

OctNintForm <- OctNintForm |>
  mutate(base_filename = str_remove(filename, "_(NORTH|EAST|SOUTH|WEST)\\.flac$")) |>
  arrange(base_filename, start_sec) |>
  group_by(base_filename) |>
  mutate(cluster_id = cumsum(c(TRUE, diff(start_sec) > 0.1))) |>
  ungroup() |>
  group_by(base_filename, cluster_id) |>
  mutate(start_sec = min(start_sec, na.rm = TRUE)) |>
  ungroup() |>
  group_by(base_filename, cluster_id) |>
  mutate(
    predicted_category = case_when(
      any(species != "") ~ species[species != ""][1],
      any(group != "")   ~ group[group != ""][1],
      any(family != "")  ~ family[family != ""][1],
      TRUE               ~ order[order != ""][1]
    )
  ) |>
  ungroup() |>
  OSS_format() |>
  mutate(direction = str_to_title(str_extract(filename, "(NORTH|SOUTH|EAST|WEST)"))) |>
  relocate(direction, .before = 1)

write.csv(OctNintForm, "NinteenthComb.csv", row.names = FALSE)
