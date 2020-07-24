library(shiny)
library(shinyWidgets)
library(data.table)
library(dplyr)
library(leaflet)
library(leaflet.extras)
shinyUI(fluidPage(
  titlePanel("Immobiliare HDE"),
  
  sidebarLayout(
    sidebarPanel(width = 2,
                 actionButton('nuova_ricerca', 'Nuova ricerca', icon('search'), width = '100%')
                 ,hr()
                 ,h4('Aggiungi un comune')
                 ,selectInput('selezione_singola_comune', 
                              label = NULL, choices = c('Nessuna selezione'), 
                              selectize = T,
                              multiple = T)
                 ,radioButtons('ui_affitto_vendita', 
                               label = 'Contratto', 
                               choiceNames = c('Affitto', 'Vendita'), 
                               choiceValues = c(1,0), 
                               inline = T)
                 ),
    mainPanel(
      h3('Distribuzione territoriale degli immobili'),
      leafletOutput('mappa_annunci', height = 550, width = '100%')
    )
  )
))
