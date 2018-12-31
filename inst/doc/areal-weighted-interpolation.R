## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

library(areal)
library(dplyr)
library(sf)

data(ar_stl_asthma, package = "areal")
data(ar_stl_race, package = "areal")
data(ar_stl_wards, package = "areal")
data(ar_stl_wardsClipped, package = "areal")

## ----load-data-----------------------------------------------------------
library(areal)

# load data into enviornment
race <- ar_stl_race                 # census tract population estimates
asthma <- ar_stl_asthma             # census tract asthma rate estimates
wards <- ar_stl_wards               # political boundaries
wardsClipped <- ar_stl_wardsClipped # political boundaries clipped to river

## ----featureMap, echo=FALSE, out.width = '100%'--------------------------
knitr::include_graphics("../man/figures/featureMap.png")

## ----feature-count-------------------------------------------------------
# print number of features in source
nrow(race)

# print number of features in target
nrow(wards)

# create intersect for example purposes
nrow(suppressWarnings(sf::st_intersection(race, wards)))

## ----intersectMap, echo=FALSE, out.width = '100%'------------------------
knitr::include_graphics("../man/figures/intersectMap.png")

## ----data-by-hand, echo=FALSE--------------------------------------------
as_tibble(
  data.frame(
    GEOID = c(29510101100, 29510101100, 29510101200, 29510101200),
    TOTAL_E = c(2510, 2510, 3545, 3545),
    WARD = c(11, 12, 12, 13)
  )
) %>% 
  knitr::kable(caption = "First Four Rows of Intersected Data")

## ----weight-by-hand, echo=FALSE------------------------------------------
as_tibble(
  data.frame(
    GEOID = c(29510101100, 29510101100, 29510101200, 29510101200),
    TOTAL_E = c(2510, 2510, 3545, 3545),
    WARD = c(11, 12, 12, 13),
    Ai = c(355702.9, 901331.1, 875554.7, 208612.1),
    Aj = c(1257034.0, 1257034.0, 1084166.8, 1084166.8),
    Wi = c(0.28297, 0.71703, 0.807583, 0.192417)
  )
) %>% 
  knitr::kable(caption = "First Four Rows of Intersected Data")

## ----calculate-by-hand, echo=FALSE---------------------------------------
as_tibble(
  data.frame(
    GEOID = c(29510101100, 29510101100, 29510101200, 29510101200),
    TOTAL_E = c(2510, 2510, 3545, 3545),
    WARD = c(11, 12, 12, 13),
    Ai = c(355702.9, 901331.1, 875554.7, 208612.1),
    Aj = c(1257034.0, 1257034.0, 1084166.8, 1084166.8),
    Wi = c(0.28297, 0.71703, 0.807583, 0.192417),
    EST = c(710.2547, 1799.745, 2862.882, 682.1182)
  )
) %>% 
  knitr::kable(caption = "First Four Rows of Intersected Data")

## ----aggregate-by-hand, echo=FALSE---------------------------------------
as_tibble(
  data.frame(
    WARD = c(11, 12, 13),
    EST = c(710.2547, 4662.627, 682.1182)
  )
) %>% 
  knitr::kable(caption = "Resulting Target Data")

## ----extensive-----------------------------------------------------------
aw_interpolate(wards, tid = WARD, source = race, sid = GEOID, 
               weight = "sum", output = "tibble", extensive = "TOTAL_E")

## ----extensive-vector----------------------------------------------------
aw_interpolate(wards, tid = WARD, source = race, sid = GEOID, 
               weight = "sum", output = "tibble", 
               extensive = c("TOTAL_E", "WHITE_E", "BLACK_E"))

## ----extensive-weights---------------------------------------------------
aw_preview_weights(wards, tid = WARD, source = race, sid = GEOID, 
                   type = "extensive")

## ----verify-true---------------------------------------------------------
result <- aw_interpolate(wards, tid = WARD, source = race, sid = GEOID, 
               weight = "sum", output = "tibble", extensive = "TOTAL_E")

aw_verify(source = race, sourceValue = TOTAL_E, 
          result = result, resultValue = TOTAL_E)

## ----verify-fail---------------------------------------------------------
result <- aw_interpolate(wards, tid = WARD, source = race, sid = GEOID, 
               weight = "total", output = "tibble", extensive = "TOTAL_E")

aw_verify(source = race, sourceValue = TOTAL_E, 
          result = result, resultValue = TOTAL_E)

## ----overlapMap, echo=FALSE, out.width = '100%'--------------------------
knitr::include_graphics("../man/figures/overlapMap.png")

## ----extensive-weights-overlap-------------------------------------------
aw_preview_weights(wardsClipped, tid = WARD, source = race, sid = GEOID, 
                   type = "extensive")

## ----invenstive-weights--------------------------------------------------
aw_preview_weights(wards, tid = WARD, source = asthma, sid = GEOID, 
                   type = "intensive")

## ----intensive-----------------------------------------------------------
aw_interpolate(wards, tid = WARD, source = asthma, sid = GEOID, 
               weight = "sum", output = "tibble", intensive = "ASTHMA")

## ----mixed---------------------------------------------------------------
# remove sf geometry
st_geometry(race) <- NULL

# create combined data
race %>%
  select(GEOID, TOTAL_E, WHITE_E, BLACK_E) %>%
  left_join(asthma, ., by = "GEOID") -> combinedData

# interpolate
aw_interpolate(wards, tid = WARD, source = combinedData, sid = GEOID, 
               weight = "sum", output = "tibble", intensive = "ASTHMA",
               extensive = c("TOTAL_E", "WHITE_E", "BLACK_E"))

## ----ouput---------------------------------------------------------------
aw_interpolate(wards, tid = WARD, source = asthma, sid = GEOID, 
               weight = "sum", output = "sf", intensive = "ASTHMA")

## ----piped-input---------------------------------------------------------
wards %>%
  select(-OBJECTID, -AREA) %>%
  aw_interpolate(tid = WARD, source = asthma, sid = GEOID, 
                 weight = "sum", output = "tibble", intensive = "ASTHMA")

## ----quoted-input--------------------------------------------------------
wards %>%
  select(-OBJECTID, -AREA) %>%
  aw_interpolate(tid = "WARD", source = asthma, sid = "GEOID", 
                 weight = "sum", output = "tibble", intensive = "ASTHMA")

## ----manual-subset-------------------------------------------------------
race <- select(ar_stl_race, GEOID, TOTAL_E)
wards <- select(wards, -OBJECTID, -AREA)

## ----aw-intersect--------------------------------------------------------
wards %>%
  aw_intersect(source = race, areaVar = "area") -> intersect

intersect

## ----aw-total------------------------------------------------------------
intersect %>%
  aw_total(source = race, id = GEOID, areaVar = "area", totalVar = "totalArea",
             type = "extensive", weight = "sum") -> intersect

intersect

## ----aw-weight-----------------------------------------------------------
intersect %>%
  aw_weight(areaVar = "area", totalVar = "totalArea", 
            areaWeight = "areaWeight") -> intersect

intersect

## ----aw-calculate--------------------------------------------------------
intersect %>%
  aw_calculate(value = TOTAL_E, areaWeight = "areaWeight") -> intersect

intersect

## ----aw-aggregate--------------------------------------------------------
intersect %>%
  aw_aggregate(target = wards, tid = WARD, interVar = TOTAL_E) -> result

result

