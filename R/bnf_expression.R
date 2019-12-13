#' bnf_expression expression from BNF spec
#'
#' @param spec A BNF spec element in list form
#' @param global_spec A global BNF spec in list form
#' @param zero_more_lambda poisson lambda for distribution of zero or mores
#' @param one_more_lambda poisson lambda for distribution of one or mores
#' @param zero_prob probability of a zero in for zero or one case
#'
#' @return
#' @export
#'
bnf_expression <- function(spec, global_spec,
                           zero_more_lambda = 1,
                           one_more_lambda = 1,
                           zero_prob = 0.5,
                           state = list(N = 1L)) {

  # Keep track of the state.
  # Currently only tracking call depth
  state$N <- state$N + 1L
  # print(state$N)

  if (is.character(spec)) {
    if (spec %in% names(global_spec)) {
      return(bnf_expression(global_spec[[spec]], global_spec, state = state,
                            zero_more_lambda = zero_more_lambda,
                            one_more_lambda = one_more_lambda))
    }
    return(paste(spec, collapse=''))
  }

  # browser()
  if ('items' %in% names(spec)) {
    Norig <- spec$N %||% 'one'
    items <- spec$items
    # browser()
    N <- switch(
      Norig,
      one          = 1,
      zero_or_more = rpois(1, zero_more_lambda),
      one_or_more  = rpois(1, one_more_lambda) + 1,
      zero_or_one  = sample(c(0, 1), size = 1, prob = c(zero_prob, 1 - zero_prob)),
      stop("Ugh N = ", N)
    )

    # Prevent stack from getting too deep
    if (state$N > 80 & Norig == 'zero_or_more') {
      N <- 0
    }

    if (state$N > 80 & Norig == 'one_or_more') {
      N <- 1
    }



    type <- spec$type %||% 'all'

    if (type == 'choice') {
      items <- sample(spec$items, N, replace = TRUE)
    } else {
      items <- spec$items
    }

    res <- purrr::map_chr(items, bnf_expression, global_spec = global_spec, state = state,
                          zero_more_lambda = zero_more_lambda,
                          one_more_lambda = one_more_lambda)
    res <- paste(res, collapse = '')

  } else {
    res <- purrr::map_chr(spec, bnf_expression, global_spec = global_spec, state = state,
                          zero_more_lambda = zero_more_lambda,
                          one_more_lambda = one_more_lambda)
    res <- paste(res, collapse = '')
  }

  res
}
