#' Intersect Source and Target Data
#'
#' @description \code{aw_intersect} intersects the source and target datasets and
#'     computes a new area field for the intersected data using the units associated
#'     with whatever project the data are currently in. This is the first step in the
#'     interpolation process after data validation and subsetting.
#'
#' @usage aw_intersect(.data, source, areaVar)
#'
#' @param .data A \code{sf} object that data should be interpolated to
#' @param source A \code{sf} object with data to be interpolated
#' @param areaVar The name of the new area variable to be calculated.
#'
#' @return A \code{sf} object with the intersected data and new area field.
#'
#' @examples
#' library(dplyr)
#'
#' race <- select(ar_stl_race, GEOID, TOTAL_E)
#' wards <- select(ar_stl_wards, WARD)
#'
#' aw_intersect(wards, source = race, areaVar = "area")
#'
#' @importFrom dplyr %>% mutate rename
#' @importFrom glue glue
#' @importFrom rlang :=
#' @importFrom rlang enquo
#' @importFrom rlang quo
#' @importFrom rlang quo_name
#' @importFrom rlang sym
#' @importFrom sf st_area st_collection_extract st_intersection
#' @importFrom dplyr rename
#' @importFrom dplyr mutate
#'
#' @export
aw_intersect <- function(.data, source, areaVar) {

  # save parameters to list
  paramList <- as.list(match.call())

  # check for missing parameters
  if (missing(.data)) {
    stop("A sf object containing target data must be specified for the '.data' argument.")
  }

  if (missing(source)) {
    stop("A sf object containing source data must be specified for the 'source' argument.")
  }

  if (missing(areaVar)) {
    stop("A variable name must be specified for the 'areaVar' argument.")
  }

  # nse
  if (!is.character(paramList$areaVar)) {
    areaVarQ <- rlang::enquo(areaVar)
  } else if (is.character(paramList$areaVar)) {
    areaVarQ <- rlang::quo(!! rlang::sym(areaVar))
  }

  areaVarQN <- rlang::quo_name(rlang::enquo(areaVarQ))

  # preform intersection
  intersection <- suppressWarnings(sf::st_intersection(source, .data))

  # if a geometry collection is returned, extract it
  if(any(grepl("GEOMETRY", sf::st_geometry_type(intersection)))) {
    intersection <- sf::st_collection_extract(intersection)
  }

  # calculate area
  intersection <- aw_area(intersection, areaVar = !!areaVarQ)

  # return output
  return(intersection)

}

# Calculate area
#
# @description Calculate the area of a feature in the units of the current
#     coordinate system. This is called by \code{aw_intersect}.
#
# @param .data A \code{sf} object that data should be interpolated to
# @param areaVar The name of the new area variable to be calculated.
#
# @return A \code{sf} object with the new area field.
#
aw_area <- function(.data, areaVar){

  # undefined global variables note
  geometry = NULL

  # save parameters to list
  paramList <- as.list(match.call())

  # nse
  areaVarQN <- rlang::quo_name(rlang::enquo(areaVar))

  # calculate area
  calculated_area <- unclass(sf::st_area(.data))

  # join
  out <- cbind(.data, calculated_area)

  # rename
  out <- dplyr::rename(out, !!areaVarQN := calculated_area)

  # return output
  return(out)

}
