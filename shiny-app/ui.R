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
                 #,sliderInput('prezzo', 'Prezzo', 0, )
                 ),
    mainPanel(
      h3('Distribuzione territoriale degli immobili'),
      leafletOutput('mappa_annunci')
    )
  )
))
