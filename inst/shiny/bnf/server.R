

function(input, output) {

  code <- reactive({
    input$generate
    bnf::generate_code(
      bnf_spec  = spec,
      bnf_rule  = spec$Expr,
      lambda0p  = input$lambda0p,
      lambda1p  = input$lambda1p
    )
  })

  output$code <- renderText(code())

  dat_grid <- reactive({
    suppressWarnings({
      dat_path <- bnf::eval_grid(code(), xmin=0, xmax=input$xmax, xn = input$res)
    })
    dat_path
  })

  output$plotgrid <- renderPlot({
    plot_df <- dat_grid()

    if (isTRUE(input$log)) {
      plot_df$z <- suppressWarnings(log(plot_df$z))
    }

    ggplot(plot_df, aes(x, y)) +
      geom_tile(aes(fill = z)) +
      theme_void() +
      theme(legend.position = 'none') +
      scale_fill_viridis_c(na.value = '#440154FF') +
      coord_equal()
  })

}
