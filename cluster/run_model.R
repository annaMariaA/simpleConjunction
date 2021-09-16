#!/usr/bin/Rscript3.6.3

library(tidyverse)
library(brms)

options(mc.cores = 4)

d <- read_csv("data_for_model.csv", 
              col_types = "fffffdfi") %>%
  mutate(diff = if_else(difficulty == "easy", 1, 0),
         diff = if_else(difficulty == "mid", 2, diff),
         diff = if_else(difficulty == "hard", 3, diff),
         difficulty = diff) %>%
  select(-diff)

formula <- bf(rt | dec(response) ~ 
                # the first part is the linear predictor for drift rate
                0 + targ:trial  + targ:trial:difficulty  + 
                (0 + targ:trial  + targ:trial:difficulty|p|observer), 
              # bs: boundary separation 
              bs ~ 0 + trial + (0 + trial|p|observer), 
              # ndt: non-decision time
              ndt ~ 1 + (1|p|observer),
              # bias: starting bias for TA or TP
              bias ~ 0 + trial + (0 + trial|p|observer))

prior <- c(
  set_prior("normal(0, 3)", class = "b"),
  set_prior("normal(1.5, 1)", class = "b", dpar = "bs"),
  set_prior("normal(0, 0.01)", class = "sd", dpar = "ndt"),
  set_prior("normal(0.0, 0.5)", class = "b", dpar = "bias"),
  set_prior("normal(-5, 0.5)", class = "Intercept", dpar = "ndt"))

make_stancode(formula, 
              family = wiener(link_bs = "identity", 
                              link_bias = "identity"),
              data = d, 
              prior = prior)

tmp_dat <- make_standata(formula, 
                         family = wiener(link_bs = "identity", 
                                         link_ndt = "identity",
                                         link_bias = "identity"),
                         data = d, prior = prior)
str(tmp_dat, 1, give.attr = FALSE)

initfun <- function() {
  list(
    b = rnorm(tmp_dat$K),
    b_bs = runif(tmp_dat$K_bs, 1, 2),
    Intercept_ndt = -10,
    b_bias = rnorm(tmp_dat$K_bias, 0.5, 0.1),
    sd_1 = runif(tmp_dat$M_1, 0.5, 1),
    z_1 = matrix(rnorm(tmp_dat$M_1*tmp_dat$N_1, 0, 0.01),
                 tmp_dat$M_1, tmp_dat$N_1),
    L_1 = diag(tmp_dat$M_1)
  )
}


fit_wiener <- brm(formula,
                  data = d,
                  family = wiener(link_bs = "log",
                                  link_bias = "logit",
                                  link_ndt = "log"),
                  prior = prior,
                  inits = initfun,
                  iter = 2000,
                  chains = 1,
                  control = list(max_treedepth = 15, adapt_delta = 0.9))

saveRDS(fit_wiener, "wiener_fit.model")
