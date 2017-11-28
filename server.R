### BANgeocodeR ###
### server : main ###
### Copyright (C) 2017 Jérémy Commmins ###


# server function ---------------------------------------------------------

function(input, output) {
  
  ## csv geocoding
  # file import
  imported_file <- callModule(csvUpload, "imported_file")
  # datatable
  displayed_table <- callModule(csvDatatable, "displayed_table", reactive( imported_file() ))
  # addresses correction
  correction_table <- callModule(csvCorrection, "correction_table", reactive( displayed_table() ))
  # map
  callModule(csvMap, "results_map", data_brut = reactive( imported_file() ), data_corr = reactive( correction_table() ))
  
  ## manual geocoding
  callModule(manualGeocoding, "manual_geocoding")
  
}
