
# Expr ::= Term ('+' Term | '-' Term)*
# Term ::= Factor ('*' Factor | '/' Factor)*
# Factor ::= ['-'] (Number | '(' Expr ')')
# Number ::= Digit+


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
    list(items = list('number'), N = 'one', type = 'all'),
    list(
      items = list(
        list(items = list('*', 'number'), N = 'one'),
        list(items = list('/', 'number'), N = 'one')
      ),
      type = 'choice',
      N    = 'zero_or_more'
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

create <- function(spec) {
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
      zero_or_more = rpois(1, 1.5),
      one_or_more  = rpois(1, 1.5) + 1,
      stop("Ugh N = ", N)
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
eval(parse(text = zz))












