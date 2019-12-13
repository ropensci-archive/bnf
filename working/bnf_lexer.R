

library(stringr)
source(here::here('working', 'lexer.R'))

# Expr   ::= Term ('+' Term | '-' Term)*
# Term   ::= Number ('*' Number | '/' Number)*
# Number ::= ('0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9')+

line0 <- "dummy ::= a b c ;"
line1 <- "dummy ::= a | b | c ;"
line2 <- "dummy ::= (a)+ ;"
line3 <- "dummy ::= (a b)+ ;"
line4 <- "dummy ::= (a | b | c)+ ;"


line10 <- "Expr ::= Term ('+' Term | '-' Term)*"

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
Factor ::= ['-'] (Number | '(' Expr ')' | Call) ;
Call   ::= ('cos(' Expr ')' | 'sin(' Expr ')') ;
Number ::= ('0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9')+ ;
"


# Notes/Restrictions
# '+' and '*' modifiers are only allowed on bracketed expressions
# '[]' delimits an optional item i.e. N = 'zero_or_one'
# '()' delimits a choice
# QWORD is a quoted word - only single quotes allowed
# WORD is a bare word. Eventually WORD and QWORD should be
#      treated differently, but for now i just look up all words to
#      see if they exist in the global spec

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
  number      = pattern_number,
  WORD       = "('.*?'|\\w+)",
  whitespace  = "\\s+"
)


tokens <- lex(line0, patterns = bnf_patterns)
tokens <- tokens[names(tokens) != 'whitespace']
tokens <- gsub("'", "", tokens)
tokens


peek_type     <- function(tokens) {     names(tokens[ 1]) }
peek_value    <- function(tokens) {    unname(tokens[ 1]) }
consume_token <- function(tokens) { invisible(tokens[-1])  }
assert_type   <- function(type, tokens) {
  stopifnot(identical(peek_type(tokens), type))
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

end_of_tokens <- function(tokens) {length(tokens) == 0}


`%notin%` <- Negate(`%in%`)

# Parse rule
assert_type('WORD', tokens)
rule_name <- peek_value(tokens)
tokens <- consume_token(tokens)
assert_type('ASSIGN', tokens)
tokens
tokens <- consume_token(tokens)
tokens

# parse items
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


parse_items <- function(tokens) {
  items   <- list()
  has_ORs <- FALSE
  while (peek_type(tokens) %notin% item_delimiters && !end_of_tokens(tokens)) {
    items  <- append(items, peek_value(tokens))
    tokens <- consume_token(tokens)
  }

  if (check_type('LBRACKET', tokens)) {
    tokens <- consume_token(tokens)
    while (peek_type(tokens) %notin% item_delimiters) {
      split_tokens <- split_while_type('WORD', tokens)
      tokens <- split_tokens$rhs
      sub_items <- parse_items(split_tokens$lhs)
      items <- append(items, sub_items)
    }
  }

  if (check_type('RBRACKET', tokens) || end_of_tokens(tokens) || check_type('ENDOFRULE', tokens)) {
    N <- 'one'
  } else if (check_type('RBRACKET1P', tokens)) {
    N <- 'one_or_more'
  } else if (check_type('RBRACKET0P', tokens)) {
    N <- 'zero_or_more'
  } else if (check_type('SRBRACKET', tokens)) {
    N <- 'zero_or_one'
  } else {
    stop("Ugh Ugh: ", peek_type(tokens), " : ", peek_value(tokens))
  }

  if (has_ORs) {
    type <- 'choice'
  } else {
    type <- 'all'
  }

  list(items = items, N = N, type = type)
}

items <- parse_items(tokens)
cat(deparse(items))

# N    <- 'one'
# type <- 'all'
#
# rule <- setNames(list(list(items = items, N = N, type = type)), rule_name)
# cat(deparse(rule))
