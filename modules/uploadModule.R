### file import module ###

# input: a csv file with at least 2 columns :
# - postcodes
# - adresses
# output: a reactive list (see below)


library(shinyjs)
library(httr)
library(RCurl)


# UI function -------------------------------------------------------------

uploadModuleUI <- function(id) {
  # namespace
  ns <- NS(id)
  # UI elements
  tagList(
    sidebarPanel(width = 3,
      # input fields
      fileInput(ns("file"), "Sélectionner un fichier CSV"),
      textInput(ns("na.string"), "Champs vides", value = "NA"),
      # selectInput(ns("champ_commune"), label = "Champ du code INSEE", choices = '', selected = NULL),
      selectInput(ns("champ_code_postal"), label = "Champ du code postal *", choices = NULL, selected = NULL),
      selectInput(ns("champ_adresse"), label = "Champ d'adresse *", choices = NULL, selected = NULL),
      actionButton(ns("geocoder"), "Géocoder")
    )
  )
}


# server function ---------------------------------------------------------

uploadModule <- function(input, output, session) {
  
  # reactive values container
  values <- reactiveValues()
  
  # activate the geocoding button only if a file is imported
  observe({
    shinyjs::toggleState("geocoder", condition = (!is.null(values$df_import)))
  })
  
  ## file import ##
  observeEvent(input$file, {
    
    # imported data
    values$df_import <- read.csv(input$file$datapath,
                                 stringsAsFactors = FALSE,
                                 na.string = input$na.string)
    # reset the BAN dataframe
    values$df_ban <-  NULL
    
    # reactive values that will contain the column indexes of the
    # score and of the columns to hide
    values$df_columns_index <- list(
      score = NULL,
      invisible = NULL
    )
    
    # populate the sidebar fields with the dataframe columns
    updateSelectInput(session, 
                      "champ_commune", 
                      label = "Champ du code INSEE", 
                      choices = names(values$df_import),
                      selected = '')
    
    updateSelectInput(session, 
                      "champ_code_postal", 
                      label = "Champ du code postal *", 
                      choices = names(values$df_import),
                      selected = NULL)
    
    updateSelectInput(session, 
                      "champ_adresse", 
                      label = "Champ d'adresse *", 
                      choices = names(values$df_import),
                      selected = NULL)
    
    # print to console
    cat(file=stderr(), "File imported:", input$file$datapath, "\n")
    
  })
  
  ## geocoding ##
  observeEvent(input$geocoder, {
    
    # send the input file to the BAN API and the result
    cat(file=stderr(), "Geocoding", "\n")
    queryResults <- POST("http://api-adresse.data.gouv.fr/search/csv/",
                         body=list(data=upload_file(input$file$datapath,
                                                    type = "text/csv; charset=UTF-8"
                         ),
                         columns = input$champ_adresse,
                         postcode = input$champ_code_postal
                         )
    )
    # the dataframe is returned with new columns
    values$df_ban <- as.data.frame(content(queryResults), header = TRUE)
    
    # create a unique ID for each row
    values$df_ban['geocodID'] <- seq(1:nrow(values$df_ban))
    
    
    ## get information about the dataframe columns ##
    # this will be useful for the dataframe formatting (in the dataframeModule)
    
    # addresse and postcode columns indexes (input fields)
    indices_cdp_adr <- list(
      grep( paste("^", input$champ_code_postal, "$" , sep="", collapse=""), names(values$df_ban)) - 1,
      grep( paste("^", input$champ_adresse, "$", sep="", collapse=""), names(values$df_ban)) - 1
    )
    cat(file=stderr(), "Postcode and addresse column indexes:", paste(indices_cdp_adr), "\n")
    
    # BAN columns to show
    colonnes_ban_noms <- c("result_label", "result_type", "result_score")
    colonnes_ban_indices <- lapply(colonnes_ban_noms, 
                                   function(x) {grep( paste("^", x, "$", sep="", collapse=""), names(values$df_ban)) - 1})
    
    # columns to show : both input fields and useful BAN columns
    colonnes_afficher <- append(indices_cdp_adr, as.numeric(unlist(colonnes_ban_indices)))
    
    # columns to hide : the remaining
    colonnes_pas_afficher <- setdiff(2:length(values$df_ban)-1, colonnes_afficher)
    
    # result_score column
    score <- grep("^result_score$", names(values$df_ban)) - 1
    
    # reactive value containing the column indexes
    values$df_columns_index <- list(
      score = score,
      invisible = colonnes_pas_afficher
    )
    cat(file=stderr(), "Hidden columns:", paste(values$df_columns_index$invisible), "\n")
  })
  
  ## reactive output ##
  # a named list containing :
  #   - df : a dataframe  
  #   - geocode : the "geocoding switch" (True if the geocoding happened, else False), useful in the next modules
  #   - df_columns_index : the column indexes to hide by default
  
  reactive({
    # if the BAN dataframe exists : geocode is True, else False
    if ( is.null(values$df_ban) ) {
      return(list(df = values$df_import, geocode = FALSE, col_indices = values$df_columns_index))
    } else {
      return(list(df = values$df_ban, geocode = TRUE, col_indices = values$df_columns_index))
    }
  })
  
}