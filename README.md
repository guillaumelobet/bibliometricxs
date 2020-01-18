# bibliometricxs
 Script to scrap bibliometric data from web services

#### `meaningfull_metrics_from_dois.R`

From a list of doi get:

- title, authors, journals, ... from CrossRef
- online attention score from Altmetrics
- citation, field citation ratio and relative citation ratio from Dimension.io


#### `update_citations_yaml_txt.R`

From a YAML file [like this one](https://raw.githubusercontent.com/guillaumelobet/guillaumelobet.github.io/master/_data/publications.yml), with the dois of the papers, get the same info as the one below and send everything to a txt file


#### `update_citations_yaml_gsheet.R`

From a YAML file [like this one](https://raw.githubusercontent.com/guillaumelobet/guillaumelobet.github.io/master/_data/publications.yml), with the dois of the papers, get the same info as the one below and send everything to a Google Sheet