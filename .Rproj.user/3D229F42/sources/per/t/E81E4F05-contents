
library(yaml)
library(rjson)
library(tidyverse)
library(cowplot)

path_pubs <- "https://raw.githubusercontent.com/guillaumelobet/guillaumelobet.github.io/master/_data/publications.yml"

pubs <- read_yaml(path_pubs)
current_year  <- 2019
papers <- NULL

for(p in pubs){
  if(p$type == "journal"){
      if(length(p$doi) > 0){
          print(p$title)
          
          temp <- data.frame(title = p$title,
                             authors = p$authors,
                             journal = p$journal,
                             year = p$year, 
                             doi = p$doi,
                             altmetrics = NA,
                             altmetrics_pc = NA,
                             cites = NA, 
                             fcr = NA, 
                             rcr = NA
                             )

          altm <- NULL
          altm <- tryCatch({
            fromJSON(readLines(paste0("https://api.altmetric.com/v1/doi/",p$doi)))
          }, error = function(e) {
          })
          if(!is.null(altm)){
            temp$altmetrics <- round(altm$score)
            temp$altmetrics_pc <- round(altm$context$all$pct)
          }
          
          dims <- NULL
          dims <- tryCatch({
            fromJSON(readLines(paste0("https://metrics-api.dimensions.ai/doi/",p$doi)))
          }, error = function(e) {
          })

          if(!is.null(dims)){
            if(!is.null(dims$times_cited)) temp$cites <- dims$times_cited
            # if(current_year - p$year > 2){
              if(!is.null(dims$field_citation_ratio)) temp$fcr <- dims$field_citation_ratio
              if(!is.null(dims$relative_citation_ratio)) temp$rcr <- dims$relative_citation_ratio
            # }
          }
          
          papers <- rbind(papers, temp)
      }
    } 
}

papers$id <- c(1:nrow(papers))

cites <- sort(papers$cites, decreasing = T)
hindex <- 0
for(i in 1:length(cites)){
  if(i <= cites[i]) hindex <- hindex+1
} 


ggplot(papers, aes(id, altmetrics)) + 
  geom_point()

papers %>% 
  mutate(rank = row_number(desc(cites))) %>% 
  ggplot(aes(rank, cites)) + 
  xlab(" ") + 
  ylab("# citations [-]")+
  geom_point(colour="#f0522a")+
    geom_abline(intercept = 0, slope = 1, lty=3) + 
    geom_vline(xintercept = hindex, lty=2)
  

papers %>% 
  filter(!is.na(fcr)) %>% 
  mutate(rank = row_number(desc(fcr))) %>% 
  ggplot(aes(rank, fcr)) + 
    xlab(" ") + 
    ylab("FCR [-]")+
  geom_point(colour="#f0522a") + 
  geom_hline(yintercept = 1, lty=2) 


papers %>% 
  filter(!is.na(rcr)) %>% 
  mutate(rank = row_number(desc(rcr))) %>% 
  ggplot(aes(rank, rcr)) + 
  xlab(" ") + 
  ylab("RCR [-]")+
  geom_point(colour="#f0522a") + 
  geom_hline(yintercept = 1, lty=2) +
  geom_hline(yintercept = 2.39, lty=2)+
  geom_hline(yintercept = 5.72, lty=2)


papers %>% 
  filter(!is.na(altmetrics)) %>% 
  mutate(rank = row_number(desc(altmetrics))) %>% 
  ggplot(aes(rank, altmetrics)) + 
  xlab(" ") + 
  ylab("Altmetric [-]")+
  geom_point(colour="#f0522a")

papers %>% 
  filter(!is.na(cites)) %>% 
  ggplot(aes(id, cites)) + 
  xlab("paper ID [-]") + 
  ylab("# citations [-]")+
  geom_point(colour="#f0522a")



papers %>% 
  filter(!is.na(rcr)) %>% 
  ggplot(aes(id, rcr)) + 
  geom_point(colour="#f0522a") + 
  geom_hline(yintercept = 1, lty=2)


papers %>% 
  filter(!is.na(rcr)) %>% 
  ggplot(aes(rcr, fcr)) + 
  geom_point()

