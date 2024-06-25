#' Align cost rasters
#'
#' @description
#' `algn_rasts()` checks to see if all three of your input cost rasters (DTM,
#' vegetation density, and ground surface roughness) are spatially congruent
#' (crs, resolution, extent, origin). If not, you can optionally force them into
#' congruence.
#'
#' @details
#' If `force == T`, it is important that the input rasters are at least quite
#' similar in crs, resolution, extent, and origin, as a relatively simple
#' resampling technique will be employed to force them into congruence. If they
#' are very different, the resulting rasters could have spatial artifacts and
#' may not accurately represent the landscape characteristics to a suitable
#' degree of accuracy. Note that the input DTM will be used as the "reference"
#' raster dataset to which the others will be forced to match the spatial
#' characteristics of.
#'
#' @param dtm SpatRaster. The coarse-scale (e.g., 10 m) DTM. This may be
#' the product of [gen_dtm()].
#' @param dns SpatRaster. The vegetation density raster dataset. This may be
#' the product of [gen_dns()].
#' @param rgh SpatRaster. The ground surface roughness raster dataset. This may
#' be the product of [gen_rgh()].
#' @param force Boolean. If spatial incongruence exists between any of the three
#' input rasters, you can optionally choose to force them into congruence.
#' @param out_file_dtm character. Optionally, if `force == T`, you can save the
#' new, congruent DTM to disk by supplying a file path with a .tif extension.
#' @param out_file_dns character. Optionally, if `force == T`, you can save the
#' new, congruent vegetation density raster to disk by supplying a file path
#' with a .tif extension.
#' @param out_file_rgh character. Optionally, if `force == T`, you can save the
#' new, congruent ground surface roughness raster to disk by supplying a file
#' path with a .tif extension.
#' @param overwrite Boolean. If `force == T` and you opt to write any or all of
#' your new, congruent rasters to disk, this parameter specifies if you are
#' willing to overwrite existing files.
#'
#' @returns A list with three `SpatRaster` items:
#' * `dtm` is either the original or new, congruence-forced DTM.
#' * `dns` is either the original or new, congruence-forced vegetation density
#' raster.
#' * `rgh` is either the original or new, congruence-forced ground surface
#' roughness raster.
#'
#' @export

