ricerca_modal <- function(lista_regioni, ec = F) {modalDialog(
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
               choices = lista_regioni,
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
               inputId = "comuni",
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
  
  immo_data <- fread('../data/immo_data_2020-07-16 20:36:25.447691.csv')
  
  #variabili per la sessione attuale
  
  session_variable <- reactiveValues('regioni_province_comuni_df'= immo_data %>% select(regione, provincia, comune) %>% distinct,
                                     'lista_regioni' = immo_data %>% pull(regione) %>% unique,
                                     'area_geografica_selezionata' = list('regione'=NULL,'provincia'=NULL, 'comuni'=NULL))
  
  isolate({
    showModal(ricerca_modal(session_variable$lista_regioni))
  })
  
  ### gestione del modale
  
  # ---> Update del campo provincia
  
  observeEvent(input$regione, {
    session_variable$area_geografica_selezionata$regione <- input$regione
    lista_province <- session_variable$regioni_province_comuni_df %>% 
      filter(regione == session_variable$area_geografica_selezionata$regione) %>% 
      pull(provincia) %>% 
      unique
    
    updatePickerInput(session, inputId = 'provincia', choices = lista_province)
  })
  
  # ---> Update del campo comune
  
  observeEvent(input$provincia, {
    session_variable$area_geografica_selezionata$provincia <- input$provincia
    lista_comuni <- session_variable$regioni_province_comuni_df %>% 
      filter(provincia == session_variable$area_geografica_selezionata$provincia) %>% 
      pull(comune) %>% 
      unique
    
    updatePickerInput(session, inputId = 'comuni', choices = lista_comuni)
  })
  
  # ----> Aggiorno la session_variable relativa al comune
  
  observeEvent(input$comuni, {
    session_variable$area_geografica_selezionata$comuni <- input$comuni
  })
  
  
  observeEvent(input$ricerca, {
    print(str(session_variable$area_geografica_selezionata))
    removeModal()
  })
  
  
  
  
  observeEvent(input$nuova_ricerca, {
    showModal(ricerca_modal(session_variable$lista_regioni, T))
  })
  
  
  
  
  
  
  
})
