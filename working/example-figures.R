temp <- bnf_expression(simple$expr, simple, 1.5, 1.5)
fun <- bnf_function(temp)
dat_grid <- bnf::dat_generation_grid(fun, 100, 0.1, 100, 0.1)

ggplot(dat_grid, aes(x, y)) +
  geom_tile(aes(fill = abs(log(z)))) +
  theme_void()

