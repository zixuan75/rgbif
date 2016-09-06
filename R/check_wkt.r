#' Check input WKT
#'
#' @export
#' @param wkt A Well Known Text object
#' @examples
#' check_wkt('POLYGON((30.1 10.1, 10 20, 20 60, 60 60, 30.1 10.1))')
#' check_wkt('POINT(30.1 10.1)')
#' check_wkt('LINESTRING(3 4,10 50,20 25)')
#'
#' wkt <- 'MULTIPOLYGON(((30 20, 45 40, 10 40, 30 20)),((15 5, 40 10, 10 20, 5 10, 15 5)))'
#' check_wkt(wkt)
#'
#' # check many passed in at once
#' check_wkt(c('POLYGON((30.1 10.1, 10 20, 20 60, 60 60, 30.1 10.1))', 'POINT(30.1 10.1)'))
#'
#' # this passes this check, but isn't valid for GBIF
#' wkt <- 'POLYGON((-178.59375 64.83258989321493,-165.9375 59.24622380205539,
#' -147.3046875 59.065977905449806,-130.78125 51.04484764446178,-125.859375 36.70806354647625,
#' -112.1484375 23.367471303759686,-105.1171875 16.093320185359257,-86.8359375 9.23767076398516,
#' -82.96875 2.9485268155066175,-82.6171875 -14.812060061226388,-74.8828125 -18.849111862023985,
#' -77.34375 -47.661687803329166,-84.375 -49.975955187343295,174.7265625 -50.649460483096114,
#' 179.296875 -42.19189902447192,-176.8359375 -35.634976650677295,176.8359375 -31.835565983656227,
#' 163.4765625 -6.528187613695323,152.578125 1.894796132058301,135.703125 4.702353722559447,
#' 127.96875 15.077427674847987,127.96875 23.689804541429606,139.921875 32.06861069132688,
#' 149.4140625 42.65416193033991,159.2578125 48.3160811030533,168.3984375 57.019804336633165,
#' 178.2421875 59.95776046458139,-179.6484375 61.16708631440347,-178.59375 64.83258989321493))'
#' check_wkt(gsub("\n", '', wkt))

check_wkt <- function(wkt = NULL){
  if (!is.null(wkt)) {
    stopifnot(is.character(wkt))
    y <- strextract(wkt, "[A-Z]+")

    wkts <- c('POINT', 'POLYGON', 'MULTIPOLYGON', 'LINESTRING', 'LINEARRING')

    for (i in seq_along(wkt)) {
      if (!y[i] %in% wkts) {
        stop(
          paste0("WKT must be one of the types: ", paste0(wkts, collapse = ", ")),
          call. = FALSE
        )
      }
      res <- tryCatch(read_wkt(wkt[i]), error = function(e) e)
      if (!inherits(res, 'list')) {
        stop(res$message, call. = FALSE)
      }
    }

    return(wkt)
  } else {
    NULL
  }
}
