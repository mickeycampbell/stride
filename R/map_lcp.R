#' Map least-cost paths
#'
#' @description
#' `map_lcp()` uses [gdistance::shortestPath()] and [gdistance::costDistance()]
#' to map the least-cost path between two or more point pairs and calculates the
#' total travel time in seconds for each path.
#'
#' @details
#' The coordinate reference system (CRS) of `pt_orig` and `pt_dest` must match
#' that of `tm` for this function to run successfully.
#'
#' @param tm transitionMatrix. The transition matrix from [bld_tm()].
#' @param pt_orig SpatVector. The origin point(s) of the least-cost path(s).
#' @param pt_dest SpatVector. The destination point(s) of the least-cost
#' path(s).
#' @param out_file character. Optionally, you can save the least-cost path
#' vector polyline to disk by supplying a file path with a .shp extension.
#' @param overwrite Boolean. If you opt to write the LCP to an output file, this
#' parameter specifies if you are willing to overwrite an existing file.
#'
#' @returns A polyline `SpatVector` representing the least-cost path(s) between
#' origin(s) and destination(s).
#'
#' @export

map_lcp <- function(tm, pt_orig, pt_dest, out_file = NULL, overwrite = F){
  crds_orig <- terra::crds(pt_orig)
  crds_dest <- terra::crds(pt_dest)
  lcp <- gdistance::shortestPath(tm, crds_orig, crds_dest, "SpatialLines") |>
    terra::vect()
  time <- gdistance::costDistance(tm, crds_orig, crds_dest)
  lcp$time <- time
  if (!is.null(out_file)){
    terra::writeVector(lcp, out_file, overwrite)
  }
  return(lcp)
}
