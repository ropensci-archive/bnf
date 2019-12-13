
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bnf

<!-- badges: start -->

![](https://img.shields.io/badge/very-experimental-orange.svg)
<!-- badges: end -->

The goal of `bnf` is to parse grammar specifications in [Backus–Naur
form (BNF)](https://en.wikipedia.org/wiki/Backus%E2%80%93Naur_form) and
generate language from that grammar.

The focus for \#OzUnconf19 was to generate valid R code from a very
restricted subset of the R grammar.

This generated code was then used to calculated coordinates to visualise
and turn into audio.

## Installation

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("coolbutuseless/minilexer")
devtools::install_github("ropenscilabs/bnf")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(bnf)
## basic example code
```
