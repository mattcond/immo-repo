library(shiny)
library(shinyWidgets)
library(data.table)
library(dplyr)
shinyUI(fluidPage(
  titlePanel("Immobiliare HDE"),
  
  sidebarLayout(
    sidebarPanel(width = 2
                 ,actionButton('nuova_ricerca', 'Nuova ricerca', icon('search'), width = '100%')
                 ,hr()
                 #,sliderInput('prezzo', 'Prezzo', 0, )
                 ),
    mainPanel("main panel")
  )
))