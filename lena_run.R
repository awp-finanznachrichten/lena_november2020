#Zeit stoppen
time_start <- Sys.time()


#Working Directory definieren
setwd("C:/Users/simon/OneDrive/LENA_Project/lena_november2020")

###Config: Bibliotheken laden, Pfade/Links definieren, bereits vorhandene Daten laden
source("config.R",encoding = "UTF-8")

###Funktionen laden
source("functions_readin.R", encoding = "UTF-8")
source("functions_storyfinder.R", encoding = "UTF-8")
source("functions_storybuilder.R", encoding = "UTF-8")

#Anzahl, Name und Nummer der Vorlagen von JSON einlesen
vorlagen <- get_vorlagen(json_data,"de")

###Natioanle Abstimmungen###

for (i in 1:length(vorlagen_short)) {

cat(paste0("\nErmittle Daten für folgende Vorlage: ",vorlagen$text[i],"\n"))
  
###Resultate aus JSON auslesen 
results <- get_results(json_data,i)

#Daten anpassen Gemeinden
results <- treat_gemeinden(results)
results <- format_data_g(results)

#Kantonsdaten hinzufügen
results_kantone <- get_results(json_data,i,"cantonal")

Ja_Stimmen_Kanton <- results_kantone %>%
  select(Kantons_Nr,jaStimmenInProzent) %>%
  rename(Ja_Stimmen_In_Prozent_Kanton = jaStimmenInProzent) %>%
  mutate(Highest_Yes_Kant = FALSE,
         Highest_No_Kant = FALSE)

results <- merge(results,Ja_Stimmen_Kanton)


#Wie viele Gemeinden sind ausgezählt?
cat(paste0(sum(results$Gebiet_Ausgezaehlt)," Gemeinden sind ausgezählt.\n"))

#Neue Variablen
results$Ja_Nein <- NA
results$Oui_Non <- NA
results$Nein_Stimmen_In_Prozent <- NA
results$Unentschieden <- NA
results$Einstimmig_Ja <- NA
results$Einstimmig_Nein <- NA
results$kleine_Gemeinde <- NA
results$Storyboard <- NA
results$Text_d <- "Die Resultate von dieser Gemeinde sind noch nicht bekannt."
results$Text_f <- "Les résultats ne sont pas encore connus dans cette commune."

hist_check <- FALSE

#Ausgezählte Gemeinden auswählen
results_notavailable <- results[results$Gebiet_Ausgezaehlt == FALSE,]
results <- results[results$Gebiet_Ausgezaehlt == TRUE,]

#Sind schon Daten vorhanden?
if (nrow(results) > 0) {

#Daten anpassen
results <- augment_raw_data(results)

#Intros generieren
results <- normal_intro(results)

#LENA-Classics (falls alle Gemeinden ausgezählt):
if (nrow(results_notavailable) == 0) {

results <- lena_classics(results)

}  


#Historischer Vergleich (falls vorhanden)

#Check Vorlagen-ID

if (vorlagen$id[i] == "6320") { #6370

hist_check <- TRUE 
data_hist <- format_data_hist(daten_kriegsmaterial_bfs)
results <- merge(results,data_hist,all.x = TRUE)
results <- hist_storyfinder(results)

}


#Vergleich innerhalb des Kantons (falls alle Daten vom Kanton vorhanden)

#Check Vorlagen-ID
if (vorlagen$id[i] == "6310") { #6360
  

#Falls mindestens ein Kanton ausgezählt -> Stories für die Kantone finden
  
if (sum(results_kantone$gebietAusgezaehlt) > 0) {
  
results <- kanton_storyfinder(results)

}

}



###Storybuilder

#Textvorlagen laden
Textbausteine <- as.data.frame(read_excel("Data/Textbausteine_LENA_November2020.xlsx", 
                                               sheet = vorlagen_short[i]))
cat("Textvorlagen geladen\n\n")

#Texte einfügen
results <- build_texts(results)

#Variablen ersetzen 
results <- replace_variables(results)

###Texte anpassen und optimieren
results <- excuse_my_french(results)

#Print out texts
#cat(paste0(results$Gemeinde_d,"\n",results$Text_d,"\n\n",results$Text_f,collapse="\n\n"))

}
###Ausgezählte und nicht ausgezählte Gemeinden wieder zusammenführen -> Immer gleiches Format für Datawrapper
if (nrow(results_notavailable) > 0) {

results_notavailable$Ja_Stimmen_In_Prozent <- 50

if (hist_check == TRUE) {
results_notavailable$Hist_Ja_Stimmen_In_Prozent <- NA
results_notavailable$Hist_Ja_Stimmen_Absolut <- NA
results_notavailable$Hist_Nein_Stimmen_In_Prozent <- NA
results_notavailable$Hist_Nein_Stimmen_Absolut <- NA
}

results <- rbind(results,results_notavailable) %>%
  arrange(Gemeinde_Nr)

}


###Output generieren für Datawrapper

#Output Abstimmungen Gemeinde

output_dw <- results %>%
  select(Gemeinde_Nr,Ja_Stimmen_In_Prozent,Gemeinde_KT_d,Gemeinde_KT_f,Text_d,Text_f)

#Anpassungen (Ticino Verzasca)
gemeinde_adapt <- output_dw[output_dw$Gemeinde_Nr == 5399,] 
gemeinde_adapt$Gemeinde_Nr[1] <- 5102
output_dw <- rbind(output_dw,gemeinde_adapt)

gemeinde_adapt$Gemeinde_Nr[1] <- 5095
output_dw <- rbind(output_dw,gemeinde_adapt)

gemeinde_adapt$Gemeinde_Nr[1] <- 5105
output_dw <- rbind(output_dw,gemeinde_adapt)

gemeinde_adapt$Gemeinde_Nr[1] <- 5129
output_dw <- rbind(output_dw,gemeinde_adapt)

gemeinde_adapt$Gemeinde_Nr[1] <- 5135
output_dw <- rbind(output_dw,gemeinde_adapt)

#Output speichern
write.csv(output_dw,paste0("Output/",vorlagen_short[i],"_dw.csv"), na = "", row.names = FALSE, fileEncoding = "UTF-8")


#Output Abstimmungen Kantone
output_dw_kantone <- results %>%
  select(Kantons_Nr,Kanton_d,Kanton_f,Ja_Stimmen_In_Prozent_Kanton) %>%
  mutate(Nein_Stimmen_In_Prozent_Kanton = round(100-Ja_Stimmen_In_Prozent_Kanton,1),
         Ja_Stimmen_In_Prozent_Kanton = round(Ja_Stimmen_In_Prozent_Kanton,1),
         Text_de = NA,
         Text_fr = NA) %>%
  unique()

for (y in 1:nrow(output_dw_kantone)) {

if (is.na(output_dw_kantone$Ja_Stimmen_In_Prozent_Kanton[y]) == TRUE) { 
  
  output_dw_kantone$Ja_Stimmen_In_Prozent_Kanton[y] <- 50
  output_dw_kantone$Text_de[y] <- "Die Resultate von diesem Kanton sind noch nicht bekannt."
  output_dw_kantone$Text_fr[y] <- "Les résultats ne sont pas encore connus dans ce canton."
} else {
  
  output_dw_kantone$Text_de[y] <- paste0("Ja-Anteil: ",output_dw_kantone$Ja_Stimmen_In_Prozent_Kanton[y]," % <br>",
                                      "Nein-Anteil: ",output_dw_kantone$Nein_Stimmen_In_Prozent_Kanton[y]," %")
  output_dw_kantone$Text_fr[y] <- paste0("pourcentage de oui: ",output_dw_kantone$Ja_Stimmen_In_Prozent_Kanton[y]," % <br>",
                                         "pourcentage de non: ",output_dw_kantone$Nein_Stimmen_In_Prozent_Kanton[y]," %") 
  
}  
  
}  

write.csv(output_dw_kantone,paste0("Output/",vorlagen_short[i],"_dw_kantone.csv"), na = "", row.names = FALSE, fileEncoding = "UTF-8")

cat(paste0("\nGenerated output for Vorlage ",vorlagen_short[i],"\n"))
}