algn_rasts <- function(dtm, dns, rgh, force = F, out_file_dtm = NULL,
                       out_file_dns = NULL, out_file_rgh = NULL,
                       overwrite = F){
  dtm_crs <- terra::crs(dtm, describe = T)
  dtm_ext <- terra::ext(dtm)
  dtm_nrow <- terra::nrow(dtm)
  dtm_ncol <- terra::ncol(dtm)
  dtm_org <- terra::origin(dtm)
  message(
    "DTM\n",
    "  - CRS: ", dtm_crs$name, "\n",
    "  - Extent:\n",
    "    - XMin: ", dtm_ext[1][[1]], "\n",
    "    - XMax: ", dtm_ext[2][[1]], "\n",
    "    - YMin: ", dtm_ext[3][[1]], "\n",
    "    - YMax: ", dtm_ext[4][[1]], "\n",
    "  - NRow: ", dtm_nrow, "\n",
    "  - NCol: ", dtm_ncol, "\n",
    "  - Origin: ", dtm_org, "\n"
  )
  dns_crs <- terra::crs(dns, describe = T)
  dns_ext <- terra::ext(dns)
  dns_nrow <- terra::nrow(dns)
  dns_ncol <- terra::ncol(dns)
  dns_org <- terra::origin(dns)
  message(
    "Density\n",
    "  - CRS: ", dns_crs$name, "\n",
    "  - Extent:\n",
    "    - XMin: ", dns_ext[1][[1]], "\n",
    "    - XMax: ", dns_ext[2][[1]], "\n",
    "    - YMin: ", dns_ext[3][[1]], "\n",
    "    - YMax: ", dns_ext[4][[1]], "\n",
    "  - NRow: ", dns_nrow, "\n",
    "  - NCol: ", dns_ncol, "\n",
    "  - Origin: ", dns_org, "\n"
  )
  rgh_crs <- terra::crs(rgh, describe = T)
  rgh_ext <- terra::ext(rgh)
  rgh_nrow <- terra::nrow(rgh)
  rgh_ncol <- terra::ncol(rgh)
  rgh_org <- terra::origin(rgh)
  message(
    "Roughness\n",
    "  - CRS: ", rgh_crs$name, "\n",
    "  - Extent:\n",
    "    - XMin: ", rgh_ext[1][[1]], "\n",
    "    - XMax: ", rgh_ext[2][[1]], "\n",
    "    - YMin: ", rgh_ext[3][[1]], "\n",
    "    - YMax: ", rgh_ext[4][[1]], "\n",
    "  - NRow: ", rgh_nrow, "\n",
    "  - NCol: ", rgh_ncol, "\n",
    "  - Origin: ", rgh_org, "\n"
  )
  unmatches <- 0
  if ((dtm_crs$name == dns_crs$name) & (dns_crs$name == rgh_crs$name)){
    message("CRS: MATCH")
  } else {
    message("CRS: DO NOT MATCH")
    unmatches <- unmatches + 1
  }
  if ((dtm_ext == dns_ext) & (dns_ext == rgh_ext)){
    message("Extent: MATCH")
  } else {
    message("Extent: DO NOT MATCH")
    unmatches <- unmatches + 1
  }
  if ((dtm_nrow == dns_nrow) & (dns_nrow == rgh_nrow)){
    message("NRow: MATCH")
  } else {
    message("NRow: DO NOT MATCH")
    unmatches <- unmatches + 1
  }
  if ((dtm_ncol == dns_ncol) & (dns_ncol == rgh_ncol)){
    message("NCol: MATCH")
  } else {
    message("NCol: DO NOT MATCH")
    unmatches <- unmatches + 1
  }
  if (all(dtm_org == dns_org) & all(dns_org == rgh_org)){
    message("Origin: MATCH")
  } else {
    message("Origin: DO NOT MATCH")
    unmatches <- unmatches + 1
  }
  if (unmatches > 0){
    message("Spatial incongruence exists. Force congruence or resolve otherwise
            before proceeding.")
    if (force == T){
      dns_frc <- terra::project(dns, dtm)
      rgh_frc <- terra::project(rgh, dtm)
      xmin_frc <- max(
        terra::ext(dtm)[1][[1]],
        terra::ext(dns_frc)[1][[1]],
        terra::ext(rgh_frc)[1][[1]]
      )
      xmax_frc <- min(
        terra::ext(dtm)[2][[1]],
        terra::ext(dns_frc)[2][[1]],
        terra::ext(rgh_frc)[2][[1]]
      )
      ymin_frc <- max(
        terra::ext(dtm)[3][[1]],
        terra::ext(dns_frc)[3][[1]],
        terra::ext(rgh_frc)[3][[1]]
      )
      ymax_frc <- min(
        terra::ext(dtm)[4][[1]],
        terra::ext(dns_frc)[4][[1]],
        terra::ext(rgh_frc)[4][[1]]
      )
      ext_frc <- terra::ext(xmin_frc, xmax_frc, ymin_frc, ymax_frc)
      dtm_frc <- terra::crop(dtm, ext_frc)
      dns_frc <- terra::crop(dns_frc, ext_frc)
      rgh_frc <- terra::crop(rgh_frc, ext_frc)
      if (!is.null(out_file_dtm)){
        terra::writeRaster(dtm_frc, out_file_dtm, overwrite)
      }
      if (!is.null(out_file_dns)){
        terra::writeRaster(dns_frc, out_file_dns, overwrite)
      }
      if (!is.null(out_file_rgh)){
        terra::writeRaster(rgh_frc, out_file_rgh, overwrite)
      }
      return(list(dtm = dtm_frc, dns = dns_frc, rgh = rgh_frc))
    }
  } else {
    return(list(dtm = dtm, dns = dns, rgh = rgh))
  }
}
