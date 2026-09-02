# -----------------------------------------------------------------------------
# Builds the analysis-ready datasets that Exercise 6 is meant to produce, one
# for each question a group can be allocated in Exercise 5.
#
# These are the fallback files: if a group is stuck at the end of Exercise 6,
# point them at data/please_help/ so they can still attempt Exercises 7 and 8.
#
# Re-run this if the raw files in data/ change.
#   Rscript make_tidy_data.R
# -----------------------------------------------------------------------------

suppressMessages(library(tidyverse))

OUT <- file.path("data", "please_help")
dir.create(OUT, showWarnings = FALSE, recursive = TRUE)

read_raw <- function(f) read_csv(file.path("data", f), show_col_types = FALSE)

# same pivot_longer(names_prefix = ...) approach the students are shown
to_long <- function(d, prefix, value_col) {
  d |>
    pivot_longer(
      cols         = starts_with(prefix),
      names_prefix = prefix,
      names_to     = "year",
      values_to    = value_col
    ) |>
    mutate(year = as.numeric(year))
}

gdp   <- to_long(read_raw("gdp.csv"),      "gdp_pcap_pp_", "gdp_pcap_pp")
urban <- to_long(read_raw("urban.csv"),    "urban_pct_",   "urban_pct")
life  <- to_long(read_raw("life_exp.csv"), "life_exp_",    "life_exp")
pop   <- to_long(read_raw("pop.csv"),      "pop_",         "population")
codes <- read_raw("country_to_continent.csv")

# Nine transcontinental countries appear twice in the lookup (once as Europe,
# once as Asia), so this join is one-to-many by design. Both rows are kept:
# a continent comparison should count Russia in both. Any group instead
# counting or averaging over all countries needs to handle the duplicates.
build <- function(other) {
  gdp |>
    left_join(other |> select(-name), by = join_by(geo, year)) |>
    left_join(pop   |> select(-name), by = join_by(geo, year)) |>
    left_join(codes |> select(-country_name),
              by = join_by(geo == iso3),
              relationship = "many-to-many")
}

# --- Question A: urbanisation vs GDP per capita ------------------------------
# urban.csv only covers 1960-2020, so coverage is 0% outside that window
# and 99.5% inside it. Restrict, then drop the remaining incomplete rows.
analysis_urban <- build(urban) |>
  filter(between(year, 1960, 2020)) |>
  drop_na()

# --- Question B: life expectancy vs GDP per capita ---------------------------
# life_exp.csv is complete for every year 1950-2025, so no window is needed.
analysis_life_exp <- build(life) |>
  drop_na()

write_csv(analysis_urban,    file.path(OUT, "analysis_urban_tidy.csv"))
write_csv(analysis_life_exp, file.path(OUT, "analysis_life_exp_tidy.csv"))

cat("analysis_urban_tidy.csv    ", nrow(analysis_urban),
    "rows |", n_distinct(analysis_urban$geo), "countries |",
    paste(range(analysis_urban$year), collapse = "-"), "\n")
cat("analysis_life_exp_tidy.csv ", nrow(analysis_life_exp),
    "rows |", n_distinct(analysis_life_exp$geo), "countries |",
    paste(range(analysis_life_exp$year), collapse = "-"), "\n")
