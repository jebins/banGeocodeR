### geocodeR ###
### server main ###
## Copyright (C) 2017 Jérémy Commmins <jebins@openaliasbox.org>


# server function ---------------------------------------------------------

function(input, output) {
  # file import
  datafile <- callModule(uploadModule, "datafile")
  # datatable
  tabselect <- callModule(DTtable, "tabimport", reactive( datafile() ))
  # correction des adresses
  tabcorr <- callModule(correctionModule, "tabcorrection", reactive( tabselect() ))
  # map
  callModule(leafletModule, "carte_csv", data_brut = reactive( datafile() ), data_corr = reactive( tabcorr() ))
  # manual geocoding
  callModule(manuelModule, "tabmanuel")
}
