# Module d'import d'un fichier
library(shinyjs)
library(httr)
library(RCurl)

uploadModuleUI <- function(id) {
  ns <- NS(id)
  
  # éléments de l'UI
  tagList(
    sidebarPanel(align = "center",
      shinyjs::useShinyjs(),
      width = 3,  
      fileInput(ns("file"), "Sélectionner un fichier CSV"),
      textInput(ns("na.string"), "Champs vides", value = "NA"),
      selectInput(ns("champ_commune"), label = "Champ du code INSEE", choices = '', selected = NULL),
      selectInput(ns("champ_code_postal"), label = "Champ du code postal *", choices = NULL, selected = NULL),
      selectInput(ns("champ_adresse"), label = "Champ d'adresse *", choices = NULL, selected = NULL),
      actionButton(ns("geocoder"), "Géocoder")
    )
  )
}


# Fonction serveur
uploadModule <- function(input, output, session) {
  
  # valeurs réactives
  values <- reactiveValues()
  
  observeEvent(input$file, {
    values$df_import <- read.csv(input$file$datapath,
                                 stringsAsFactors = FALSE,
                                 na.string = input$na.string)
    values$df_ban <-  NULL
    
    values$df_columns_index <- list(
      score = NULL,
      invisible = NULL
    )
    cat(file=stderr(), "upload_visible_file", paste(values$df_columns_index$invisible), "\n")
    cat(file=stderr(), "upload_score_file", paste(values$df_columns_index$score), "\n")
    
    # mise à jour des champs
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
  })
  
  # désactiver bouton "géocoder" si aucun fichier importé
  observe({
    shinyjs::toggleState("geocoder", condition = (!is.null(values$df_import)))
  })
  
  ### géocodage
  observeEvent(input$geocoder, {
    
    ## envoi à la BAN
    cat(file=stderr(), "requête BAN", "\n")
    queryResults <- POST("http://api-adresse.data.gouv.fr/search/csv/",
                         body=list(data=upload_file(input$file$datapath,
                                                    type = "text/csv; charset=UTF-8"
                         ),
                         columns = input$champ_adresse,
                         postcode = input$champ_code_postal
                         )
    )
    values$df_ban <- as.data.frame(content(queryResults), header = TRUE)
    values$df_ban['geocodID'] <- seq(1:nrow(values$df_ban))
    # colonne checkbox, avec valeurs par défaut
    # values$df_ban <- cbind(corriger = ifelse(values$df_ban$result_score < 0.59 | is.na(values$df_ban$result_score), TRUE, FALSE), values$df_ban)
    
    ## infos sur le tableau pour sa mise-en-forme
    # indices des colonnes "code postal" et "adresse"
    indices_cdp_adr <- list(
      grep( paste("^", input$champ_code_postal, "$" , sep="", collapse=""), names(values$df_ban)) - 1,
      grep( paste("^", input$champ_adresse, "$", sep="", collapse=""), names(values$df_ban)) - 1
    )
    cat(file=stderr(), "upload_indices_champs", paste(indices_cdp_adr), "\n")
    
    # indices des colonnes BAN utiles
    colonnes_ban_noms <- c("result_label", "result_type", "result_score")
    colonnes_ban_indices <- lapply(colonnes_ban_noms, 
                                   function(x) {grep( paste("^", x, "$", sep="", collapse=""), names(values$df_ban)) - 1})
    
    # colonnes à afficher : (champs + BAN utile)
    colonnes_afficher <- append(indices_cdp_adr, as.numeric(unlist(colonnes_ban_indices)))
    cat(file=stderr(), "upload_affich", paste(colonnes_afficher), "\n")
    
    # colonnes à ne pas afficher : les autres
    colonnes_pas_afficher <- setdiff(2:length(values$df_ban)-1, colonnes_afficher)
    cat(file=stderr(), "upload_pasaffich", paste(colonnes_pas_afficher), "\n")
    
    # colonne result_score
    score <- grep("^result_score$", names(values$df_ban)) - 1
    cat(file=stderr(), "upload_score", paste(score), "\n")
    
    # retour des valeurs pour affichage d3tf
    values$df_columns_index <- list(
      # indice colonne "result_score"
      score = score,
      invisible = colonnes_pas_afficher
    )
    cat(file=stderr(), "upload_colinvisible", paste(values$df_columns_index$invisible), "\n")
    cat(file=stderr(), "type de values$df_columns_index$invisible :", paste(class(values$df_columns_index$invisible)), "\n")
  })
  
  reactive({
    if ( is.null(values$df_ban) ) {
      return(list(df = values$df_import, geocode = FALSE, col_indices = values$df_columns_index))
    } else {
      return(list(df = values$df_ban, geocode = TRUE, col_indices = values$df_columns_index))
    }
  })
  
}