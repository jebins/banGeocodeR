library(shiny)
library(htmlwidgets)
library(leaflet)

# données postales
laposte <- read.csv('data/codes_postaux_laposte.csv', sep = ',', stringsAsFactors = FALSE)
laposte[is.na(laposte)] <- "Tout"

# ShinyJS
jscode2 <- "
var postcode;
Shiny.addCustomMessageHandler('codePostalMessage', function(cdp) {
postcode = cdp;
});
var jsonFeature; // geojson
"


# UI ----------------------------------------------------------------------


correctionUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    tags$head(
      tags$script(HTML(jscode2))
    ),
    sidebarPanel(width = 3,
        # selectizeInput(ns("p1"), choices = laposte$Nom_commune, selected = NULL, 
        #                label = NULL, options = list(placeholder = "Commune", plugins = list('restore_on_backspace'))),
        selectizeInput(ns("p2"), choices = laposte$Code_postal, selected = NULL, 
                       label = NULL, options = list(placeholder = "Code postal", plugins = list('restore_on_backspace'))),
        selectizeInput(ns("p3"), choices = laposte$Ligne_5, selected = NULL, 
                       label = NULL, options = list(placeholder = "Ligne postale", plugins = list('restore_on_backspace'))),
        
        selectizeInput(ns('adresses'), label = NULL, choices = '', options = list(
          placeholder = 'Entrer un adresse',
          valueField = 'result_name',
          labelField = 'result_name',
          searchField = 'result_name',
          # sortField = 'result_score',
          sortField = I("[{field: 'result_score', direction: 'desc'}, {field: '$score'}]"),
          loadThrottle = '500',
          maxOptions = 5,
          plugins = list('restore_on_backspace'),
          # hors module :
          # onChange = I("
          #              function(value, $item) {
          #              var data = this.options[value];
          #              if (data) {
          #              jsonFeature = data
          #              }
          #              console.log(jsonFeature);
          #              Shiny.onInputChange('jsonFeature', jsonFeature); // envoi json vers R, à remplacer par vs discu
          #              }"),
          onChange = I(sprintf("
                       function(value, $item) {
                       var data = this.options[value];
                       if (data) {
                       jsonFeature = data
                       }
                       console.log(jsonFeature);
                       console.log('envoyé');
                       Shiny.onInputChange('%s', jsonFeature);}", ns("jsonFeature"))
                       ),
          
  #     onLoad = I("
  # function () {
  #   var self = this;
  #   $.each(self.options, function(key, value) {
  #     if(self.items.indexOf(key) == -1) {
  #       delete self.options[key];
  #     }
  #   });
  #   self.sifter.items = self.options;
  #   }"),
  #     onLoad = I("
  # function () {
  #   var self = this;
  #   $.each(self.options, function(key, value) {
  #     if(self.items.indexOf(key) == -1) {
  #       removeItem(value);
  #     }
  #   });
  #   }"),
          # onLoad = I("
          #           function() {
          #               console.log(this.options);
          #           }"),
          # supprime les données quand le champ est cliqué
          onFocus = I("
                      function() {
                      this.clearOptions();
                      }"),
          persist = FALSE,
          options = list(),
          create = FALSE,
          allowEmptyOption = FALSE,
          render = I("
                     {
                     option: function(item, escape) {
                     return '<div>' + '<strong>' + escape(item.result_name) + '</strong>' + '</div>';
                     }
                     }"  ),
          # non prise en compte du score (sans ordre)
          # score = I("
          #           function() {
          #           return function() {
          #               return 1;
          #           };
          #           }"),
          # non prise en compte du score (avec ordre)
          # score = I("
          #           function(search) {
          #           var score = this.getScoreFunction(search);
          #           return function(item) {
          #               return 1 + score(item);
          #           };
          #           }"),
  # solution moins acceptable (filtre les valeurs selon l'orthographe exacte) :
          # score = I("
          #           function(search) {
          #           var score = this.getScoreFunction(search);
          #           return function(item) {
          #           return score(item);
          #           };
          #           }"),
              
          load = I("
                   function(query, callback) {
                   if (!query.length) return callback();
                   $.ajax({
                   url: 'https://api-adresse.data.gouv.fr/search/?',
                   type: 'GET',
                   data: {
                   q: query,
                   postcode: postcode
                   },
                   dataType: 'json',
                   error: function() {
                   callback();
                   },
                   success: function (data) {

                   callback(data.features.map(function (item) {
                   return {result_name: item.properties.name, 
                   result_label: item.properties.label,
                   result_score: item.properties.score,
                   result_city: item.properties.city,
                   result_citycode: item.properties.citycode,
                   result_context: item.properties.context,
                   result_housenumber: item.properties.housenumber,
                   result_id: item.properties.id,
                   result_importance: item.properties.importance,
                   longitude: item.geometry.coordinates[0],
                   latitude: item.geometry.coordinates[1],
                   result_postcode: item.properties.postcode,
                   result_street: item.properties.street,
                   result_type: item.properties.type};
                   }));
                   }
                   });
                   }"
          )
          )),
          textInput(ns("commentaire_corr"), "Commentaire", placeholder = "Détails de la correction"),
          actionButton(ns("ajouterAdresseBtn"), "Corriger"),
          leafletOutput(ns("map"))#, height = "300px", width = "300px"),
          ),
  column(width = 9,
    DT::dataTableOutput(ns("tabcorrection"))
  )
    
  )
}



# SERVEUR -----------------------------------------------------------------


correctionModule <- function(input, output, session, data) {
  
  ns <- session$ns
  
  # valeurs réactives
  values <- reactiveValues()
  values$id_modif <- NULL
  
  observeEvent(data(), {
    values$adresses <- data()$df
  })
  
  # # champs d'adresse : code postal
  # observe({
  #   cdp <- laposte$Code_postal[laposte$Nom_commune == input$p1]
  #   updateSelectInput(session, "p2", "Code_postal", choices = unique(cdp))
  # })

  # champs d'adresse : ligne
  observe({
    lig <- laposte$Ligne_5[laposte$Code_postal == input$p2]
    if ( any(unique(lig) == 'Tout') ) {  # si ligne contient "Tout"
      selec <- 'Tout' # sélection par défaut vaut "Tout"
    } else {
      selec <- ''
    }
    updateSelectInput(session, "p3", "Ligne_5", choices = lig, selected = selec)
    session$sendCustomMessage("codePostalMessage", input$p2)  # message JS pour ajax : code postal
  })
  
  # boutton "ajouter"
  observe({
    shinyjs::toggleState("ajouterAdresseBtn", condition = (!is.null(input$tabcorrection_rows_selected)))
  })
  
  # adresse sélectionnée
  adresseSelec <- reactive({
    req(input$adresses)
    df <- values$adresseSelec
    df <- as.list(df)
    return(df)
  })
  
  observeEvent(input$jsonFeature, {
    # values$jsonFeature <- toJSON(input$jsonFeature)
    cat(file=stderr(), paste("JSON BAN valide"), "\n")
    values$adresseSelec <- input$jsonFeature
    cat(file=stderr(), paste(values$adresseSelec), "\n")
  })
  
  observe({
    updateSelectInput(session, "p2", "Code_postal", selected = values$adresses[input$tabcorrection_rows_selected, ]$V_codp, choices = NULL)
    updateSelectInput(session, "adresses", "adresse", selected = values$adresses[input$tabcorrection_rows_selected, ]$V_adres)
  })
  
  # ajouter adresse au df final
  observeEvent(input$ajouterAdresseBtn, {
    if (input$tabcorrection_rows_selected) {
      for (x in names(values$adresses) ) {
        for ( y in names(adresseSelec()) ) {
          if (x == y) {
            values$adresses[input$tabcorrection_rows_selected, x] <- adresseSelec()[y]
          }
        }
      }
    }
    values$adresses[input$tabcorrection_rows_selected, 'commentaire_correction'] <- input$commentaire_corr
    values$id_modif <- c(values$id_modif, values$adresses[input$tabcorrection_rows_selected, 'geocodID'])
    updateTextInput(session, 'commentaire_corr', label = 'Commentaire', value = '', placeholder = 'Détails de la correction')
    cat(file=stderr(), unlist(adresseSelec()), "\n")
    
  })
  
  
  test <- reactive({
    return(values$adresses)
  })


# datatable

  
  table <- reactive({
    
    datatable(test(),
              rownames = FALSE,
              style = 'bootstrap',
              class = 'table-bordered table-condensed table-striped',
              extensions = list('Buttons' = NULL),
              selection = list(mode = 'single', selected = NULL),
              options = list(pageLength = 15,
                             autoWidth = FALSE,
                             # scrollX = TRUE,
                             fixedHeader = FALSE,
                             dom = 'Btp', #lBfrtip
                             buttons = list(list(extend = 'collection',
                                                 buttons = c('csv', 'excel'),
                                                 text = 'Enregistrer'),
                                            I('colvis')
                             ),
                             searchHighlight = TRUE,
                             columnDefs = list(list(visible = FALSE, targets = data()$col_indices)),
                             language = list(url = '//cdn.datatables.net/plug-ins/1.10.13/i18n/French.json')
              )
    )
    
  })
  
  output$tabcorrection <- DT::renderDataTable({
    
    table()
    
  })
  
  # carte
  
  
  output$map <- renderLeaflet({
    
    leaflet() %>%
      addProviderTiles("CartoDB.Positron", 
                       group = "CartoDB", 
                       options = providerTileOptions(opacity = 1, minZoom = 0, maxZoom = 21)
      ) %>%
      addCircleMarkers(lng = adresseSelec()$longitude,
                       lat = adresseSelec()$latitude,
                       weight = 1, radius = 6, color = "darkgreen",
                       popup = paste0("QIDENT : ",
                                      as.character(adresseSelec()$ID),
                                      "<br/>", "result_label : ",
                                      as.character(adresseSelec()$result_label))
      ) %>%
      addCircleMarkers(lng =values$adresses[input$tabcorrection_rows_selected, ]$longitude,
                       lat =values$adresses[input$tabcorrection_rows_selected, ]$latitude,
                       weight = 1, radius = 6, color = "red",
                       popup = paste0("ID : ",
                                      as.character(values$adresses[input$tabcorrection_rows_selected, ]$ID),
                                      "<br/>", "result_label : ",
                                      as.character(values$adresses[input$tabcorrection_rows_selected, ]$result_label))
      )
  })
  
  reactive({
    return(list(df = test(), id_modif = values$id_modif))
  })
  
}