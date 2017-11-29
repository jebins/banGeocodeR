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
             p("banGeocodeR est une application R Shiny expérimentale, permettant de géocoder des adresses en France. 
             L'application utilise la Base Adresse Nationale, la base de données officielle des adresses françaises. 
             banGeocodeR a été développé dans le cadre d'un projet de recherche mené par le Centre Hospitalier Universitaire 
             de La Réunion et est pour l'instant limité à La Réunion."),
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
