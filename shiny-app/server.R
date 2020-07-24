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

addCUstomCircleMarker <- function(prx, df){
  prx %>% 
  addCircleMarkers(data = df,
                   label = ~lab %>% lapply(HTML),
                   lat = ~noised_lat,
                   lng = ~noised_lng,
                   group = ~comune,
                   color = ~col,
                   radius = 5,
                   stroke = F,
                   fillOpacity = 1)
}


# VENDITA: #f0ad4e
# AFFITTO: #337ab7

shinyServer(function(input, output, session){
  ### Modale per nuoova ricerca
  regioni_attive <- readLines('../data/regioni-attive.txt')
  immo_data <- fread('../data/immo_data_20200723225910.csv') %>% 
    filter(regione %in% regioni_attive) %>% 
    mutate(lab = paste(titolo, indirizzo, affitto, sep = ',<br>'), 
           col = ifelse(affitto == 1, '#337ab7', '#f0ad4e'))
  
  ultimo_run <- immo_data %>% 
    group_by(regione, provincia, comune) %>% 
    summarise(run = max(data_run)) %>% 
    mutate(run = substr(run, 1,10))
  
  
  immo_data <- immo_data %>% 
    mutate(noise_lat = 0, 
           noise_lng = 0) %>% 
    mutate(noise_lat = lapply(noise_lat, function(x){return(x + rnorm(1, 0, 0.00007))}) %>% unlist,
           noise_lng = lapply(noise_lng, function(x){return(x + rnorm(1, 0, 0.00007))}) %>% unlist) %>% 
    mutate(noised_lat = latitudine + noise_lat, 
           noised_lng = longitudine + noise_lng)
  
  mappa_annunci_prx <- leafletProxy('mappa_annunci')
  #variabili per la sessione attuale
  
  session_variable <- reactiveValues('regioni_province_comuni_df'= immo_data %>% select(regione, provincia, comune) %>% distinct,
                                     'lista_regioni' = immo_data %>% pull(regione) %>% unique,
                                     'area_geografica_selezionata' = list('regione'=NULL,'provincia'=NULL, 'comuni'=NULL), 
                                     'lista_comuni' = NULL,
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
    session_variable$lista_comuni <- session_variable$regioni_province_comuni_df %>% 
      filter(provincia == session_variable$area_geografica_selezionata$provincia) %>% 
      pull(comune) %>% 
      unique %>% 
      sort
    
    updatePickerInput(session, inputId = 'comuni', choices = session_variable$lista_comuni)
  })
  
  # ----> Aggiorno la session_variable relativa al comune
  
  observeEvent(input$comuni, {
    session_variable$area_geografica_selezionata$comuni <- input$comuni %>% sort
  })
  
  # ----> Click sul tasto di ricerca
  observeEvent(input$ricerca, {
    session_variable$affitto <- ifelse(input$affitto_vendita == 'Affitto', 1, 0) 
    
    print(session_variable$affitto)
    print(input$affitto_vendita)
    
    session_variable$annunci_selezionati <- immo_data %>%
      filter(regione == session_variable$area_geografica_selezionata$regione, 
             provincia == session_variable$area_geografica_selezionata$provincia, 
             comune %in% session_variable$area_geografica_selezionata$comuni)
    
    updateSelectInput(session, 
                         'selezione_singola_comune', 
                         choices = session_variable$lista_comuni,
                         selected = session_variable$area_geografica_selezionata$comuni)
    
    mean_lat <- session_variable$annunci_selezionati$latitudine %>% mean
    mean_lng <- session_variable$annunci_selezionati$longitudine %>% mean
    
    mappa_annunci_prx %>%
      clearMarkers() %>%
      addTiles() %>%
      setView(lat = mean_lat, lng = mean_lng, zoom = 8)
    
    addCUstomCircleMarker(mappa_annunci_prx, 
                          session_variable$annunci_selezionati %>% 
                            filter(affitto == session_variable$affitto))
    
    updateRadioButtons(session, inputId = 'ui_affitto_vendita', selected = session_variable$affitto)
    
    removeModal()
  })
  
  # ----> aggiunta o rimozione di uno o più comuni
  
  observeEvent(input$selezione_singola_comune, {
    
    cat("===== MODIFICA COMUNE =====\n")
    
    cat('session_variable pre: ',session_variable$area_geografica_selezionata$comuni, '\n')
    
    cat('select_input:', input$selezione_singola_comune, '\n')
    
    comune_diff <- setdiff(input$selezione_singola_comune, session_variable$area_geografica_selezionata$comuni)
    to_remove <- setdiff(session_variable$area_geografica_selezionata$comuni, input$selezione_singola_comune)
    session_variable$area_geografica_selezionata$comuni <- input$selezione_singola_comune
    
    cat('session_variable post: ',session_variable$area_geografica_selezionata$comuni, '\n')
    
    session_variable$annunci_selezionati <- immo_data %>%
      filter(regione == session_variable$area_geografica_selezionata$regione, 
             provincia == session_variable$area_geografica_selezionata$provincia, 
             comune %in% session_variable$area_geografica_selezionata$comuni)
    
    mean_lat <- session_variable$annunci_selezionati$latitudine %>% mean
    mean_lng <- session_variable$annunci_selezionati$longitudine %>% mean
    
    if(length(comune_diff) > 0){
      cat('nuovo comune:', comune_diff, '\n')
      mappa_annunci_prx %>%
        addTiles() %>%
        setView(lat = mean_lat, lng = mean_lng, zoom = 10)
      
      addCUstomCircleMarker(mappa_annunci_prx, 
                            session_variable$annunci_selezionati %>% 
                              filter(comune == comune_diff, 
                                     affitto == session_variable$affitto))
      
    } 
    
    if(length(to_remove)>0){
      cat('rimosso un comune:', to_remove, '\n')
      mappa_annunci_prx %>%
        clearGroup(group = to_remove) 
    }
    
  })
  
  
  observeEvent(input$nuova_ricerca, {
    
    updatePickerInput(session, 'regione', selected = session_variable$area_geografica_selezionata$regione)
    updatePickerInput(session, 'provincia', selected = session_variable$area_geografica_selezionata$provincia)
    updatePickerInput(session, 'comuni', selected = session_variable$area_geografica_selezionata$comuni)
    
    updateRadioGroupButtons(session, 'affitto_vendita', 
                            selected = ifelse(session_variable$affitto == 1, 'Affitto', 'Vendita'))
    
    showModal(ricerca_modal(session_variable$lista_regioni, T))
  })
  
  
  observeEvent(input$ui_affitto_vendita, {
    
    if(!is.null(session_variable$annunci_selezionati)){
      
      session_variable$affitto <- as.integer(input$ui_affitto_vendita)
      
      mappa_annunci_prx %>%
        clearMarkers() 
      
      addCUstomCircleMarker(mappa_annunci_prx, 
                            session_variable$annunci_selezionati %>% 
                              filter(affitto == session_variable$affitto))
      
    }
  })
  
})
