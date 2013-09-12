#' Lookup names in all taxonomies.
#' 
#' See details for information about the sources. Paging is supported
#' 
#' @template all
#' @importFrom httr GET content verbose
#' @importFrom plyr compact
#' @template occsearch
#' @template occ
#' @param georeferenced Return only occurence records with lat/long data (TRUE) or
#' all records (FALSE, default).
#' @examples \dontrun{
#' # Search by species name, using \code{gbif_lookup} first to get key
#' key <- gbif_lookup(name='Helianthus annuus', kingdom='plants')$speciesKey
#' occ_search(taxonKey=key, limit=2)
#' occ_search(taxonKey=key, limit=20)
#' occ_search(taxonKey=key, return='meta')
#' 
#' # Search by dataset key
#' occ_search(datasetKey='7b5d6a48-f762-11e1-a439-00145eb45e9a', return='data')
#' 
#' # Search by catalog number
#' occ_search(catalogNumber='PlantAndMushroom.6845144', minimal=FALSE)
#' 
#' # Occurrence data: lat/long data, and associated metadata with occurrences
#' ## If return='data' the output is a data.frame of all data together 
#' ## for easy manipulation
#' occ_search(taxonKey=key, return='data')
#' 
#' # Taxonomic hierarchy data
#' ## If return='meta' the output is a list of the hierarch for each record
#' occ_search(taxonKey=key, limit=20, return='hier')
#' 
#' ## You can get the unique hiearchies easily using \code{unique}
#' unique(occ_search(taxonKey=key, limit=20, return='hier'))
#' 
#' # Pass in curl options for extra fun
#' occ_search(taxonKey=key, limit=20, return='hier', callopts=verbose())
#' }
#' @export
occ_search <- function(taxonKey=NULL, georeferenced=NULL, boundingBox=NULL, 
  collectorName=NULL, basisOfRecord=NULL, datasetKey=NULL, date=NULL, catalogNumber=NULL, 
  callopts=list(), limit=20, start=NULL, minimal=TRUE, return='all')
{
  url = 'http://api.gbif.org/occurrence/search'
  args <- compact(list(taxonKey=taxonKey, georeferenced=georeferenced, 
                       boundingBox=boundingBox, collectorName=collectorName, 
                       basisOfRecord=basisOfRecord, datasetKey=datasetKey, date=date, 
                       catalogNumber=catalogNumber, limit=limit, offset=start))  
  iter <- 0
  sumreturned <- 0
  outout <- list()
  while(sumreturned < limit){
    iter <- iter + 1
    tt <- content(GET(url, query=args, callopts))
    numreturned <- length(tt$results)
    sumreturned <- sumreturned + numreturned
    if(sumreturned<limit){
      args$limit <- limit-numreturned
      args$offset <- sumreturned
    }
    outout[[iter]] <- tt
  }
  
  meta <- outout[[length(outout)]][c('offset','limit','endOfRecords','count')]
  data <- sapply(outout, "[[", "results")
  data <- gbifparser(data, minimal=minimal)
  if(return=='data'){
    ldfast(lapply(data, "[[", "data"))
  } else
    if(return=='hier'){
      lapply(data, "[[", "hierarch")
    } else
      if(return=='meta'){ data.frame(meta) } else
      {
        list(meta=meta, data=data)
      }
}