#' Density function
#'
#' @description
#' `dns_fun()` defines the calculation of normalized relative lidar point
#' density (proxy for vegetation density) that is applied to every pixel within
#' the extent of a lidar dataset using `gen_dns()`.
#'
#' @param z numeric. Aboveground lidar point heights.
#' @param hgt_1 numeric. The bottom value of the vegetation density height
#' range.
#' @param hgt_2 numeric. The top value of the vegetation density height range.
#'
#' @returns A numeric value representing normalized relative lidar point
#' density.
#' @export

dns_fun <- function(z, hgt_1, hgt_2){
  num <- length(z[z >= hgt_1 & z <= hgt_2])
  den <- length(z[z <= hgt_2])
  dns <- num / den
  return(list(dns = dns))
}
