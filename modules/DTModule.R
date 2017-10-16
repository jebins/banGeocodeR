library(DT)
library(RColorBrewer)

DTtableUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    column(width = 9,
           withSpinner(color="#0dc5c1", DT::dataTableOutput(ns('table')))
    )
  )
}

# serveur
DTtable <- function(input, output, session, data) {
  
  # pré-sélection des lignes
  selection <- reactive({
    if ( data()$geocode ) {
      return(list(mode = 'multiple', selected = which(data()$df$result_score < 0.59 | is.na(data()$df$result_score))))
    } else {
      return(list(mode = 'multiple', selected = NULL)) # À MODIFIER APRÈS TESTS (SINGLE)
    }
  })
  
  # observeEvent(input$table_rows_selected, {
  #   cat(file=stderr(), paste(input$table_rows_selected), "\n")
  # })
  
  table <- reactive({
    
    datatable(data()$df,
              rownames = FALSE,
              style = 'bootstrap',
              class = 'table-bordered table-condensed table-striped',
              extensions = list('Buttons' = NULL),
              selection = selection(),
              options = list(pageLength = 15,
                             autoWidth = FALSE,
                             # scrollX = TRUE,
                             fixedHeader = FALSE,
                             dom = 'lfBrtip', #lsp
                             buttons = list(list(extend = 'collection',
                                                 buttons = c('csv', 'excel'),
                                                 text = 'Enregistrer'),
                                            I('colvis')
                             ),
                             searchHighlight = TRUE,
                             columnDefs = list(list(visible = FALSE, targets = data()$col_indices$invisible )),
                             language = list(url = '//cdn.datatables.net/plug-ins/1.10.13/i18n/French.json')
              )
    )
    
  })
  
  output$table <- DT::renderDataTable({
    
    # formattage colonne result_score
    if (data()$geocode) {

      brks <- quantile(data()$df$result_score, probs = seq(0.1, 0.9, 0.1), na.rm = TRUE)
      clrs <- brewer.pal(10, "RdYlGn")
      
      table() %>%
        formatStyle(
          'result_score',
          backgroundColor = styleInterval(brks, clrs)
        ) %>%
        formatStyle(
          'result_type',
          color = styleEqual(c("housenumber", "street", "locality"), c('green', 'darkorange', 'red')),
          fontWeight = 'bold'
          # backgroundColor = styleInterval(3.4, c('gray', 'yellow'))
        )
      
    } else {
      table()
    }
    
  })
  
  # tableau sélectionné en sortie + colonnes cachées
  reactive({
    
    return(list( df = data()$df[input$table_rows_selected, ], col_indices = data()$col_indices$invisible))
    
  })
  
}