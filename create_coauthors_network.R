

# co-authors network


library(yaml)

path_pubs <- "https://raw.githubusercontent.com/guillaumelobet/guillaumelobet.github.io/master/_data/publications.yml"
pubs <- read_yaml(path_pubs)

i <- 1
for(p in pubs){
  if(i > 1){
    auths <- strsplit(strsplit(p$authors, ",")[[1]], " ")[[1]][1]
  }
}