###Kantonale Abstimmungen###

for (k in 1:length(kantonal_short) ) {
  
  cat(paste0("\nErmittle Daten für folgende Vorlage: ",kantonal_short[k],"\n"))
  
  results <- get_results_kantonal(json_data_kantone,
                                  kantonal_number[k],
                                  kantonal_add[k])
  
  #Daten simulieren Gemeinde!!!
  #for (a in 1:nrow(results)) { 
  
  #results$gebietAusgezaehlt[a] = TRUE
  
  #results$jaStimmenAbsolut[a] <- sample(0:10000,1)
  #results$neinStimmenAbsolut[a] <- sample(0:10000,1)
  #results$gueltigeStimmen[a] <- results$jaStimmenAbsolut[a] + results$neinStimmenAbsolut[a]
  #results$jaStimmenInProzent[a] <- results$jaStimmenAbsolut[a]*100/results$gueltigeStimmen[a]
  
  #}
  
  
  #Daten anpassen Gemeinden
  results <- treat_gemeinden(results)
  results <- format_data_g(results)

  #Kantonsergebnis hinzufügen
  Ja_Stimmen_Kanton <- get_results_kantonal(json_data_kantone,
                                            kantonal_number[k],
                                            kantonal_add[k],
                                            "kantonal")
  
  results$Ja_Stimmen_In_Prozent_Kanton <- Ja_Stimmen_Kanton

  #Wie viele Gemeinden sind ausgezählt?
  cat(paste0(sum(results$Gebiet_Ausgezaehlt)," Gemeinden sind ausgezählt.\n"))
  
  #Neue Variablen
  results$Ja_Nein <- NA
  results$Oui_Non <- NA
  results$Nein_Stimmen_In_Prozent <- NA
  results$Unentschieden <- NA
  results$Einstimmig_Ja <- NA
  results$Einstimmig_Nein <- NA
  results$kleine_Gemeinde <- NA
  results$Highest_Yes_Kant <- FALSE
  results$Highest_No_Kant <- FALSE
  results$Storyboard <- NA
  results$Text_d <- "Die Resultate von dieser Gemeinde sind noch nicht bekannt."
  results$Text_f <- "Les résultats ne sont pas encore connus dans cette commune."
  
  hist_check <- FALSE
  
  #Ausgezählte Gemeinden auswählen
  results_notavailable <- results[results$Gebiet_Ausgezaehlt == FALSE,]
  results <- results[results$Gebiet_Ausgezaehlt == TRUE,]
  
  #Sind schon Daten vorhanden?
  if (nrow(results) > 0) {
  
  #Daten anpassen
  results <- augment_raw_data(results)
  
  #Intros generieren
  results <- normal_intro(results)
  
  
  #Vergleich innerhalb des Kantons (falls Daten vom Kanton vorhanden) -> Ändern von FALSE auf TRUE
  
  if (json_data_kantone$kantone$vorlagen[[kantonal_number[k]]]$vorlageBeendet[[kantonal_add[k]]] == TRUE) {
    
    results <- kanton_storyfinder_kantonal(results)
    
  }
  
  #Textvorlagen laden
  Textbausteine <- as.data.frame(read_excel("Data/Textbausteine_LENA_November2020.xlsx", 
                                            sheet = kantonal_short[k]))
  cat("Textvorlagen geladen\n\n")
  
  #Texte einfügen
  results <- build_texts(results)
  
  #Variablen ersetzen 
  results <- replace_variables(results)
  
  ###Texte anpassen und optimieren
  results <- excuse_my_french(results)
  
  #Print out texts
  #cat(paste0(results$Gemeinde_d,"\n",results$Text_d,"\n\n",results$Text_f,collapse="\n\n"))
  
  }
  ###Ausgezählte und nicht ausgezählte Gemeinden wieder zusammenführen -> Immer gleiches Format für Datawrapper
  if (nrow(results_notavailable) > 0) {
    
    results_notavailable$Ja_Stimmen_In_Prozent <- 50
    
    results <- rbind(results,results_notavailable) %>%
      arrange(Gemeinde_Nr)
    
  }
  
  ###Output generieren für Datawrapper

  
  output_dw <- results %>%
    select(Gemeinde_Nr,Ja_Stimmen_In_Prozent,Gemeinde_KT_d,Gemeinde_KT_f,Text_d,Text_f)
  
  
  write.csv(output_dw,paste0("Output/",kantonal_short[k],"_dw.csv"), na = "", row.names = FALSE, fileEncoding = "UTF-8")
  
  cat(paste0("\nGenerated output for Vorlage ",kantonal_short[k],"\n"))
  
}

#Wie lange hat LENA gebraucht
time_end <- Sys.time()
print(time_end-time_start)


