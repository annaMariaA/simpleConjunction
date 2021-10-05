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
              bs ~ 0 + trial + trial:difficulty + 
                (0 + trial + trial:difficulty|p|observer), 
              # ndt: non-decision time
              ndt ~ 1 + (1|p|observer),
              # bias: starting bias for TA or TP
              bias ~ 0 + trial + trial:difficulty + 
                (0 + trial + trial:difficulty|p|observer))


get_prior(formula, d, 
          family = wiener(link_bs = "log",
                          link_bias = "logit",
                          link_ndt = "log"))

rate_slopes <- c(
  paste("targ", c("absent", "present"), ":trialconj", ":difficulty", sep = ""),
  paste("targ", c("absent", "present"), ":trialori", ":difficulty", sep = ""),
  paste("targ", c("absent", "present"), ":trialtex", ":difficulty", sep = ""))


b_slopes <- paste("trial", unique(d$trial), ":difficulty", sep = "")

prior <- c(
  set_prior("normal(0, 1)", class = "b"), # rate intercepts
  set_prior("normal(0, 0.1)", class = "b", coef = rate_slopes), # rate slopes
  set_prior("normal(1, 1)", class = "b", dpar = "bs"), #boundary sep
  set_prior("normal(0, 0.1)", class = "b", dpar = "bs", coef = b_slopes),
  set_prior("normal(0.0, 0.5)", class = "b", dpar = "bias"),
  set_prior("normal(0.0, 0.1)", class = "b", dpar = "bias", coef = b_slopes),
  set_prior("normal(-5, 0.5)", class = "Intercept", dpar = "ndt"),
  set_prior("normal(0, 0.01)", class = "sd", dpar = "ndt"))

rm(rate_slopes, b_slopes)

tmp_dat <- make_standata(formula,
                         family = wiener(link_bs = "log",
                                         link_bias = "logit",
                                         link_ndt = "log"),
                         data = d, prior = prior,
                         chains = n_chains)
str(tmp_dat, 1, give.attr = FALSE)

initfun <- function() {
  list(
    b = c(rnorm(tmp_dat$K/2, 0, 1), rnorm(tmp_dat$K/2, 0, 0.1)),
    b_bs = c(runif(tmp_dat$K_bs/2, 0.5, 1), runif(tmp_dat$K_bs/2, 0, 0.1)),
    Intercept_ndt = -10,
    b_bias = rnorm(tmp_dat$K_bias, 0.0, 0.1),
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
                  chains = 4,
                  control = list(max_treedepth = 15, adapt_delta = 0.9))

saveRDS(fit_wiener, "wiener_fit.model")
