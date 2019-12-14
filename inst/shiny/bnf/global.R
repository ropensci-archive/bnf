
library(shiny)
library(ggplot2)
library(bnf)


my_bnf <- bnf:::simple_bnf_with_functions
tokens <- bnf::parse_bnf_text_to_tokens(my_bnf)
spec   <- bnf::parse_bnf_tokens_to_spec(tokens)
