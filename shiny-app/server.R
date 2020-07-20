ricerca_modal <- function(ec = F) {modalDialog(
  title = NULL, #'Esegui una ricerca', 
  footer = NULL, easyClose = ec,
  fluidPage(
    # ### riga 1: filtri con regione provincia e comune
    fluidRow(
      h4('Seleziona l\'area geografica'),
      column(width = 4
             ,pickerInput(
               inputId = "regione",
               label = NULL, 
               choices = c('aa', 'aaaa', 'aaaaaa'),
               options = list(
                 'live-search' = TRUE, 
                 'title' = "Regione")
             )
      ),
      column(width = 4
             ,pickerInput(
               inputId = "provincia",
               label = NULL, 
               choices = c('aa', 'aaaa', 'aaaaaa'),
               options = list(
                 'live-search' = TRUE,
                 'title' = "Provincia")
             )
      ),
      column(width = 4
             ,pickerInput(
               inputId = "comune",
               label = NULL, 
               choices = c('aa', 'aaaa', 'aaaaaa'),
               options = list(
                 'live-search' = TRUE,
                 'title' = "Comuni"),
               multiple = T
             )
      )
    ),
    ### END ###
    
    # #### Seconda riga: radio button, e tasto cerca
    fluidRow(
      h4('Scegli il tipo di contratto e ricerca'),
      column(width = 8, 
             
             
             radioGroupButtons(
               inputId = "affitto_vendita",
               label = NULL,#"Affitto o vendita?",
               choices = c("Affitto", "Vendita"),
               justified = TRUE,
               selected = "Vendita",
               checkIcon = list(
                 yes = tags$i(class = "fa fa-circle", 
                              style = "color: steelblue"),
                 no = tags$i(class = "fa fa-circle-o", 
                             style = "color: steelblue"))
             )
             
      ), 
      column(width = 4,
             actionBttn(
               'ricerca',
               'Cerca',
               style = "bordered",
               color = 'primary',block = T
             )
      )
    )
    ### END ###
  )
)
}

shinyServer(function(input, output, session){
  ### Modale per nuoova ricerca
  
  #immo_data <- fread('../data/immo_data_2020-07-16 20:36:25.447691.csv')
  
  #session_variable
  
  
  isolate({
    showModal(ricerca_modal())
  })
  
  observeEvent(input$nuova_ricerca, {
    showModal(ricerca_modal(T))
  })
  
  observeEvent(input$ricerca, {
    removeModal()
  })
  
  
  
  
  
})
