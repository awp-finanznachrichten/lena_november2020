#Bibliotheken laden
library(dplyr)
library(tidyr)
library(purrr)
library(readr)
library(ggplot2)
library(stringr)
library(stringi)
library(xml2)
library(rjson)
library(jsonlite)
library(readxl)

print("Benötigte Bibliotheken geladen\n")

#Link zu JSON-Daten / Daten einlesen
link_json <- "https://app-prod-static-voteinfo.s3.eu-central-1.amazonaws.com/v1/ogd/sd-t-17-02-20201129-eidgAbstimmung.json" 
#link_json <- "https://app-prod-static-voteinfo.s3.eu-central-1.amazonaws.com/v1/ogd/sd-t-17-02-20200927-eidgAbstimmung.json" 
json_data <- fromJSON(link_json, flatten = TRUE)

link_json_kantone <- "https://app-prod-static-voteinfo.s3.eu-central-1.amazonaws.com/v1/ogd/sd-t-17-02-20201129-kantAbstimmung.json"
#link_json_kantone <- "https://app-prod-static-voteinfo.s3.eu-central-1.amazonaws.com/v1/ogd/sd-t-17-02-20200209-kantAbstimmung.json"
json_data_kantone <- fromJSON(link_json_kantone, flatten = TRUE)

print("Aktuelle Abstimmungsdaten geladen\n")

#Kurznamen Vorlagen (Verwendet im File mit den Textbausteinen)
vorlagen_short <- c("Konzernverantwortung","Kriegsgeschaefte")

###Kurznamen und Nummern kantonale Vorlagen
kantonal_short <- c("FR_Pensionskasse","GE_Handicap","GE_Avusy")

#Nummer in JSON 
kantonal_number <- c(4,11,11) #3,13,13

#Falls mehrere Vorlagen innerhalb eines Kantons, Vorlage auswählen
kantonal_add <- c(1,1,2) # 1,1,1

###Vorhandene Daten laden Gripen / Masseneinwanderungsinitiative
daten_kriegsmaterial_bfs <- read_excel("Data/daten_kriegsmaterial_bfs.xlsx", 
                               skip = 10)

cat("Daten zu historischen Abstimmungen geladen\n")

#Metadaten Gemeinden und Kantone
meta_gmd_kt <- read_csv("Data/MASTERFILE_GDE.csv")

cat("Metadaten zu Gemeinden und Kantonen geladen\n")
