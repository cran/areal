## ----setup, include = FALSE---------------------------------------------------
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

## -----------------------------------------------------------------------------
library(areal)
library(dplyr)   # data wrangling
library(sf)      # spatial data operations

# load data into enviornment
race <- ar_stl_race
asthma <- ar_stl_asthma
wards <- ar_stl_wards

# create example data - non-spatial data
asthmaTbl <- ar_stl_asthma
st_geometry(asthmaTbl) <- NULL

# create example data - wrong crs
race83 <- st_transform(race, crs = 4269)

## ----validate-simple----------------------------------------------------------
ar_validate(source = asthma, target = wards, varList = "ASTHMA", method = "aw")

## ----validate-verbose---------------------------------------------------------
ar_validate(source = asthma, target = wards, varList = "ASTHMA", method = "aw", verbose = TRUE)

## ----validate-non-sf----------------------------------------------------------
ar_validate(source = asthmaTbl, target = wards, varList = "ASTHMA", method = "aw", verbose = TRUE)

## ----race-crs-----------------------------------------------------------------
st_crs(race83)

## ----validate-non-matching-crs------------------------------------------------
ar_validate(source = race83, target = wards, varList = "TOTAL_E", method = "aw", verbose = TRUE)

## ----wards-crs----------------------------------------------------------------
st_crs(wards)

## ----transform-crs------------------------------------------------------------
raceFixed <- st_transform(race83, crs = 26915)

## ----validate-matching-crs----------------------------------------------------
ar_validate(source = raceFixed, target = wards, varList = "TOTAL_E", method = "aw", verbose = TRUE)

## -----------------------------------------------------------------------------
ar_validate(source = race, target = wards, varList = "TOTAL", method = "aw", verbose = TRUE)

## -----------------------------------------------------------------------------
names(race)

## -----------------------------------------------------------------------------
wardsVar <- mutate(wards, TOTAL_E = seq(1:28))

ar_validate(source = race, target = wardsVar, varList = "TOTAL_E", method = "aw", verbose = TRUE)

## -----------------------------------------------------------------------------
wardsFixed <- select(wardsVar, -TOTAL_E)

ar_validate(source = race, target = wardsFixed, varList = "TOTAL_E", method = "aw", verbose = TRUE)

## -----------------------------------------------------------------------------
names(wards)

## -----------------------------------------------------------------------------
wardsSubset <- select(wards, -OBJECTID, -AREA)

