### dataframe diplaying module ###
# input: the reactive output of importModule : a dataframe
# output: a reactive list (see below)


library(DT)
library(RColorBrewer)


# UI function -------------------------------------------------------------

csvDatatableUI <- function(id) {
  ns <- NS(id)
  tagList(
    column(width = 9,
           withSpinner(color="#0dc5c1", DT::dataTableOutput(ns("table")))
    )
  )
}


# server function ---------------------------------------------------------

csvDatatable <- function(input, output, session, data) {
  
  # select addresses with a result_score < 0.6 by default
  selection <- reactive({
    if ( data()$geocode ) {
      return(list(mode = "multiple", selected = which(data()$df$result_score < 0.6 | is.na(data()$df$result_score))))
    } else {
      return(list(mode = "none", selected = NULL))
    }
  })
  
  ## datatable ##
  table <- reactive({
    
    datatable(data()$df,
              rownames = FALSE,
              style = "bootstrap",
              class = "table-bordered table-condensed table-striped",
              extensions = list("Buttons" = NULL),
              selection = selection(),
              options = list(pageLength = 15,
                             autoWidth = FALSE,
                             fixedHeader = FALSE,
                             dom = "lfBrtip",
                             buttons = list(list(extend = "collection",
                                                 buttons = c("csv", "excel"),
                                                 text = "Enregistrer"),
                                            I("colvis")
                             ),
                             searchHighlight = TRUE,
                             columnDefs = list(list(visible = FALSE, targets = data()$col_indices$invisible )),
                             # french internationalization
                             language = list(url = "//cdn.datatables.net/plug-ins/1.10.13/i18n/French.json")
              )
    )
    
  })
  
  output$table <- DT::renderDataTable({
    
    ## result_score column formatting ##
    # only if the dataframe was geocoded
    if (data()$geocode) {

      brks <- quantile(data()$df$result_score, probs = seq(0.1, 0.9, 0.1), na.rm = TRUE)
      clrs <- brewer.pal(10, "RdYlGn")
      
      table() %>%
        formatStyle(
          "result_score",
          backgroundColor = styleInterval(brks, clrs)
        ) %>%
        formatStyle(
          "result_type",
          color = styleEqual(c("housenumber", "street", "locality"), c("green", "darkorange", "red")),
          fontWeight = "bold"
          # backgroundColor = styleInterval(3.4, c("gray", "yellow"))
        )
      
    } else {
      table()
    }
    
  })
  
  ## reactive output ##
  # df : dataframe containing the selected rows
  # col_indices : 
  reactive({
    return(list( df = data()$df[input$table_rows_selected, ], col_indices = data()$col_indices$invisible))
  })
  
}