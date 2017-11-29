### banGeocodeR ###
### UI : main ###
### Copyright (C) 2017 Jérémy Commmins ###

# modules
source("modules/csvDatatableModule.R")
source("modules/csvUploadModule.R")
source("modules/csvMapModule.R")
source("modules/csvCorrectionModule.R")
source("modules/manualGeocodingModule.R")

# packages
library(shiny)
library(shinythemes)
library(shinyjs)
library(shinycssloaders)


# main UI function --------------------------------------------------------

shinyUI(
  
  navbarPage("banGeocodeR",
    # bootstrap theme
    theme = shinytheme("flatly"),
    useShinyjs(),
    tags$head(
      # custom CSS
      tags$style(HTML("
        /* navbar */
        .navbar {margin-bottom: 5px;}
        .navbar .navbar-nav {float: right;}
        .navbar .navbar-header {float: left;}
        /* nav-tabs */
        .nav-tabs {margin-bottom: 5px;}
        /* sidebar */
        .well {text-align: center;}
        /* datatable */
        table.dataTable th {background-color:#2C3E50; color:white;}
        table.dataTable tr.selected td, table.dataTable td.selected {background-color: pink !important;}
      "))
    ),
    
    # main tabs
    tabPanel("Géocodage CSV",
             
             tabsetPanel(
               
               tabPanel("Import des données",
                 fluidRow(
                   csvUploadUI("imported_file"),
                   csvDatatableUI("displayed_table")
                 )
               ),
               tabPanel("Correction des adresses",
                 fluidRow(
                   csvCorrectionUI("correction_table")
                 )
               ),
               tabPanel("Carte dynamique",
                 fluidRow(
                   csvMapUI("results_map")
                 )
               )
               
             )
    ),
    tabPanel("Géocodage manuel",
             fluidRow(
               manualGeocodingUI("manual_geocoding")
             )
    ),
    # about tab
    tabPanel("À propos",
             h1("banGeocodeR"),
             p("banGeocodeR est réalisé par l'UMR Espace-Dev (IRD, Univ. Guyane, Univ. Montpellier, Univ. Réunion) dans l'axe ESoR 
                (Environnement, Sociétés et Risques Sanitaires). L'application a initialement été développée pour les besoins du projet de recherche FOSFORE 
                coordonné par le Registre des Cancers (Dr. Emmanuel Chirpaz) du Centre Hospitalier Universitaire de La Réunion."),
             tags$ul(
               tags$li("Conception et développement : Jérémy Commins, Institut de Recherche pour le Développement (IRD) - UMR Espace-Dev."),
               tags$li("Conception : Vincent Herbreteau, Institut de Recherche pour le Développement (IRD) - UMR Espace-Dev.")
             ),
             tags$hr(),
             div(align = "center",
                 img(src="logos/logo_ird.png", align = "center"),
                 img(src="logos/logo_espacedev.jpg", align = "center"),
                 img(src="logos/logo_chu.png", align = "center")
                 )
             ),
    
    # default tab
    selected = "Géocodage CSV"
    
  )  # navbarPage
  
)  # shinyUI
