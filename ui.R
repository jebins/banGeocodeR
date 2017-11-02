### geocodeR ###
### UI main ###
### Copyright (C) 2017 Jérémy Commmins <jebins@openaliasbox.org> ###

# modules
source("modules/DTModule.R")
source("modules/uploadModule.R")
source("modules/leafletModule.R")
source("modules/correctionModule.R")
source("modules/manuelModule.R")

# packages
library(shiny)
library(shinythemes)
library(shinyjs)
library(shinycssloaders)


# main UI function --------------------------------------------------------

shinyUI(
  
  navbarPage("Géocodeur BAN",
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
                   uploadModuleUI("datafile"),
                   DTtableUI("tabimport")
                 )
               ),
               tabPanel("Correction des adresses",
                 fluidRow(
                   correctionUI("tabcorrection")
                 )
               ),
               tabPanel("Carte dynamique",
                 fluidRow(
                   leafletModuleUI("carte_csv")
                 )
               )
               
             )
    ),
    tabPanel("Géocodage manuel",
             
             fluidRow(
               manuelUI("tabmanuel")
             )
    ),
    tabPanel("À propos"),
    
    # default tab
    selected = "Géocodage CSV"
    
  )  # navbarPage
  
)  # shinyUI
