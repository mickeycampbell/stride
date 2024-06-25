#' Build transition matrix
#'
#' @description
#' `bld_tm()` builds a [gdistance::transitionMatrix()] using the three input
#' cost rasters: (1) DTM (from which directional slope will be calculated); (2)
#' vegetation density; and (3) ground surface roughness; and the two input barrier
#' rasters: (1) cliffs (slopes >= 45 deg.); and (2) waterbodies.
#'
#' @details
#' It is imperative to check for (and optionally enforce) spatial congruence
#' between the three input cost rasters using [algn_rasts()] prior to running
#' this function. Provided that [get_bars()] is run after [algn_rasts()], the
#' two barrier rasters will automatically be aligned and ready for use here.
#'
#' Note that building transition matrices is a computationally intensive
#' process, requiring many pairwise calculations between neighboring cells in a
#' potentially large study area, and the storage of those calculations in
#' memory. You may consider testing the algorithm on a small study area prior to
#' employment on a broad spatial scale.
#'
#' @param dtm SpatRaster. The coarse-scale (e.g., 10 m) DTM. This may be
#' the product of [gen_dtm()].
#' @param dns SpatRaster. The vegetation density raster dataset. This may be
#' the product of [gen_dns()].
#' @param rgh SpatRaster. The ground surface roughness raster dataset. This may
#' be the product of [gen_rgh()].
#' @param clf SpatRaster. The cliff barrier raster dataset. This may be the
#' product of [get_bars()].
#' @param wtr SpatRaster. The water barrier raster dataset. This may be the
#' product of [get_bars()].
#'
#' @returns A `transitionMatrix`, with values representing the conductance
#' (inverse of cost) between adjacent cells in your study area.
#'
#' @export

bld_tm <- function(dtm, dns, rgh, clf, wtr){
  dtm <- raster::raster(dtm)
  dns <- raster::raster(dns)
  rgh <- raster::raster(rgh)
  clf <- raster::raster(clf)
  wtr <- raster::raster(wtr)
  a <- -2.320
  b <- 26.315
  c <- 147.362
  d <- 15.265
  e <- 16.505
  tm_clf <- gdistance::transition(clf, min, 16, symm = T)
  tm_wtr <- gdistance::transition(wtr, min, 16, symm = T)
  tm_dns <- gdistance::transition(dns, mean, 16, symm = T)
  tm_rgh <- gdistance::transition(rgh, mean, 16, symm = T)
  tm_slp <- gdistance::transition(dtm, function(x) {x[2] - x[1]}, 16, symm = F)
  tm_slp <- gdistance::geoCorrection(tm_slp)
  tm_slp <- atan(tm_slp) * 180/pi
  adj <- raster::adjacent(tm_slp, cells = 1:raster::ncell(dtm), pairs = T,
                          directions = 16)
  tm_slp[adj] <- (c*(1/(pi*b*(1+((tm_slp[adj]-a)/b)^2)))) /
    (d * tm_dns[adj] + e * tm_rgh[adj] + 1)
  tm <- tm_slp * tm_clf * tm_wtr
  tm <- gdistance::geoCorrection(tm)
  return(tm)
}
