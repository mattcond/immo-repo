library(shiny)
library(shinyWidgets)
library(data.table)
library(dplyr)
library(leaflet)
library(leaflet.extras)
shinyUI(fluidPage(
  titlePanel("Immobiliare HDE"),
  
  sidebarLayout(
    sidebarPanel(width = 2
                 ,actionButton('nuova_ricerca', 'Nuova ricerca', icon('search'), width = '100%')
                 ,hr()
                 ,h4('Aggiungi un comune')
                 ,selectInput('selezione_singola_comune', 
                              label = NULL, choices = c('Nessuna selezione'), 
                              selectize = T,
                              multiple = T)
                 ,switchInput('ui_affitto_vendita', 
                              onLabel = 'Affitto', 
                              offLabel = 'Vendita',
                              offStatus = 'warning',
                              value = F, 
                              label = 'Contratto', 
                              width = '100%')
                 
                 
                 # ,pickerInput(
                 #   inputId = "selezione_singola_comune",
                 #   label = NULL,
                 #   choices = c(NA),
                 #   options = list(
                 #     'live-search' = TRUE,
                 #     'title' = "Comune")
                 # )
                 #,actionButton('add_comune', 'Aggiungi', icon('plus'), width = '100%')
                 #,sliderInput('prezzo', 'Prezzo', 0, )
                 ),
    mainPanel(
      h3('Distribuzione territoriale degli immobili'),
      leafletOutput('mappa_annunci', height = 550, width = '100%')
    )
  )
))
