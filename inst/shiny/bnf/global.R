simple <- list(
  expr = list(
    list(items = list('term'), N = 'one'),
    list(
      items = list(
        list(items = list('op', 'term'), N = 'one'),
        list(items = list('op', 'term'), N = 'one')
      ),
      type = 'choice',
      N    = 'zero_or_more'
    )
  ),
  term = list(
    list(items = list('number'), N = 'one', type = 'all'),
    list(
      items = list(
        list(items = list('op', 'number'), N = 'one'),
        list(items = list('op', 'func'), N = 'one'),
        list(items = list('op', 'var'), N = 'one')
      ),
      type = 'choice',
      N    = 'zero_or_more'
    )
  ),
  op = list(
    items = list('+', '-', '*', '/'),
    N = 'one',
    type = 'choice'
  ),
  func = list(
    list(items = list('cos', 'sin'), N = 'one', type = 'choice'),
    list(items = list('(', 'term', ')'), N = 'one')
  ),
  var = list(
    items = list('x', 'y'), N = 'one', type = 'choice'
  ),
  number = list(
    items = as.list(as.character(0:9)),
    N     = 'one_or_more',
    type  = 'choice'
  )
)
