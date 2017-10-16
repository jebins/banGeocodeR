function(input, output) {
  # import du fichier
  datafile <- callModule(uploadModule, "datafile")
  # affichage tableau
  tabselect <- callModule(DTtable, "tabimport", reactive( datafile() ))
  # correction des adresses
  tabcorr <- callModule(correctionModule, "tabcorrection", reactive( tabselect() ))
  # carte interactive
  callModule(leafletModule, "carte_csv", data_brut = reactive( datafile() ), data_corr = reactive( tabcorr() ))
  # géocodage manuel
  callModule(manuelModule, "tabmanuel")
}
