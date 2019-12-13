simple <- list(
  expr = list(
    list(items = list('term'), N = 'one'),
    list(
      items = list(
        list(items = list('op', 'term'), N = 'one'),
        list(items = list('op', 'term'), N = 'one')
      ),
      type = 'choice',
      N    = 'zero_or_more'
    )
  ),
  term = list(
    list(items = list('number'), N = 'one', type = 'all'),
    list(
      items = list(
        list(items = list('op', 'number'), N = 'one'),
        list(items = list('op', 'func'), N = 'one'),
        list(items = list('op', 'var'), N = 'one'),
      ),
      type = 'choice',
      N    = 'zero_or_more'
    )
  ),
  op = list(
    items = list('+', '-', '*', '/'),
    N = 'one',
    type = 'choice'
  ),
  func = list(
    list(items = list('cos', 'sin'), N = 'one', type = 'choice'),
    list(items = list('(', 'term', ')'), N = 'one')
  ),
  var = list(
    items = list('x', 'y'), N = 'one', type = 'choice'
  ),
  number = list(
    items = as.list(as.character(0:9)),
    N     = 'one_or_more',
    type  = 'choice'
  )
)


library(rlang)
library(tidyverse)

global_spec <- simple

create <- function(spec) {
  # browser()
  if (is.character(spec)) {
    if (spec %in% names(global_spec)) {
      return(create(global_spec[[spec]]))
    }
    return(paste(spec, collapse=''))
  }

  if ('items' %in% names(spec)) {
    N <- spec$N %||% 1
    items <- spec$items
    N <- switch(
      N,
      one          = 1,
      zero_or_more = 2,
      one_or_more  = 3,
      9
    )

    type <- spec$type %||% 'all'

    if (type == 'choice') {
      items <- sample(spec$items, N, replace = TRUE)
    } else {
      items <- spec$items
    }

    res <- purrr::map_chr(items, create)
    res <- paste(res, collapse = '')

  } else {
    res <- purrr::map_chr(spec, create)
    res <- paste(res, collapse = '')
  }

  res
}

spec <- simple$expr

zz <- create(simple$expr)
zz

fun <- function(x, y) {
  eval(parse(text = zz))
}



make_fun <- function() {
  zz <- create(simple$expr)

  fun <- function(x, y) {
    eval(parse(text = zz))
  }
}
aargh_grid <- function(n) {

  fun <- make_fun()

  dat <- expand.grid(1:n, 1:n) %>%
    as_tibble %>%
    mutate(z = map2_dbl(Var1, Var2, fun))

  p <- ggplot(aes(Var1, Var2)) +
    geom_tile(aes(fill = log(z))) +
    scale_fill_viridis_c(guide = "none") +
    theme_void()
  print(p)
}
