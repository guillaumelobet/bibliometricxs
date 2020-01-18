
library(tidyverse)
library(rjson)
library(XML)

# Get bibliometric informations from list of DOIs
dois <- c("http://doi.org/10.1104/pp.19.00617,10.1104/pp.111.179895,10.1186/1746-4811-9-1,10.1186/1746-4811-9-xx")
sep <- ","  # doi separator 

pubs <- gsub("http://", "", dois)
pubs <- gsub("https://", "", pubs)
pubs <- gsub("www.doi.org/", "", pubs)
pubs <- gsub("doi.org/", "", pubs)

pubs <- strsplit(pubs, sep)[[1]]

all <- NULL

  for(p in pubs){
    
    p <- gsub("\n", "", p)
    p <- gsub(" ", "", p)
    print(p)

    temp <- tibble("doi" = p, 
                   "title" = "-", 
                   "authors" = "-", 
                   "pages" = "-", 
                   "volume" = "-", 
                   "year" = "-", 
                   "journal" = "-", 
                   "altmetric" = "-", 
                   "rcr" = "-", 
                   "fcr" = "-", 
                   "citations" = "-")
    
    
    # ------------------------
    # Get data from CrossRef
    crossref <- NULL
    tryCatch({
      crossref<- fromJSON(readLines(paste0("https://api.crossref.org/v1/works/",p)))
      temp$title <- crossref$message$title
      
      text_auth <- ""
      auths <- crossref$message$author
      for(au in auths){
        if(text_auth == ""){
          text_auth <- paste0(au$family, ", ", au$given)
        }else{
          text_auth <- paste0(text_auth, ", ", au$family, ", ", au$given)
        }
      }
      
      temp$authors <- text_auth
      temp$year <- crossref$message$created$`date-parts`[[1]][1]
      temp$journal <- crossref$message$`container-title`
      if(!is.null(crossref$message$volume)){
        temp$volume <- crossref$message$volume
      }
      if(!is.null(crossref$message$page)){
        temp$pages <- crossref$message$page
      }
    }, error = function(e) {
      print("Error : Crossref data not found")
    })
    
    # ------------------------
    # Get data from Altmetric
    tryCatch({
      altm <- fromJSON(readLines(paste0("https://api.altmetric.com/v1/doi/",p)))
      temp$altmetric <- round(altm$score)
    }, error = function(e){ 
      print("Error : Altmetric data not found")
    })
    
    # ------------------------
    # Get data from Dimensions
    tryCatch({
      dims <- fromJSON(readLines(paste0("https://metrics-api.dimensions.ai/doi/",p)))
      temp$citations <- dims$times_cited
      if(temp$year != ""){
        if(!is.null(dims$field_citation_ratio)){
          temp$fcr <- dims$field_citation_ratio
        }
        if(!is.null(dims$relative_citation_ratio)){
          temp$rcr <- dims$relative_citation_ratio
        }
      }
    }, error = function(e) { 
      print("Error : Dimensions data not found")
    })
    
    all <- rbind(all, temp)
  }
  
  print(all)
    
