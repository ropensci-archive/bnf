

library(stringr)
source(here::here('working', 'lexer.R'))

# Expr   ::= Term ('+' Term | '-' Term)*
# Term   ::= Number ('*' Number | '/' Number)*
# Number ::= ('0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9')+

line0 <- "dummy ::= a b c ;"
line1 <- "dummy ::= (a | b | c)+ ;"


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
  QWORD       = "'.*?'",
  WORD        = "\\w+",
  whitespace  = "\\s+"
)


tokens <- lex(line0, patterns = bnf_patterns)
tokens <- tokens[names(tokens) != 'whitespace']
tokens

peek_type     <- function(tokens) {     names(tokens[ 1]) }
peek_value    <- function(tokens) {    unname(tokens[ 1]) }
consume_token <- function(tokens) { invisible(tokens[-1])  }
assert_type   <- function(type, tokens) {
  stopifnot(identical(peek_type(tokens), type))
}
end_of_tokens <- function(tokens) {length(tokens) == 0}


`%notin%` <- Negate(`%in%`)

# Parse rule
tokens
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

items <- list()
while (peek_type(tokens) %notin% item_delimiters) {
  items  <- append(items, peek_value(tokens))
  tokens <- consume_token(tokens)
}

N    <- 'one'
type <- 'all'

rule <- setNames(list(list(items = items, N = N, type = type)), rule_name)
cat(deparse(rule))


