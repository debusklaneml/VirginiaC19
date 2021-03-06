#' Pipe operator
#'
#' See \code{magrittr::\link[magrittr:pipe]{\%>\%}} for details.
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export 
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
NULL

read_data <- function() {
  suppressWarnings(
    readr::read_csv(
      "https://www.vdh.virginia.gov/content/uploads/sites/182/2020/05/VDH-COVID-19-PublicUseDataset-Cases.csv",
      col_types =
        readr::cols(
          `Report Date` = readr::col_character(),
          FIPS = readr::col_double(),
          Locality = readr::col_character(),
          `VDH Health District` = readr::col_character(),
          `Total Cases` = readr::col_double(),
          Hospitalizations = readr::col_double(),
          Deaths = readr::col_double()
        )
    )
  )
}


# need to change the date into a date variable.
clean_data <- function(tbl) {
  suppressWarnings(
    tbl %>%
      janitor::clean_names() %>%
      dplyr::select(
        date = report_date,
        location_code = fips,
        location = locality,
        vdh_health_district,
        cases_new = total_cases,
        deaths_new = deaths,
        hosp_new = hospitalizations
      ) %>%
      dplyr::mutate(
        location_type = "county",
        data_url = "https://www.vdh.virginia.gov/coronavirus/",
        data_set_name = "virginia_cases",
        package_name = "VirginiaC19",
        function_to_get_data = "refresh_VirginiaC19()",
        has_geospatial_info = FALSE,
        location_code_type = "fips_code"
      ) %>%
      dplyr::arrange(
        date
      ) %>%
      dplyr::mutate(date = lubridate::mdy(date)) %>%
      tidyr::pivot_longer(
        cols = cases_new:hosp_new,
        names_to = "data_type",
        values_to = "value"
      )
  )
}
