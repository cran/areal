## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

library(areal)

data(ar_stl_asthma, package = "areal")
asthma <- ar_stl_asthma

data(ar_stl_race, package = "areal")
race <- ar_stl_race

data(ar_stl_wards, package = "areal")
wards <- ar_stl_wards

## ----exampleMap, echo=FALSE, out.width = '100%'--------------------------
knitr::include_graphics("../man/figures/exampleMap.png")

## ----iteration-----------------------------------------------------------
aw_interpolate(ar_stl_wards, tid = WARD, source = ar_stl_race, sid = "GEOID", 
               weight = "sum", output = "sf", extensive = "TOTAL_E")

