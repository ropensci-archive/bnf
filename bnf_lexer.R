

library(stringr)
source('lexer.R')

# Expr ::= Term ('+' Term | '-' Term)*
# Term ::= Number ('*' Number | '/' Number)*
# Number ::= Digit+

line1 <- "Expr ::= Term ('+' Term | '-' Term)*"

simple_bnf <- "
Expr ::= Term ('+' Term | '-' Term)* ;
Term ::= Number ('*' Number | '/' Number)* ;
Number ::= Digit+ ;"

simple_bnf_with_factor <- "
Expr ::= Term ('+' Term | '-' Term)* ;
Term ::= Factor ('*' Factor | '/' Factor)* ;
Factor ::= ['-'] (Number | '(' Expr ')') ;
Number ::= Digit+ ;
"

simple_bnf_with_functions <- "
Expr   ::= Term ('+' Term | '-' Term)* ;
Term   ::= Factor ('*' Factor | '/' Factor)* ;
Factor ::= ['-'] (Number | '(' Expr ')' | Call) ;
Call   ::= ('cos(' Expr ')' | 'sin(' Expr ')') ;
Number ::= Digit+ ;
"


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
  WORD0P      = "\\w+\\*",
  WORD1P      = "\\w+\\+",
  WORD        = "\\w+",
  whitespace  = "\\s+"
)


tokens <- lex(simple_bnf_with_functions, patterns = patterns)
tokens[names(tokens) != 'whitespace']


