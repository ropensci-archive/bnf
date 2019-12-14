
# bnf 0.1.1 (20191214)

* Renamed files and functions for clarity
* Minor parser changes
    * removed extra `NULL` which is generated under some conditions. This was 
      harmless but looked terrible.
    * Intermediate representation now assumes that `N = 'one'` and `type = 'all'`
      if not specified. This makes the representation much less verbose.
* Documentation update
* Removed hack for graphical output in README where we were using a pre-generated 
  intermediate grammar representation.  Grammar is now actually parsed from 
  BNF text
* Sped up the grid generation for plotting (also removed dplyr dependency)
* Shiny App
    * Removed some graphical output in the interests of maintainability
    * Added some more sliders to control code generation and graphic output
    * switched over to an actual parsed BNF (it used to be a pre-generated 
      grammar representation)

# bnf 0.1.0 (20191213)

* Initial release at #OzUnconf19
