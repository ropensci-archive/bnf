
plist <- function(ll) {
  cat(paste(trimws(deparse(ll, width.cutoff = 500)), collapse = " "))
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Some simple BNFs to work with
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
simple_bnf <- "
Expr   ::= Term ('+' Term | '-' Term)* ;
Term   ::= Number ('*' Number | '/' Number)* ;
Number ::= ('0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9')+ ;"

simple_bnf_with_factor <- "
Expr   ::= Term ('+' Term | '-' Term)* ;
Term   ::= Factor ('*' Factor | '/' Factor)* ;
Factor ::= ['-'] (Number | '(' Expr ')') ;
Number ::= ('0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9')+ ;
"

simple_bnf_with_functions <- "
Expr   ::= Term ('+' Term | '-' Term)* ;
Term   ::= Factor ('*' Factor | '/' Factor)* ;
Factor ::= (Number | Var | '(' Expr ')' | Call) ;
Call   ::= ('cos(' Expr ')' | 'sin(' Expr ')') ;
Var    ::= ('x' | 'y') ;
Number ::= ('0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9')+ ;
"


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Notes/Restrictions on parsing BNF
# '+' and '*' modifiers are only allowed on bracketed expressions
# '[]' delimits an optional item i.e. N = 'zero_or_one'
# '()' delimits a choice
# '| is only allowed inside '()' for delimiting choices
# QWORD is a quoted word - only single quotes allowed
# WORD is a bare word. Eventually WORD and QWORD should be
#      treated differently, but for now i just look up all words to
#      see if they exist in the global spec
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
bnf_patterns <- c(
  ASSIGN      = "::=",
  ENDOFRULE   = "\\s+;",
  OR          = "\\|",
  LBRACKET    = '\\(',
  RBRACKET1P  = '\\)\\+',
  RBRACKET0P  = '\\)\\*',
  RBRACKET    = '\\)',
  SLBRACKET   = '\\[',
  SRBRACKET   = '\\]',
  number      = minilexer::pattern_number,
  WORD       = "('.*?'|\\w+)",
  whitespace  = "\\s+"
)



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Some internal tools for working with a list of tokens.
# Note: Everything here should probably be grouped into an R6 class
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
peek_type     <- function(tokens) {     names(tokens[ 1]) }
peek_value    <- function(tokens) {    unname(tokens[ 1]) }
consume_token <- function(tokens) { invisible(tokens[-1])  }
assert_type   <- function(type, tokens) {
  if (!identical(peek_type(tokens), type)) {
    stop("Expected type '", type, "' but got:", peek_type(tokens))
  }
}
check_type <- function(type, tokens) {
  identical(peek_type(tokens), type)
}


split_while_type <- function(type, tokens) {
  pos <- which(names(tokens) != type)
  if (length(pos) == 0) {
    print(tokens)
    stop("split file: ", type)
  }
  pos <- pos[1]

  lhs <- tokens[1:(pos-1)]
  rhs <- tokens[pos:length(tokens)]
  list(lhs = lhs, rhs = rhs)
}


split_until_type <- function(type, tokens) {
  pos <- which(names(tokens) == type)
  if (length(pos) == 0 || pos[1] == length(tokens)) {
    return(list(lhs=tokens, rhs=list())) # return all tokens if token not found
  }
  pos <- pos[1]

  lhs <- tokens[1:pos]

  rhs <- tokens[(pos+1):length(tokens)]
  list(lhs = lhs, rhs = rhs)
}



end_of_tokens <- function(tokens) {length(tokens) == 0}


`%notin%` <- Negate(`%in%`)


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Which tokens indicate the end of a run of items
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
item_delimiters <- c(
  'ENDOFRULE',
  'OR',
  'LBRACKET',
  'RBRACKET',
  'RBRACKET1P',
  'RBRACKET0P',
  'SLBRACKET',
  'SRBRACKET'
)


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Parse items
#'
#' @param tokens named character vector of tokens
#'
#' @return a list representation of the items
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
parse_items <- function(tokens) {
  items   <- list()
  sub_items   <- list()
  has_ORs <- FALSE
  while (peek_type(tokens) %notin% item_delimiters && !end_of_tokens(tokens)) {
    items  <- append(items, peek_value(tokens))
    tokens <- consume_token(tokens)
  }

  if (length(items) > 0) {
    items <- list(items = items)
  } else {
    items <- NULL
  }

  if (check_type('LBRACKET', tokens) || check_type('SLBRACKET', tokens)) {
    tokens <- consume_token(tokens)

    sub_has_ORs <- FALSE
    while (peek_type(tokens) %notin% item_delimiters) {
      split_tokens  <- split_while_type('WORD', tokens)
      sub_sub_items <- parse_items(split_tokens$lhs)
      sub_items     <- append(sub_items, list(sub_sub_items))

      tokens       <- split_tokens$rhs
      if (check_type('OR', tokens)) {
        sub_has_ORs <- TRUE
        tokens <- consume_token(tokens)
      }
    }

    if (end_of_tokens(tokens)) {
      sub_N <- NULL
    } else if (check_type('RBRACKET', tokens) || check_type('ENDOFRULE', tokens)) {
      sub_N <- NULL
      tokens <- consume_token(tokens)
    } else if (check_type('RBRACKET1P', tokens)) {
      sub_N <- 'one_or_more'
      tokens <- consume_token(tokens)
    } else if (check_type('RBRACKET0P', tokens)) {
      sub_N <- 'zero_or_more'
      tokens <- consume_token(tokens)
    } else if (check_type('SRBRACKET', tokens)) {
      sub_N <- 'zero_or_one'
      tokens <- consume_token(tokens)
    } else {
      stop("Sub Ugh Ugh: ", peek_type(tokens), " : ", peek_value(tokens))
    }

    if (sub_has_ORs) {
      type <- 'choice'
    } else {
      type <- NULL
    }

    sub_items      <- list(items = sub_items)
    sub_items$N    <- sub_N
    sub_items$type <- type

    if (is.null(items)) {
      items <- sub_items
    } else {
      items <- c(list(items), list(sub_items))
    }
  }

  items
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Parse tokens lexed from BNF text into the R nested list representation
#'
#' @param tokens named character vector of tokens from lex()
#' @return R nested list representation of the BNF grammar
#'
#' @importFrom stats setNames
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
parse_bnf_tokens_to_spec <- function(tokens) {
  bnf <- list()
  while (!end_of_tokens(tokens)) {

    assert_type('WORD', tokens)
    rule_name <- peek_value(tokens)
    tokens <- consume_token(tokens) # consume the name
    assert_type('ASSIGN', tokens)
    tokens <- consume_token(tokens) # consume the assignemnt

    split_tokens <- split_until_type('ENDOFRULE', tokens)
    tokens      <- split_tokens$rhs
    rule_tokens <- split_tokens$lhs
    items <- parse_items(rule_tokens)

    new_rule <- setNames(list(items = items), rule_name)

    bnf <- c(bnf, new_rule)
  }
  bnf
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Parse BNF text into tokens
#'
#' @param bnf_text BNF text
#'
#' @return named character vector of tokens
#'
#' @import minilexer
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
parse_bnf_text_to_tokens <- function(bnf_text) {
  tokens <- minilexer::lex(bnf_text, patterns = bnf_patterns)
  tokens <- tokens[names(tokens) != 'whitespace']
  tokens <- gsub("'", "", tokens)
  tokens
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Parse BNF text into an R data structure
#'
#' TODO: detail what flavour of BNF is supported.
#'
#' @param bnf_text string containing the BNF rules
#'
#' @return nested list representing the BNF
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
parse_bnf <- function(bnf_text) {
  tokens <- parse_bnf_text_to_tokens(bnf_text)
  spec   <- parse_bnf_tokens_to_spec(tokens)
  spec
}

