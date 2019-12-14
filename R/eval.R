

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Make a function from a character string representing an R expression
#'
#' @param expr A string representing an R expression e.g. \code{x + y}
#'
#' @return A function with 2 formal arguments (\code{x}, \code{y}) which will
#' calculate the value of the given expression at this location
#'
#' @examples
#' \dontrun{
#' f <- char_expression_to_function("x + y")
#' f(1, 2)
#' }
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
char_expression_to_function <- function(expr) {
  function(x, y) {
    eval(parse(text = expr))
  }
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Evaluate code (given as a character string) at gridded points on the (x, y) plane
#'
#' @param code A character string containing an R expression.
#' @param xmin,xmax,xn grid dimensions along x-axis i.e. the minimum and maximum
#'        extents on the x axis, and the number of grid points to generate
#'        along this dimension
#' @param ymin,ymax,yn grid dimensions along y-axis i.e. the minimum and maximum
#'        extents on the y axis, and the number of grid points to generate
#'        along this dimension. Defaults to same as x-axis
#'
#' @return data.frame of \code{(x, y)} coordinates and the evaluated function at these
#'         coordinates \code{z}
#'
#' @examples
#' eval_grid("x + y")
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
eval_grid <- function(code, xmin = 0, xmax = 1, xn = 10, ymin = xmin, ymax = xmax, yn = xn) {

  if (is.character(code)) {
    fun <- char_expression_to_function(code)
  } else {
    stop("eval_grid: 'code' must be a character expression (e.g. 'x + y')")
  }

  dat <- expand.grid(x = seq(from = xmin, to = xmax, length.out = xn),
                     y = seq(from = ymin, to = ymax, length.out = yn))

  dat$z <- fun(dat$x, dat$y)

  dat
}

