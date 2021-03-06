
library(yaml)
library(bibtex)
library(rjson)
library(lubridate)

path_pubs <- "https://raw.githubusercontent.com/guillaumelobet/guillaumelobet.github.io/master/_data/publications.yml"
path_pres <- "https://raw.githubusercontent.com/guillaumelobet/guillaumelobet.github.io/master/_data/presentations.yml"
path_bib <-"~/Desktop/bib.txt"

print_num <- T
print_title <- T
print_authors <- T
print_first_author <- F
print_info <- T
print_doi <- T
print_journal <- T
min_year <- 2008
current_year <- year(today())

pubs <- read_yaml(path_pubs)
pres <- read_yaml(path_pres)
art_count <- 1

bib <- ""

tot_papers <- 0
tot_papers_2014 <- 0
for(p in pubs){
  if(p$type == "journal"){
    if(length(p$doi) > 0){
      if(p$year >= min_year){
        tot_papers <- tot_papers + 1
        if(p$year >= 2014){
          tot_papers_2014 <- tot_papers_2014 + 1
        }
      }
    } 
  }
}

tot_pres <-0
for(p in pres){
  year <- strsplit(p$date, " ")[[1]][2]
  if(as.numeric(year) >= min_year){
    tot_pres <- tot_pres + 1
  }
}

cites <-c()
fcrs <-c()
rcrs <-c()
published <- 0
journals <- c()
years <- c()


bib <- " ----------------- PREPRINTS --------------------\n "
for(p in pubs){
  if(p$type == "journal"){
    if(length(p$preprint) > 0){   
      if(p$year >= min_year){
        print(p$title)        
        if(print_num) bib <- paste0(bib ,"[",tot_papers,"]  ")
        if(print_title) bib <- paste0(bib ,p$title,", ")
        if(print_authors) bib <- paste0(bib, p$authors, "")
        if(print_first_author){
          auth <- strsplit(strsplit(p$authors, ",")[[1]], " ")[[1]][1]
          bib <- paste0(bib, auth, "")
        }
        if(print_journal) bib <- paste0(bib, ", ", p$journal)
        bib <- paste0(bib, " (",p$year,") ")
        tot_papers <- tot_papers - 1
        dims <- NULL
        altm <- NULL
        if(length(p$doi) > 0){
          
          if(print_info){
            altm <- tryCatch({
              fromJSON(readLines(paste0("https://api.altmetric.com/v1/doi/",p$doi)))
            }, error = function(e) {
            })
            
            dims <- tryCatch({
              fromJSON(readLines(paste0("https://metrics-api.dimensions.ai/doi/",p$doi)))
            }, error = function(e) {
            })
            
            
            if(!is.null(altm)){
              bib <- paste0(bib, "[altmetric = ",round(altm$score),"] ")
            }else{
              bib <- paste0(bib, "[altmetric =-] ")
            }
            if(!is.null(dims)){
              if(!is.null(dims$times_cited)){
                bib <- paste0(bib, "[citations = ",dims$times_cited,"] ")
              }
              if(!is.null(dims$field_citation_ratio)){
                bib <- paste0(bib, "[fcr = ",dims$field_citation_ratio,"] ")
              }
              if(!is.null(dims$relative_citation_ratio)){
                bib <- paste0(bib, "[rcr = ",dims$relative_citation_ratio,"] ")
              }
              cites <-c(cites, dims$times_cited)
              journals <-c(journals, p$journal)
              years <-c(years, p$year)
            }else{
              bib <- paste0(bib, "[citations = 0] ")
              if(current_year - p$year > 2) bib <- paste0(bib, "[fcr = 0] ")
            }
          }
          if(print_doi) bib <- paste0(bib, " - [http://dx.doi.org/",p$doi,"][PREPRINT] \n\n\n")
        }
        art_count <- art_count + 1
      }
    }
  }
}

bib <- paste0(bib, "\n\n ----------------- PUBLISHED ARTICLES -------------------- \n\n")





