

library(rlang)
library(purrr)

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
    # cat("Norig : ", Norig, "\n")
    N <- switch(
      Norig,
      one          = 1,
      zero_or_more = rpois(1, 1.0),
      one_or_more  = rpois(1, 1.2) + 1,
      zero_or_one  = sample(c(0, 1), 1),
      stop("Ugh N = ", N)
    )

    # Prevent stack from getting too deep
    if (state$N > 80 & Norig == 'zero_or_more') {
      N <- 0
    }

    if (state$N > 80 & Norig == 'one_or_more') {
      N <- 1
    }

    # cat("N : ", N, "\n")


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

spec <- list(
  Expr = list(
    list(items = list("Term"), N = "one", type = "all"),
    list(items = list(
      list(items = list("+", "Term"), N = "one", type = "all"),
      list(items = list("-", "Term"), N = "one", type = "all")),
      N = "zero_or_more", type = "choice")
  ),
  Term = list(list(items = list("Number"), N = "one", type = "all"),
              list(items = list(list(items = list("*", "Number"), N = "one",
                                     type = "all"), list(items = list("/", "Number"),
                                                         N = "one", type = "all")), N = "zero_or_more", type = "choice")),
  Number = list(NULL, list(items = list(list(items = list("0"),
                                             N = "one", type = "all"), list(items = list("1"), N = "one",
                                                                            type = "all"), list(items = list("2"), N = "one", type = "all"),
                                        list(items = list("3"), N = "one", type = "all"), list(
                                          items = list("4"), N = "one", type = "all"), list(
                                            items = list("5"), N = "one", type = "all"), list(
                                              items = list("6"), N = "one", type = "all"), list(
                                                items = list("7"), N = "one", type = "all"), list(
                                                  items = list("8"), N = "one", type = "all"), list(
                                                    items = list("9"), N = "one", type = "all")), N = "one_or_more",
                           type = "choice")))




global_spec <- spec
create(spec$Expr, state = list(N=1))



