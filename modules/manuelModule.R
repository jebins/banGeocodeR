library(htmlwidgets)
library(DT)
library(leaflet)

# données postales
laposte <- read.csv('data/codes_postaux_laposte.csv', sep = ',', stringsAsFactors = FALSE)
laposte[is.na(laposte)] <- "Tout"

# ShinyJS
# splitter
jscode <- "
shinyjs.init = function () {
    Split(['#tabmanuel', '#carte'], {
        direction: 'horizontal',
        sizes: [55, 45],
        gutterSize: 10,
        cursor: 'col-resize'
    })
}"


# UI ----------------------------------------------------------------------


manuelUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    tags$head(
      tags$script(HTML(jscode)),
      # boutton de suppression dans tableau
      tags$script(sprintf("
$(document).on('click', '#tabmanuel-tabmanuel button', function () {
 console.log('suppression ligne');
 Shiny.onInputChange('%s',this.id);
 Shiny.onInputChange('%s', Math.random())
 });", 
                  ns("lastClickId"), ns("lastClick"))),
      includeScript("./www/split.min.js"),
      tags$style(HTML("
  . {
     vertical-align: middle;
  }

  .left-top {
     width: 68%;
  }

  .left-top .shiny-input-panel {
     margin: 0px 5px 5px 5px;
     padding-right: 0px;
  }

  .right-top {
     width: 31%;
  }

  #tabmanuel-minimap {
     margin-right: 3px;
     height: 150px;
  }

  #carte {
     padding-top: 52px;
  }

  /* splitter */
 .split {
     overflow-y: auto;
     overflow-x: hidden;
 }

 .gutter.gutter-horizontal {
     cursor: col-resize;
     background-repeat: no-repeat;
     background-color: #eee;
     background-position: 50%;
     background-image: url('grips/vertical.png');
 }

 .split.split-horizontal,
 .gutter.gutter-horizontal {
     height: 500px;
     float: left;
 }
                      "))
      ),
    

    # colonne : par défaut il y a un margin et padding
    # ligne 1
    # fluidRow(id = "haut", style = "position:relative; margin:auto; padding:auto; background-color: blue; text-align:center; height:50%;",

      column(class = "left-top", width = 9, style = "margin:0; padding:0;",

             # tags$div(id = "champs", style = "background-color: green; height:150px",
                 
                 inputPanel(
                 # inputPanel(align = "center",
                            selectizeInput(ns("p1"), choices = laposte$Nom_commune, selected = NULL, 
                                           label = NULL, options = list(placeholder = "Commune")),
                            selectizeInput(ns("p2"), choices = laposte$Code_postal, selected = NULL, 
                                           label = NULL, options = list(placeholder = "Code postal", plugins = list('restore_on_backspace'))),
                            selectizeInput(ns("p3"), choices = laposte$Ligne_5, selected = NULL, 
                                           label = NULL, options = list(placeholder = "Ligne postale", plugins = list('restore_on_backspace'))),
                            
                            selectizeInput(ns('adresses'), label = NULL, choices = '', options = list(
                              placeholder = 'Entrer un adresse',
                              valueField = 'result_name',
                              labelField = 'result_name',
                              searchField = 'result_name',
                              sortField = I("[{field: 'result_score', direction: 'desc'}, {field: '$score'}]"),
                              loadThrottle = '500',
                              maxOptions = 5,
                              plugins = list('restore_on_backspace'),
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
                            )), # ~ adresses
                 textInput(ns("commentaire"), label = NULL, placeholder = "Commentaires"),
                 actionButton(ns("ajouterAdresseBtn"), "Ajouter")
                 
                 )
      ),
      column(class = "right-top", width = 3, style = "padding:0;",

             # tags$div(style = "height:50px;" ,
                       leafletOutput(ns("minimap"), height = "150px")
                       # )
      ),
    # ),
    # ligne 2
    # fluidRow(id = "bas", style = "margin:auto; padding:auto; background-color: lightblue; text-align:center; height:100%;",

             tags$div(id = "tabmanuel", class = "split", style = "height:500px; float:left;",
                    DT::dataTableOutput(ns("tabmanuel"), height = "100%", width = "100%")
             ),
          
             tags$div(id = "carte", class = "split", style = "height:500px; float:left;",
                    # carte finale
                    leafletOutput(ns("map"), height = "100%", width = "100%")
             )
    # )
  )
}



# SERVEUR -----------------------------------------------------------------


