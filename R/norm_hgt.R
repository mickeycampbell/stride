#' Normalize lidar point cloud heights relative to ground surface
#'
#' @description
#' `norm_hgt()` normalizes lidar point cloud heights relative to the ground
#' surface, effectively converting elevations (i.e., above mean sea level) to
#' heights (i.e., above the ground level). This is a necessary prerequisite step
#' to calculating vegetation density.
#'
#' @param las An object of class `LAS` (i.e., from [lidR::readLAS()]) or
#' `LAScatalog` (i.e., from [lidR::readLAScatalog()]). Airborne lidar point
#' cloud data in its raw format, where Z values represent elevations above mean
#' sea level or some reference ellipsoid.
#' @param algorithm function. A function that implements an algorithm to
#' interpolate a ground surface, the elevation of which will be subtracted from
#' each lidar point to compute height. `lidR` implements [lidR::knnidw()],
#' [lidR::tin()], and [lidR::kriging()] (see respective documentation and
#' examples).
#' @param ncores numeric. If you supply a `LAScatalog` with multiple tiles of
#' lidar data, you can leverage multiple CPUs to process your data in parallel,
#' using [future::plan()].
#' @param out_path character. Optionally, you can save the height-normalized
#' lidar tile(s) to file. If you supply a `LAScatalog`, the files will inherit
#' their names from the input tiles, so the outputs cannot be placed in the same
#' directory as the input files. If you supply a `LAS`, you must also provide an
#' `out_name`.
#' @param out_name character. If you supply a `LAS` and specify an `out_path`,
#' indicating your desire to save the output file to disk, this is the output
#' file name, with the extension .las or .laz, and will be stored in `out_path`.
#'
#' @returns `LAS` or `LAScatalog` point cloud data, where point Z values will
#' be replaced with aboveground heights.
#'
#' @export

norm_hgt <- function(las, algorithm = lidR::tin(), ncores = 1L, out_path = NULL,
                     out_name = NULL){
  if (ncores > 1){
    future::plan(future::multisession, workers = ncores)
  }
  if (class(las) == "LAScatalog"){
    if (!is.null(out_path)){
      lidR::opt_laz_compression(las) <- T
      lidR::opt_output_files(las) <- file.path(out_path, "{ORIGINALFILENAME}")
    }
    hgt <- lidR::normalize_height(las, algorithm)
  } else {
    hgt <- lidR::normalize_height(las, algorithm)
    if (!is.null(out_path) & !is.null(out_name)){
      writeLAS(hgt, file.path(out_path, out_name))
    }
  }
  if (ncores > 1){
    future::plan(future::sequential)
  }
  return(hgt)
}
