# modules Shiny
source("modules/DTModule.R")
source("modules/uploadModule.R")
source("modules/leafletModule.R")
source("modules/correctionModule.R")
source("modules/manuelModule.R")

library(shiny)
library(shinythemes)
library(shinyjs)
library(shinycssloaders)

shinyUI(
  navbarPage(
    "Géocodeur BAN",
    theme = shinytheme("flatly"),
    tags$head(
      tags$style(HTML("
        /* navbar */
        .navbar {margin-bottom: 5px;}
        .navbar .navbar-nav {float: right;}
        .navbar .navbar-header {float: left;}
        /* nav-tabs */
        .nav-tabs {margin-bottom: 5px;}
        /* nav-tabs */
        .well {text-align: center;}
        /* datatable */
        table.dataTable th {background-color:#2C3E50; color:white;}
        table.dataTable tr.selected td, table.dataTable td.selected {background-color: pink !important;}
      "))
    ),
    selected = "Géocodage CSV",  # tab par défaut
    tabPanel("Géocodage CSV",
             tabsetPanel(
               tabPanel(
                 "Import des données",
                 fluidRow(
                   uploadModuleUI("datafile"),
                   DTtableUI("tabimport")
                 )
               ),
               tabPanel(
                 "Correction des adresses",
                 fluidRow(
                   correctionUI("tabcorrection")
                 )
               ),
               tabPanel(
                 "Carte dynamique",
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
    tabPanel("À propos")
  )
)
