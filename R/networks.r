#' Networks metadata.
#' 
#' @template all
#' @template occ
#' @template identifierargs
#' @export
#' 
#' @param data The type of data to get. Default is all data.
#' @param uuid UUID of the data network provider. This must be specified if data
#'    is anything other than 'all'.
#' @param query Query nodes. Only used when data='all'. Ignored otherwise.
#' @param identifier The value for this parameter can be a simple string or integer, 
#'    e.g. identifier=120. This parameter doesn't seem to work right now.
#' @param identifierType Used in combination with the identifier parameter to filter 
#'    identifiers by identifier type. See details. This parameter doesn't seem to 
#'    work right now.
#' 
#' @examples \dontrun{
#' networks(limit=5)
#' networks(uuid='16ab5405-6c94-4189-ac71-16ca3b753df7')
#' networks(data='endpoint', uuid='16ab5405-6c94-4189-ac71-16ca3b753df7')
#' }

networks <- function(data = 'all', uuid = NULL, query = NULL, identifier=NULL,
                     identifierType=NULL, limit=100, start=NULL, callopts=list())
{
  args <- rgbif_compact(list(q = query, limit=as.integer(limit), offset=start))
  data <- match.arg(data, choices=c('all', 'contact', 'endpoint', 'identifier', 
                                    'tag', 'machineTag', 'comment', 'constituents'), several.ok = TRUE)
  
  # Define function to get data
  getdata <- function(x){
    if(!x == 'all' && is.null(uuid))
      stop('You must specify a uuid if data does not equal "all"')
    
    url <- if(is.null(uuid)){ paste0(gbif_base(), '/network') } else {
      if(x=='all'){ sprintf('%s/network/%s', gbif_base(), uuid) } else {
        sprintf('%s/network/%s/%s', gbif_base(), uuid, x)
      }
    }
    res <- gbif_GET(url, args, callopts, TRUE)
    structure(list(meta=get_meta(res), data=parse_results(res, uuid)))
  }
  
  # Get data
  if(length(data)==1) getdata(data) else lapply(data, getdata)
}
