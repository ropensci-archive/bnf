#' run_example
#'
#' @export
run_example <- function() {
  if(!requireNamespace("shiny", quietly = TRUE)) {
    stop("The shiny package is not available. Install with `install.packages('shiny')`.")
  }
  appDir <- system.file("shiny", "bnf", package = "bnf")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `bnf`.", call. = FALSE)
  }

  shiny::runApp(appDir, display.mode = "normal")
}
