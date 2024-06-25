#' Generate ground surface roughness raster
#'
#' @description
#' `gen_rgh()` generates a raster dataset representing the roughness of the
#' ground surface, defined as the mean absolute deviation between a fine-scale
#' (1 m) digital terrain model (DTM) and a DTM that has been smoothed using a
#' circular mean focal filter with a 2 m radius.
#'
#' @details
#' To use this dataset in conjunction with a DTM and vegetation density raster
#' for the purposes of modeling least-cost paths, it is important to ensure that
#' the spatial resolution is consistent between all of these inputs.
#'
#' @param dtm SpatRaster. The fine-scale (e.g., 1 m) DTM.
#' @param radius numeric. The circular focal radius used for smoothing. Defaults
#' to 2 m, based on the work of Campbell et al. (in review).
#' @param res numeric. The target spatial resolution of the output roughness
#' raster dataset.
#' @param out_file character. Optionally, you can save the roughness raster to
#' disk by supplying a file path with a .tif extension.
#' @param overwrite Boolean. If you opt to write the DTM to an output file, this
#' parameter specifies if you are willing to overwrite an existing file.
#'
#' @returns `SpatRaster` where each pixel represents an approximation of the
#' roughness of the ground surface.
#'
#' @export

gen_rgh <- function(dtm, radius = 2, res = 10, out_file = NULL, overwrite = F){
  fm <- terra::focalMat(dtm, radius, "circle")
  dtm_smth <- terra::focal(dtm, fm, "mean")
  dtm_diff <- abs(dtm_smth - dtm)
  agg_fact <- round(res / terra::res(dtm))
  rgh <- terra::aggregate(dtm_diff, agg_fact, "mean")
  names(rgh) <- "roughness"
  if (!is.null(out_file)){
    terra::writeRaster(rgh, out_file, overwrite)
  }
}
