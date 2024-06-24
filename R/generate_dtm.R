#' Generate terrain model from lidar data
#'
#' @description
#' `generate_dtm()` generates a digital terrain model (DTM) from lidar point
#' cloud data. It is mostly a wrapper function around
#' `lidR::rasterize_terrain()`.
#'
#' @details
#' In the context of the `stride` package workflow, you will likely employ the
#' use of `generate_dtm()` twice. The first is to generate a high-resolution
#' (e.g., 1 m) terrain model that will be used for both normalizing lidar point
#' heights and generating the ground surface roughness model. The second is to
#' generate a lower-resolution (e.g., 10 m) terrain model that will be used as
#' the basis of calculating terrain slope for generating least-cost paths and
#' estimating travel times.
#'
#' For this function to execute successfully, the input lidar point cloud
#' (`las`) will need to have ground points classified. Most airborne lidar data
#' that come from authoritative sources (e.g., the USGS) will have ground points
#' already classified, so you need not worry about performing this
#' classification yourself. However, should you need to do so, you can use
#' `lidR::classify_ground()`.
#'
#' @param las An object of class [lidR::LAS()] or [lidR::LAScatalog].
#' @param res numeric. The size of a grid cell in point cloud coordinate units.
#' @param algorithm function. A function that implements an algorithm to compute
#' a digital terrain model. `lidR` implements [lidR::knnidw()], [lidR::tin()],
#' and [lidR::kriging()] (see respective documentation and examples).
#'
#' @returns `SpatRaster` where each pixel represents elevation in point cloud
#' coordinate units.
#' @export

generate_dtm <- function(las, res = 1, algorithm = lidR::tin()){
  dtm <- lidR::rasterize_terrain(
    las = las,
    res = res,
    algorithm = algorithm
  ) |>
    terra::rast()
  return(dtm)
}
