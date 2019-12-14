

ui <- bootstrapPage(
  column(
    width = 3,
    h2("Adjust the code generation parameters"),
    shiny::sliderInput('xmax', label = 'Max X'     , min =  1, max =   50, value = 5, ticks = FALSE),
    shiny::sliderInput('res' , label = 'Resolution', min = 10, max =  200, value = 100, ticks = FALSE),
    shiny::sliderInput('lambda0p' , label = 'lambda (0 or more)', min = 0.1, max = 2.0, value = 0.5, ticks = FALSE),
    shiny::sliderInput('lambda1p' , label = 'lambda (1 or more)', min = 0.1, max = 2.0, value = 0.5, ticks = FALSE),
    shiny::checkboxInput('log', 'Log?', value = TRUE),
    actionButton('generate', 'Generate Code!', icon("paper-plane"),
                 style="color: #fff; background-color: #337ab7; border-color: #2e6da4")
  ),
  column(
    width = 9,
    h3("Grammar"),
    pre(bnf:::simple_bnf_with_functions),
    h3("Generated Code"),
    textOutput('code'),
    h3("Graphical Output"),
    plotOutput('plotgrid')
  )
)

