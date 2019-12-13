library(shiny)
library(bnf)

function(input, output) {

  # code <- ""
  code <- reactive({
    input$generate
    bnf_expression(simple$expr, simple, 1, 1)
  })

  output$code <- renderText(code())

  dat_path <- reactive({
    fun <- bnf_function(code())
    dat_path <- bnf::dat_generation_path(fun, 5, 1, 50)
  })

  dat_grid <- reactive({
    fun <- bnf_function(code())
    dat_path <- bnf::dat_generation_grid(fun, 100,0.5, 100, 0.5)
  })

  output$plotpath <- renderPlot({
    ggplot(dat_path(), aes(x, y)) +
      geom_path() +
      theme_void()
  })

  output$plotgrid <- renderPlot({
    ggplot(dat_grid(), aes(x, y)) +
      geom_tile(aes(fill = log(z))) +
      theme_void()
  })
  #
  # output$plotpath

}
