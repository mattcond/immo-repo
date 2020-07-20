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
  regioni_attive <- readLines('../data/regioni-attive.txt')
  immo_data <- fread('../data/immo_data_2020-07-16 20:36:25.447691.csv') %>% 
    filter(regione %in% regioni_attive)

  mappa_annunci_prx <- leafletProxy('mappa_annunci')
  #variabili per la sessione attuale
  
  session_variable <- reactiveValues('regioni_province_comuni_df'= immo_data %>% select(regione, provincia, comune) %>% distinct,
                                     'lista_regioni' = immo_data %>% pull(regione) %>% unique,
                                     'area_geografica_selezionata' = list('regione'=NULL,'provincia'=NULL, 'comuni'=NULL), 
                                     'annunci_selezionati' = NULL, 
                                     'affitto' = 0, 
                                     'reset_ricerca' = T)
  
  isolate({
    output$mappa_annunci <- renderLeaflet({leaflet()})
    showModal(ricerca_modal(session_variable$lista_regioni))
  })
  
  ### gestione del modale
  
  # ---> Update del campo provincia
  
  observeEvent(input$regione, {
    session_variable$area_geografica_selezionata$regione <- input$regione
    lista_province <- session_variable$regioni_province_comuni_df %>% 
      filter(regione == session_variable$area_geografica_selezionata$regione) %>% 
      pull(provincia) %>% 
      unique %>% 
      sort
    
    updatePickerInput(session, inputId = 'provincia', choices = lista_province)
  })
  
  # ---> Update del campo comune
  
  observeEvent(input$provincia, {
    session_variable$area_geografica_selezionata$provincia <- input$provincia
    lista_comuni <- session_variable$regioni_province_comuni_df %>% 
      filter(provincia == session_variable$area_geografica_selezionata$provincia) %>% 
      pull(comune) %>% 
      unique %>% 
      sort
    
    updatePickerInput(session, inputId = 'comuni', choices = lista_comuni)
  })
  
  # ----> Aggiorno la session_variable relativa al comune
  
  observeEvent(input$comuni, {
    session_variable$area_geografica_selezionata$comuni <- input$comuni %>% sort
  })
  
  
  observeEvent(input$ricerca, {
    session_variable$affitto <- ifelse(input$affitto_vendita == 'Affitto', 1, 0) 
    
    print(session_variable$affitto)
    print(input$affitto_vendita)
    
    session_variable$annunci_selezionati <- immo_data %>%
      filter(regione == session_variable$area_geografica_selezionata$regione, 
             provincia == session_variable$area_geografica_selezionata$provincia, 
             comune %in% session_variable$area_geografica_selezionata$comuni, 
             affitto == session_variable$affitto)
    
    mean_lat <- session_variable$annunci_selezionati$latitudine %>% mean
    mean_lng <- session_variable$annunci_selezionati$longitudine %>% mean
    
    mappa_annunci_prx %>%
      clearMarkers() %>%
      addTiles() %>%
      setView(lat = mean_lat, lng = mean_lng, zoom = 8) %>% 
      addCircleMarkers(data = session_variable$annunci_selezionati, 
                  lat = ~latitudine, 
                 lng = ~longitudine)
    
    
    
    removeModal()
  })
  
  
  
  
  observeEvent(input$nuova_ricerca, {
    
    updatePickerInput(session, 'regione', selected = session_variable$area_geografica_selezionata$regione)
    updatePickerInput(session, 'provincia', selected = session_variable$area_geografica_selezionata$provincia)
    updatePickerInput(session, 'comuni', selected = session_variable$area_geografica_selezionata$comuni)
    
    updateRadioGroupButtons(session, 'affitto_vendita', 
                            selected = ifelse(session_variable$affitto == 1, 'Affitto', 'Vendita'))
    
    showModal(ricerca_modal(session_variable$lista_regioni, T))
  })
  
  
  
  
  
  
  
})
