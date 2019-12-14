

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Generate code from a BNF specification
#'
#' @param bnf_spec A full BNF grammar specification
#' @param bnf_rule A single rule from the bnf_spec to be used as the starting
#'        node for code generation.  By default this is the first element in the
#'        \code{bnf_spec}, but user may specify alternate starting node by name,
#'        or by passing in the rule from the full specification. See \code{Examples}
#' @param lambda0p When an item is to be repeated "zero or more" times, the actual
#'        number of repetitions is drawn from a poisson distribution with
#'        mean =  \code{lambda0p}. Setting this value above too high (depending
#'        on your grammer) can result in runaway recursion and stack overflow.
#'        Default: 1
#' @param lambda1p When an item is to be repeated "one or more" times, the actual
#'        number of repetitions is drawn from a poisson distribution with
#'        mean =  \code{lambda1p}.  Setting this value above too high (depending
#'        on your grammer) can result in runaway recursion and stack overflow.
#'        Default: 1
#' @param zero_prob When an item is to be repeated "zero or one" times, the
#'        actual number of repetitions is randomly selected. This value sets
#'        the probability of 0 repetitions.  Default: 0.5
#' @param state a list of state information.  Should not be set by user (unless
#'        they really want to)
#'
#' @return Code generated from the given BNF
#'
#' @importFrom stats rpois
#' @import purrr
#' @export
#'
#' @examples
#' \dontrun{
#' generate_code(bnf_spec = bnf_spec)
#' generate_code(bnf_spec = bnf_spec, bnf_rule = bnf_spec[[1]])
#' generate_code(bnf_spec = bnf_spec, bnf_fule = 'Expr')
#' }
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
generate_code <- function(bnf_spec,
                          bnf_rule  = bnf_spec[[1]],
                          lambda0p  = 1,
                          lambda1p  = 1,
                          zero_prob = 0.5,
                          state     = list(depth = 1L)) {


  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Keep track of the state.
  # Currently this is just the recursion depth
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  state$depth <- state$depth + 1L


  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # If a character is passed in as the bnf_rule it could either be:
  #   1. The name of another rule to generate from (e.g. 'Expr')
  #   2. The verbatim character string to output
  #
  # Currently there is no difference in the bnf_spec between these things, so
  # all character strings are looked-up in the global_spec to decide which it
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (is.character(bnf_rule)) {
    if (bnf_rule %in% names(bnf_spec)) {
      return(generate_code(bnf_spec = bnf_spec,
                           bnf_rule = bnf_spec[[bnf_rule]],
                           state    = state,
                           lambda0p = lambda0p,
                           lambda1p = lambda1p))
    }
    return(paste(bnf_rule, collapse=''))
  }


  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # If there are 'items' in this rule, then generate from them.
  # Otherwise it means that the nested elements have items and we should recurse
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if ('items' %in% names(bnf_rule)) {
    Norig <- bnf_rule$N %||% 'one'
    items <- bnf_rule$items
    # browser()
    N <- switch(
      Norig,
      one          = 1,
      zero_or_more = rpois(1, lambda0p),
      one_or_more  = rpois(1, lambda1p) + 1,
      zero_or_one  = sample(c(0, 1), size = 1, prob = c(zero_prob, 1 - zero_prob)),
      stop("generate_code(): Invalid N specified. The following value is not allowed: = ",
           deparse(N), call. = FALSE)
    )

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Prevent stack from getting too deep.
    # i.e.. check how deep we currently are, and if the current production rule
    # is 'zero or more' or 'one or more', then set N to the minimum possible
    # value.
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if (state$depth > 80 & Norig == 'zero_or_more') { N <- 0 }
    if (state$depth > 80 & Norig == 'one_or_more' ) { N <- 1 }
    if (state$depth > 80 & Norig == 'zero_or_one' ) { N <- 0 }



    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Be default, all elements in the current run are expressed in the output
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    type <- bnf_rule$type %||% 'all'


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # If we have to choose amongst elements, then sample the appropriate number
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if (type == 'choice') {
      items <- sample(bnf_rule$items, N, replace = TRUE)
    } else {
      items <- bnf_rule$items
    }

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recurse through these items and accumulate their output
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    res <- purrr::map_chr(items, ~generate_code(bnf_spec = bnf_spec,
                                                bnf_rule = .x,
                                                state    = state,
                                                lambda0p = lambda0p,
                                                lambda1p = lambda1p))
  } else {
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # The nested elements have items and we should recurse over the current rule
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    res <- purrr::map_chr(bnf_rule, ~generate_code(bnf_spec = bnf_spec,
                                                   bnf_rule = .x,
                                                   state    = state,
                                                   lambda0p = lambda0p,
                                                   lambda1p = lambda1p))
  }


  res <- paste(res, collapse = '')
  res
}


