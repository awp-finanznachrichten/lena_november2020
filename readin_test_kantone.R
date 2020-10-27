
for (k in 1:length(kantonal_short) ) {

  
  
results <- get_results_kantonal(json_data_kantone,
                                kantonal_number[k],
                                kantonal_add[k])

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
#if (nrow(results) > 0) {
  
  #Daten anpassen
  results <- augment_raw_data(results)
  
  #Intros generieren
  results <- normal_intro(results)
  
  
#Vergleich innerhalb des Kantons (falls Daten vom Kanton vorhanden)

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
cat(paste0(results$Gemeinde_d,"\n",results$Text_d,"\n\n",results$Text_f,collapse="\n\n"))

###Ausgezählte und nicht ausgezählte Gemeinden wieder zusammenführen -> Immer gleiches Format für Datawrapper
if (nrow(results_notavailable) > 0) {
  
  results_notavailable$Ja_Stimmen_In_Prozent <- 50
  
  results <- rbind(results,results_notavailable) %>%
    arrange(Gemeinde_Nr)
  
}

###Output generieren für Datawrapper

#Output Abstimmungen Gemeinde

output_dw <- results %>%
  select(Gemeinde_Nr,Ja_Stimmen_In_Prozent,Gemeinde_KT_d,Gemeinde_KT_f,Text_d,Text_f)


write.csv(output_dw,paste0("Output/",kantonal_short[k],"_dw.csv"), na = "", row.names = FALSE, fileEncoding = "UTF-8")

cat(paste0("\nGenerated output for Vorlage ",kantonal_short[k],"\n"))
  
}
