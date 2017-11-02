### map module ###
# input : 
# - geocoded dataframe (importModule)
# - edited rows (correctionModule)

library(leaflet)
library(plyr)


# UI function -------------------------------------------------------------

csvMapUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    downloadButton(ns("enregistrer"), "Enregistrer les données"),
    leafletOutput(ns("map"))
  )
}


# server function ---------------------------------------------------------

csvMap <- function(input, output, session, data_brut, data_corr) {
  
  ## reactive dataframe : ##
  # - if rows were edited in the correction module : (orginal df - rows edited) + rows edited
  # - else : original df
  data_all <- reactive({
    if ( !is.null(data_corr()$id_modif) ) {
      df1 <- data_brut()$df[-data_corr()$df$geocodID, ]
      df2 <- data_corr()$df
      return(rbind.fill(df1, df2))
    } else {
      return(data_brut()$df)
    }
  })
  
  ## download data ##
  output$enregistrer <- downloadHandler(
    filename = function() {
      paste("geocoded", ".csv", sep = "")
    },
    content = function(file) {
      write.csv(data_all(), file, row.names = FALSE)
    }
  )
  
  ## map rendering ##
  # input : the reactive dataframe
  output$map <- renderLeaflet({
    
    if (data_brut()$geocode) {
      
      leaflet() %>%
        addProviderTiles("CartoDB.Positron", 
                         group = "CartoDB", 
                         options = providerTileOptions(opacity = 1, minZoom = 0, maxZoom = 21)
        ) %>%
        addCircleMarkers(lng = data_all()$longitude,
                         lat = data_all()$latitude,
                         weight = 1, radius = 4,
                         popup = paste0("QIDENT : ",
                                        as.character(data_all()$V_adres),
                                        "<br/>", "V_adres : ",
                                        as.character(data_all()$result_label))
        )
      
    } else {
      NULL
    }
  })
}