
# Expr ::= Term ('+' Term | '-' Term)*
# Term ::= Factor ('*' Factor | '/' Factor)*
# Factor ::= ['-'] (Number | '(' Expr ')')
# Number ::= Digit+

rm(list = ls())

simple <- list(
  expr = list(
    list(items = list('term'), N = 'one'),
    list(
      items = list(
        list(items = list('+', 'term'), N = 'one'),
        list(items = list('-', 'term'), N = 'one')
      ),
      type = 'choice',
      N    = 'zero_or_more'
    )
  ),
  term = list(
    list(items = list('factor'), N = 'one', type = 'all'),
    list(
      items = list(
        list(items = list('*', 'factor'), N = 'one'),
        list(items = list('/', 'factor'), N = 'one')
      ),
      type = 'choice',
      N    = 'zero_or_more'
    )
  ),
  factor = list(
    list(items = list('-'), N = 'zero_or_one', type = 'choice'),
    list(
      items = list(
        list(items = list('number'), N = 'one'),
        list(items = list('(', 'expr', ')'), N = 'one')
      ),
      type = 'choice',
      N    = 'one'
    )
  ),
  number = list(
    items = as.list(as.character(0:9)),
    N     = 'one_or_more',
    type  = 'choice'
  )
)


library(rlang)
library(purrr)

global_spec <- simple

create <- function(spec, state) {

  # Keep track of the state.
  # Currently only tracking call depth
  state$N <- state$N + 1L
  # print(state$N)

  if (is.character(spec)) {
    if (spec %in% names(global_spec)) {
      return(create(global_spec[[spec]], state = state))
    }
    return(paste(spec, collapse=''))
  }

  if ('items' %in% names(spec)) {
    Norig <- spec$N %||% 'one'
    items <- spec$items
    N <- switch(
      Norig,
      one          = 1,
      zero_or_more = rpois(1, 1.5),
      one_or_more  = rpois(1, 1.5) + 1,
      zero_or_one  = sample(c(0, 1), 1),
      stop("Ugh N = ", N)
    )

    if (state$N > 20 & Norig == 'zero_or_more') {
      N <- 0
    }

    if (state$N > 20 & Norig == 'one_or_more') {
      N <- 1
    }



    type <- spec$type %||% 'all'

    if (type == 'choice') {
      items <- sample(spec$items, N, replace = TRUE)
    } else {
      items <- spec$items
    }

    res <- purrr::map_chr(items, create, state = state)
    res <- paste(res, collapse = '')

  } else {
    res <- purrr::map_chr(spec, create, state = state)
    res <- paste(res, collapse = '')
  }

  res
}



spec <- simple$expr
zz <- create(simple$expr, state = list(N = 1L))
zz


