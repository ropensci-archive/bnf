

library(stringr)
source('lexer.R')

# Expr ::= Term ('+' Term | '-' Term)*
# Term ::= Number ('*' Number | '/' Number)*
# Number ::= ('0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9')+

line1 <- "Expr ::= Term ('+' Term | '-' Term)*"

simple_bnf <- "
Expr ::= Term ('+' Term | '-' Term)* ;
Term ::= Number ('*' Number | '/' Number)* ;
Number ::= ('0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9')+ ;"

simple_bnf_with_factor <- "
Expr ::= Term ('+' Term | '-' Term)* ;
Term ::= Factor ('*' Factor | '/' Factor)* ;
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

patterns <- c(
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


tokens <- lex(simple_bnf, patterns = patterns)
tokens[names(tokens) != 'whitespace']









