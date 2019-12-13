library(shiny)
library(bnf)
library(tidyverse)

ui <- bootstrapPage(
  actionButton('generate', 'Generate Code!'),
  textOutput('code'),
  tabsetPanel(
    tabPanel("Tile plot", plotOutput('plotgrid')),
    tabPanel("Path plot", plotOutput('plotpath')
    )
  )

)

