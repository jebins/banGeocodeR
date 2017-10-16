library(shiny)
library(htmlwidgets)
library(leaflet)


jscode <- "
shinyjs.init = function () {
    Split(['#a', '#b'], {
        direction: 'horizontal',
        sizes: [75, 25],
        gutterSize: 8,
        cursor: 'col-resize'
    })

    Split(['#c', '#d'], {
        direction: 'vertical',
        minSize: 200,
        sizes: [25, 75],
        gutterSize: 5,
        cursor: 'row-resize'
    })

    Split(['#e', '#f'], {
        direction: 'vertical',
        minSize: 200,
        sizes: [25, 75],
        gutterSize: 5,
        cursor: 'row-resize'
    })
}"


# UI ----------------------------------------------------------------------


manuelUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    tags$head(
      # tags$script(HTML(jscode)),
      includeScript("./www/split.min.js"),
      tags$style(HTML("
  /* navbar */
  .shiny-flow-layout {
  background: #2C3E50;
  height: 80px;
  }
  . {
  vertical-align: middle;
  }

  /* splitter */
 .split {
     overflow-y: auto;
     overflow-x: hidden;
 }

 .content {
     border: 1px solid #2C3E50;
     box-shadow: inset 0 1px 2px #e4e4e4;
     background-color: #fff;
     height:200px;
 }

 .gutter.gutter-horizontal {
     cursor: col-resize;
 }

 .gutter.gutter-vertical {
     cursor: row-resize;
 }

 .split.split-horizontal,
 .gutter.gutter-horizontal {
     height: 600px;
     float: left;
 }
                      "))
      ),
    

    # colonne : par défaut il y a un margin et padding

    # fluidRow(id = "haut", style = "position:relative; margin:auto; padding:auto; background-color: blue; text-align:center; height:50%;",
    # 
    #   column(width = 8, style = "background-color: black;",
    # 
    #          div(id = "lol1", "haut-haut-gauche", style = "background-color: green; height:100px"),
    #          # champs
    # 
    #          div(id = "lol2", "haut-bas-gauche", style = "background-color: lightgreen; height:100px")
    #          # tableau sélectionné
    #   ),
    #   column(width = 4, style = "padding:0;",
    # 
    #          div("haut-droit", style = "background-color: yellow; height:200px;")
    #          # carte sélectionnée
    #          )
    # ),
    # fluidRow(id = "bas", style = "margin:auto; padding:auto; background-color: lightblue; text-align:center; height:50%;",
    # # 
    #          column(width = 8, style = "margin:auto; padding:0;",
    # # 
    #                 div(id = "lol3", "bas-gauche", style = "background-color: red; height:100px"),
    # #                 tableau final
    # #          ),
    #          column(id = "lol4", width = 4, style = "margin:auto; padding:0;",
    # 
    #                 div("bas-droit", style = "background-color: orange; height:100px")
    #                 # carte finale
    #          )
    # )
    
    div(id="a", class="split split-horizontal",
      div(id="c", class="split content"),
      div(id="d", class="split content")
    ),

    div(id="b", class="split split-horizontal",
      div(id="e", class="split content"),
      div(id="f", class="split content")
    )
    
    )
    
  # )
}



# SERVEUR -----------------------------------------------------------------


manuelModule <- function(input, output, session, data) {
  
  ns <- session$ns
  
}