manuelModule <- function(input, output, session, data) {
  
  ns <- session$ns
  
  # valeurs réactives
  values <- reactiveValues()
  
  # créer un tableau vide
  values$adressesMan <- data.frame()
  
  # # champs d'adresse : code postal
  observe({
    cdp <- laposte$Code_postal[laposte$Nom_commune == input$p1]
    updateSelectInput(session, "p2", "Code_postal", choices = unique(cdp))
  })
  
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
    shinyjs::toggleState("ajouterAdresseBtn", condition = (!is.null(input$adresses)))
  })
  
  # JSON
  observeEvent(input$jsonFeature, {
    cat(file=stderr(), paste("reçuuuuu json !"), "\n")
    values$adresseSelec <- input$jsonFeature
    cat(file=stderr(), paste(values$adresseSelec), "\n")
  })
  
  # adresse sélectionnée
  adresseSelec <- reactive({
    req(input$adresses)
    df <- values$adresseSelec
    df <- as.list(df)
    return(df)
  })
  
  #### TABMANUEL ####
  
  # ajouter adresse au df final
  # boutton "ajouter"
  observe({
    shinyjs::toggleState("ajouterAdresseBtn", condition = (input$adresses != ""))
  })
  
  observeEvent(input$ajouterAdresseBtn, {
    values$adresseSelec['Commentaire'] <- paste(input$commentaire)
    values$adressesMan <- rbind( values$adressesMan, as.data.frame(values$adresseSelec))
    updateTextInput(session, 'commentaire', label = 'Commentaire', value = '', placeholder = 'Détails de la correction')
    updateSelectInput(session, "adresses", "adresse", selected = '')
    cat(file=stderr(), class(values$adressesMan), "\n")
    cat(file=stderr(), nrow(values$adressesMan), "\n")
    print(values$adressesMan)
  })
  
  tabmanuel_ <- reactive({
    df <- values$adressesMan
    if (!is.null(df) && nrow(df) > 0) {
      df['Actions'] <- paste0('
<div class="btn-group" role="group" aria-label="Basic example">
<button type="button" class="btn btn-secondary delete" id=delete_', 1:nrow(df), '>Supprimer</button>
</div>')
      return(df)
    } else {
      return(NULL)
    }
    
  })
  
  to_hide <- reactive({
    match( c( "result_score",
               "result_name",
               "result_city",
               "result_citycode",
               "result_context",
               "result_housenumber",
               "result_id",
               "result_name",
               "result_importance",
               "result_postcode",
               "result_street",
               "result_type",
               "X.order"
    ), names(tabmanuel_()) ) - 1
  })
  
  # supprimer ligne
  observeEvent(input$lastClick, {
    if (grepl("delete", input$lastClickId)) {
      row_to_del <- as.numeric(gsub("delete_", "", input$lastClickId))
      values$adressesMan <- values$adressesMan[-row_to_del,]
      cat(file=stderr(),"suppr", input$lastClickId,'\n')
    } 
  })
  
  table <- reactive({
    
    datatable(tabmanuel_(),
              rownames = FALSE,
              style = 'bootstrap',
              class = 'table-bordered table-condensed table-striped',
              extensions = list('Buttons' = NULL),
              selection = list(mode = 'single', selected = NULL),
              escape = FALSE,
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
                             columnDefs = list(list(visible = FALSE, targets = to_hide() )),
                             language = list(url = '//cdn.datatables.net/plug-ins/1.10.13/i18n/French.json')
              )
    )
  })
  
  output$tabmanuel <- DT::renderDataTable({
    table()
  })
  
  
  #### MINI CARTE ####
  
  output$minimap <- renderLeaflet({
    
    leaflet() %>%
      addProviderTiles("CartoDB.Positron", 
                       group = "CartoDB", 
                       options = providerTileOptions(opacity = 1, minZoom = 0, maxZoom = 21)
      ) %>%
      addCircleMarkers(lng = adresseSelec()$longitude,
                       lat = adresseSelec()$latitude,
                       weight = 1, radius = 5
      ) 
  })
  
  
  #### CARTE ####
  
  # proxies
  proxyTab <- dataTableProxy(ns('tabmanuel'), session = session)
  proxyMap <- leafletProxy(ns('map'), session = session)
  
  # clic marker -> selectionner ligne
  observeEvent(input$map_marker_click, {
    proxyTab %>% selectRows( which(tabmanuel_()$result_label == paste(input$map_marker_click)[1]) )
    # cat(file=stderr(),"clicked marker", input$map_marker_click[1],'\n')
  })
  
  observeEvent(input$tabmanuel_rows_selected, {
    cat(file=stderr(), input$tabmanuel_rows_selected, '\n')
  })
  
  # clic ligne -> zoomer marker
  observeEvent(input$tabmanuel_rows_selected, {
    proxyMap %>% setView(lng = tabmanuel_()[input$tabmanuel_rows_selected[1], "longitude"], lat = tabmanuel_()[input$tabmanuel_rows_selected, "latitude"], zoom = 15)
    # cat(file=stderr(),"clicked row", rowClic$clickedRow, '\n')
  })
    
  # style de la carte
  labels <- reactive({
    sprintf(
      "<h5>%s</h5>",
      tabmanuel_()$result_label
    ) %>% lapply(htmltools::HTML)
  })
  
  carte <- reactive({
    leaflet() %>%
      addProviderTiles("CartoDB.Positron", 
                       group = "CartoDB", 
                       options = providerTileOptions(opacity = 1, minZoom = 0, maxZoom = 21)
      ) %>%
      addCircleMarkers(lng = tabmanuel_()$longitude,
                       lat = tabmanuel_()$latitude,
                       layerId = tabmanuel_()$result_label,
                       label = labels(),
                       weight = 1, radius = 6
      ) 
  })
  
  output$map <- renderLeaflet({
    if ( !is.null(tabmanuel_())) {
      carte()
    }
  })
  
}