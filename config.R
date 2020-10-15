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
link_json <- "https://app-prod-static-voteinfo.s3.eu-central-1.amazonaws.com/v1/ogd/sd-t-17-02-20200927-eidgAbstimmung.json" 
json_data <- fromJSON(link_json, flatten = TRUE)

print("Aktuelle Abstimmungsdaten geladen\n")


#Kurznamen Vorlagen (Verwendet im File mit den Textbausteinen)
vorlagen_short <- c("Konzernverantwortung","Kriegsgeschaefte")


###Vorhandene Daten laden Gripen / Masseneinwanderungsinitiative
daten_kriegsmaterial_bfs <- read_excel("Data/daten_kriegsmaterial_bfs.xlsx", 
                               skip = 10)

cat("Daten zu historischen Abstimmungen geladen\n")

#Metadaten Gemeinden und Kantone
meta_gmd_kt <- read_csv("Data/MASTERFILE_GDE.csv")

cat("Metadaten zu Gemeinden und Kantonen geladen\n")