for(p in pubs){
  if(p$type == "journal"){
    if(length(p$preprint) == 0){   
      if(length(p$doi) > 0){
        if(p$year >= min_year){
          print(p$title)
          
          if(print_num) bib <- paste0(bib ,"[",tot_papers,"]  ")
          if(print_title) bib <- paste0(bib ,p$title,", ")
          if(print_authors) bib <- paste0(bib, p$authors, "")
          if(print_first_author){
            auth <- strsplit(strsplit(p$authors, ",")[[1]], " ")[[1]][1]
            bib <- paste0(bib, auth, "")
          }          
          if(print_journal) bib <- paste0(bib, ", ", p$journal)
          bib <- paste0(bib, " (",p$year,") ")
          
          tot_papers <- tot_papers - 1
          
          dims <- NULL
          altm <- NULL
          if(length(p$doi) > 0){
            
            if(print_info){
                
              altm <- tryCatch({
                fromJSON(readLines(paste0("https://api.altmetric.com/v1/doi/",p$doi)))
              }, error = function(e) {
              })
              
              dims <- tryCatch({
                fromJSON(readLines(paste0("https://metrics-api.dimensions.ai/doi/",p$doi)))
              }, error = function(e) {
              })
              
              
              if(!is.null(altm)){
                bib <- paste0(bib, "[altmetric = ",round(altm$score),"] ")
              }else{
                bib <- paste0(bib, "[-] ")
              }
              if(!is.null(dims)){
                if(!is.null(dims$times_cited)){
                  bib <- paste0(bib, "[citations = ",dims$times_cited,"] ")
                }
                if(!is.null(dims$field_citation_ratio)){
                  bib <- paste0(bib, "[fcr = ",dims$field_citation_ratio,"] ")
                }
                if(!is.null(dims$relative_citation_ratio)){
                  bib <- paste0(bib, "[rcr = ",dims$relative_citation_ratio,"] ")
                }
                cites <-c(cites, dims$times_cited)
                fcrs <-c(fcrs, dims$field_citation_ratio)
                rcrs <-c(rcrs, dims$relative_citation_ratio)
                journals <-c(journals, p$journal)
                years <-c(years, p$year)
              }else{
                bib <- paste0(bib, "[citations = -] ")
                if(current_year - p$year >= 2){
                  bib <- paste0(bib, "[fcr = -] ")
                  bib <- paste0(bib, "[rcr = -] ")
                }
              }
            }
            if(print_doi) bib <- paste0(bib, "- [http://dx.doi.org/",p$doi,"]")
            bib <- paste0(bib, "\n\n\n")
          }
          published <- published + 1
        }
      } 
    }
  }
}


bib <- paste0(bib, "\n\n  ----------------- INVITED CONFERENCES -------------------- %%%\n\n")
invited <- 0
for(p in pres){
  if(length(p$status) > 0){
    year <- strsplit(p$date, " ")[[1]][2]
    if(as.numeric(year) >= min_year){
      print(p$title)
      invited <- invited + 1
      loc <- paste0(strsplit(p$location, ",")[[1]][2],", ",strsplit(p$location, ",")[[1]][3])
      conf <- strsplit(p$location, ",")[[1]][1]
      
      if(print_num) bib <- paste0(bib ,"[",tot_pres,"]  ")
      tot_pres <- tot_pres-1
      bib <- paste0(bib ,p$title,", Lobet, G")
      bib <- paste0(bib, " (",year,") ")
      bib <- paste0(bib, conf,", ")
      bib <- paste0(bib, loc, " ")
      if(length(p$slides_url) > 0){
        bib <-paste0(bib, "[",p$slides_url,"]")
      }
      bib <- paste0(bib, "[INVITED]\n\n")  
    }
  }
}

bib <- paste0(bib, "\n\n %%% ----------------- CONFERENCES -------------------- %%%\n\n")

for(p in pres){
  if(length(p$status) == 0){
    
    year <- strsplit(p$date, " ")[[1]][2]
    if(as.numeric(year) >= min_year){
      print(p$title)
      loc <- paste0(strsplit(p$location, ",")[[1]][2],", ",strsplit(p$location, ",")[[1]][3])
      conf <- strsplit(p$location, ",")[[1]][1]
      
      if(print_num) bib <- paste0(bib ,"[",tot_pres,"]  ")
      tot_pres <- tot_pres-1
      bib <- paste0(bib ,p$title,", Lobet, G")
      bib <- paste0(bib, " (",year,") ")
      bib <- paste0(bib, conf,", ")
      bib <- paste0(bib, loc, " ")
      if(length(p$slides_url) > 0){
        bib <-paste0(bib, "[",p$slides_url,"]")
      }
      bib <- paste0(bib, "\n\n") 
    }
  }
}

cat(bib, file = path_bib)

cites <- sort(cites, decreasing = T)
hindex <- 0
for(i in 1:length(cites)){
  if(i <= cites[i]) hindex <- hindex+1
} 
mess <- "------------------------------------\n"
mess <- paste0(mess, "published articles = ",published,"\n")
mess <- paste0(mess, "h-index = ",hindex,"\n")
mess <- paste0(mess, "total citations = ",sum(cites),"\n")
mess <- paste0(mess, "average citations = ",round(mean(cites)),"\n")
mess <- paste0(mess, "median citations = ",median(cites),"\n")
mess <- paste0(mess, "average fcr = ",round(mean(fcrs)),"\n")
mess <- paste0(mess, "median fcr = ",median(fcrs),"\n")
mess <- paste0(mess, "average rcr = ",mean(rcrs),"\n")
mess <- paste0(mess, "median rcr = ",median(rcrs),"\n")
mess <- paste0(mess, "invitation to conferences = ",invited,"\n")
message(mess)

