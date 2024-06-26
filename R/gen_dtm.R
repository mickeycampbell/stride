#' Generate terrain model from lidar data
#'
#' @description
#' `gen_dtm()` generates a digital terrain model (DTM) from lidar point cloud
#' data. It is mostly a wrapper function around `lidR::rasterize_terrain()`.
#'
#' @details
#' In the context of the `stride` package workflow, you will likely employ the
#' use of `gen_dtm()` twice. The first is to generate a high-resolution (e.g., 1
#' m) terrain model that will be used for both normalizing lidar point heights
#' and generating the ground surface roughness model. The second is to generate
#' a lower-resolution (e.g., 10 m) terrain model that will be used as the basis
#' of calculating terrain slope for generating least-cost paths and estimating
#' travel times.
#'
#' For this function to execute successfully, the input lidar point cloud
#' (`las`) will need to have ground points classified. Most airborne lidar data
#' that come from authoritative sources (e.g., the USGS) will have ground points
#' already classified, so you need not worry about performing this
#' classification yourself. However, should you need to do so, you can use
#' `lidR::classify_ground()`.
#'
#' @param las An object of class `LAS` (i.e., from [lidR::readLAS()]) or
#' `LAScatalog` (i.e., from [lidR::readLAScatalog()]). Airborne lidar point
#' cloud data in its raw format, where Z values represent elevations above mean
#' sea level or some reference ellipsoid.
#' @param res numeric. The size of a grid cell in point cloud coordinate units.
#' @param algorithm function. A function that implements an algorithm to compute
#' a digital terrain model. `lidR` implements [lidR::knnidw()], [lidR::tin()],
#' and [lidR::kriging()] (see respective documentation and examples).
#' @param ncores numeric. If you supply a `LAScatalog` with multiple tiles of
#' lidar data, you can leverage multiple CPUs to process your data in parallel,
#' using [future::plan()].
#' @param out_file chara cter. Optionally, you can save the DTM to disk by
#' supplying a file path with a .tif extension.
#' @param overwrite Boolean. If you opt to write the DTM to an output file, this
#' parameter specifies if you are willing to overwrite an existing file.
#'
#' @returns `SpatRaster` where each pixel represents elevation in point cloud
#' coordinate units.
#'
#' @export

gen_dtm <- function(las, res = 1, algorithm = lidR::tin(), ncores = 1L,
                    out_file = NULL, overwrite = F){
  options(lidR.raster.default = "terra")
  if (ncores > 1){
    future::plan(future::multisession, workers = ncores)
  }
  dtm <- lidR::rasterize_terrain(
    las = las,
    res = res,
    algorithm = algorithm
  )
  names(dtm) <- "elevation"
  if (ncores > 1){
    future::plan(future::sequential)
  }
  if (!is.null(out_file)){
    terra::writeRaster(dtm, out_file, overwrite)
  }
  return(dtm)
}
