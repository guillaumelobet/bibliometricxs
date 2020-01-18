
library(yaml)
library(rjson)
library(googlesheets)
library(lubridate)

path_pubs <- "https://raw.githubusercontent.com/guillaumelobet/guillaumelobet.github.io/master/_data/publications.yml"
path_pres <- "https://raw.githubusercontent.com/guillaumelobet/guillaumelobet.github.io/master/_data/presentations.yml"

ti <- gs_title("Bibliographic data")
bib_gs <- gs_read(ti, ws = 1)

print_num <- F
print_title <- T
print_authors <- T
print_first_author <- F
print_info <- T
print_doi <- T
print_journal <- F
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
journals <- c()
years <- c()
published <- 0

for(p in pubs){
  if(p$type == "journal"){
    # if(length(p$preprint) == 0){   
      if(length(p$doi) > 0){
        if(p$year >= min_year){
          bib <- ""
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
          if(print_doi) bib <- paste0(bib, "- [http://dx.doi.org/",p$doi,"]")
          tot_papers <- tot_papers - 1
          
          dims <- NULL
          altm <- NULL
          if(length(p$doi) > 0){
            
            if(print_info){
              bib_dat <- ""
              
              altm <- tryCatch({
                fromJSON(readLines(paste0("https://api.altmetric.com/v1/doi/",p$doi)))
              }, error = function(e) {
              })
              
              dims <- tryCatch({
                fromJSON(readLines(paste0("https://metrics-api.dimensions.ai/doi/",p$doi)))
              }, error = function(e) {
              })
              
              
              if(!is.null(altm)){
                bib_dat <- paste0(bib_dat, "[altmetric = ",round(altm$score),"] ")
              }else{
                bib_dat <- paste0(bib_dat, "[-] ")
              }
              if(!is.null(dims)){
                bib_dat <- paste0(bib_dat, "[citations = ",dims$times_cited,"] ")
                if(current_year - p$year >= 2) {
                  bib_dat <- paste0(bib_dat, "[fcr = ",dims$field_citation_ratio,"] ")
                  bib_dat <- paste0(bib_dat, "[rcr = ",dims$relative_citation_ratio,"] ")
                  
                }
                cites <-c(cites, dims$times_cited)
                fcrs <-c(fcrs, dims$field_citation_ratio)
                rcrs <-c(rcrs, dims$relative_citation_ratio)
                journals <-c(journals, p$journal)
                years <-c(years, p$year)
              }else{
                bib_dat <- paste0(bib_dat, "[citations = 0] ")
                if(current_year - p$year >= 2){
                  bib_dat <- paste0(bib_dat, "[fcr = 0] ")
                  bib_dat <- paste0(bib_dat, "[rcr = 0] ")
                }
              }
            }
          }
          published <- published + 1
          gs_edit_cells(ti, ws = "Sheet1", anchor = paste0("A",published), input = bib, byrow = TRUE)
          gs_edit_cells(ti, ws = "Sheet1", anchor = paste0("B",published), input = bib_dat, byrow = TRUE)
        }
      } 
    # }
  }
}


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
message(mess)

