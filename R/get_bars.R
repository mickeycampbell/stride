#' Get barriers
#'
#' @description
#' `get_bars()` allows you to create two raster datasets that represent barriers
#' on the landscape that would represent impassible pedestrian obstacles. The
#' two barriers used in STRIDE are cliffs (slope >= 45 deg.) and area
#' waterbodies (e.g., ponds, lakes). The cliffs are derived from the coarse-
#' scale (e.g., 10 m) DTM produced by [gen_dtm()], and the waterbodies can
#' either be supplied as polygon vector file or downloaded using the `nhdR`
#' package. Note that National Hydrography Dataset (NHD) data are only available
#' in the US.
#'
#' @details
#' This function should be run after [algn_rasts()] in the STRIDE modeling
#' workflow. This is because the cliff and water barrier rasters that are
#' produced by this function will be spatially aligned (crs, resolution, extent,
#' and origin) to the input DTM. If the DTM already aligns with the vegetation
#' density and ground surface roughness rasters (i.e., [algn_rasts()] ran
#' successfully), then the new barrier rasters will likewise align, which is
#' imperative for successful STRIDE modeling.
#'
#' @param dtm SpatRaster. The coarse-scale (e.g., 10 m) DTM. This may be
#' the product of [gen_dtm()].
#' @param in_wtr SpatVector. A vector polygon dataset representing area
#' waterbodies that will act as barriers to movement. If not supplied, in the
#' US, NHD data will be downloaded and used instead.
#' @param out_file_clf character. Optionally, if `force == T`, you can save the
#' cliff barrier raster to disk by supplying a file path with a .tif extension.
#' @param out_file_wtr character. Optionally, if `force == T`, you can save the
#' water barrier raster to disk by supplying a file path with a .tif extension.
#' @param overwrite Boolean. If you opt to write either or both of your barrier
#' rasters to disk, this parameter specifies if you are willing to overwrite
#' existing files.
#'
#' @returns A list with two `SpatRaster` items:
#' * `clf` is the cliff barrier raster.
#' * `wtr` is the water barrier raster.
#'
#' @export

get_bars <- function(dtm, in_wtr = NULL, out_file_clf = NULL,
                    out_file_wtr = NULL, overwrite = F){
  slp <- terra::terrain(dtm)
  clf <- terra::ifel(slp >= 45, 0, 1)
  if (!is.null(in_wtr)){
    wtr_vect <- in_wtr
  } else {
    bbox <- terra::ext(dtm) |>
      terra::as.polygons()
    terra::crs(bbox) <- terra::crs(dtm)
    bbox <- terra::project(bbox, "EPSG:4326")
    cent <- terra::centroids(bbox)
    cent_crds <- terra::crds(cent)
    cent_lat <- cent_crds[1,2][[1]]
    cent_lon <- cent_crds[1,1][[1]]
    bbox_pts <- terra::as.points(bbox)
    dists <- terra::distance(cent, bbox_pts)
    max_dist <- max(dists)
    nhd <- nhdR::nhd_plus_query(cent_lon, cent_lat, dsn = c("NHDWaterbody"),
                                buffer_dist = units::as_units(max_dist, "m"))
    wtr_vect <- nhd[[1]][[1]] |> terra::vect()
  }
  wtr_vect$rastid <- 0
  wtr <- terra::project(wtr_vect, dtm) |>
    terra::rasterize(dtm, "rastid", background = 1) |>
    terra::crop(dtm)
  names(clf) <- "cliff"
  names(wtr) <- "water"
  if (!is.null(out_file_clf)){
    terra::writeRaster(clf, out_file_clf, overwrite)
  }
  if (!is.null(out_file_wtr)){
    terra::writeRaster(wtr, out_file_wtr, overwrite)
  }
  return(list(clf = clf, wtr = wtr))
}
