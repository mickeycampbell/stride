#' Generate vegetation density raster
#'
#' @description
#' `gen_dns()` calculates an approximation of vegetation density, based on
#' lidar point density, within a particular height range of interest.
#'
#' @details
#' To use this dataset in conjunction with a DTM and ground surface roughness
#' raster for the purposes of modeling least-cost paths, it is important to
#' ensure that the spatial resolution is consistent between all of these inputs.
#'
#' @param las_hgt An object of class `LAS` (i.e., from [lidR::readLAS()]) or
#' `LAScatalog` (i.e., from [lidR::readLAScatalog()]). Airborne lidar point
#' cloud data that have been normalized to the ground surface, where Z values
#' represent heights above the ground.
#' @param hgt_1 numeric. The bottom value of the vegetation density height
#' range. Defaults to 0.85 m, based on the work of Campbell et al. (in review).
#' @param hgt_2 numeric. The top value of the vegetation density height range.
#' Defaults to 1.20 m, based on the work of Campbell et al. (in review).
#' @param res numeric. The size of a grid cell in point cloud coordinate units.
#' @param ncores numeric. If you supply a `LAScatalog` with multiple tiles of
#' lidar data, you can leverage multiple CPUs to process your data in parallel,
#' using [future::plan()].
#' @param out_file character. Optionally, you can save the vegetation density
#' raster to disk by supplying a file path with a .tif extension.
#' @param overwrite Boolean. If you opt to write the DTM to an output file, this
#' parameter specifies if you are willing to overwrite an existing file.

#' @returns `SpatRaster` where each pixel represents an approximation of the
#' vegetation density between `hgt_1` and `hgt_2`.
#' @export

gen_dns <- function(las_hgt, hgt_1 = 0.85, hgt_2 = 1.20, res = 10, ncores = 1L,
                     out_file = NULL, overwrite = F){
  options(lidR.raster.default = "terra")
  if (class(las_hgt) == "LAScatalog"){
    lidR::opt_output_files(las_hgt) <- ""
  }
  if (ncores > 1){
    future::plan(future::multisession, workers = ncores)
  }
  hgt_1 <<- hgt_1
  hgt_2 <<- hgt_2
  dns <- lidR::pixel_metrics(
    las = las_hgt,
    func = ~stride::dns_fun(z = Z, hgt_1 = hgt_1, hgt_2 = hgt_2),
    res = 10
  )
  names(dns) <- "density"
  if (!is.null(out_file)){
    terra::writeRaster(dns, out_file, overwrite = overwrite)
  }
  if (ncores > 1){
    future::plan(future::sequential)
  }
  return(dns)
}
