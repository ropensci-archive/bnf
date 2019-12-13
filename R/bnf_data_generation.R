#' Generate xy data from an expression
#'
#' @param f A function that accepts two numeric arguments and returns a single numeric value
#' @param xdim An integer defining length of the x dimension
#' @param ydim An integer defining length of the y dimension
#'
#' @return A tibble
#' @export
#'
dat_generation_grid <- function(f, xdim = 20, xby = 1, ydim = 20, yby = 1) {

  dat <- expand.grid(x = seq(from = 0, length.out = xdim, by = xby),
                     y = seq(from = 0, length.out = ydim, by = yby)) %>%
    dplyr::mutate(z = purrr::map2_dbl(x, y, f))

}

#' Generate path data from an expression
#'
#' @param f
#' @param seed1 A double
#' @param seed2 A double
#'
#' @return A tibble
#' @export
#'
dat_generation_path <- function(f, seed1, seed2, n) {
  x_vec <- vector("double", n)
  y_vec <- vector("double", n)

  x_vec[1] <- fun(seed1, seed2)
  y_vec[1] <- fun(seed2, seed1)

  for (i in seq_len(n - 1)) {
    x_vec[i + 1] <- fun(x_vec[i], y_vec[i])
    y_vec[i + 1] <- fun(y_vec[i], x_vec[i])
  }

  tibble::tibble(x = x_vec, y = y_vec)
}
