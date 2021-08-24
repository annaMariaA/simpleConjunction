library(tidyverse)
library(brms)
library(tidybayes)
library(patchwork)

options(mc.cores = 4)

d <- read_csv("accuracy_rt_data.txt") %>%
  mutate(
    targ_present = as_factor(targPresent),
    targ_present = fct_recode(targ_present, present = "1", absent = "0"),
    trial_type = as_factor(targetType),
    difficulty = as.numeric(as_factor(difficulty))) %>%
  select(observer, trial="trial_type", targ="targ_present", difficulty, n, rt, accuracy) 

d$response <- NA
d$response[which(d$targ=="present" & d$accuracy==1)] = 1
d$response[which(d$targ=="present" & d$accuracy==0)] = 0
d$response[which(d$targ=="absent" & d$accuracy==1)] = 0
d$response[which(d$targ=="absent" & d$accuracy==0)] = 1




# remove some outliers
d <- filter(d, rt > 0.2, rt < 20)


formula <- bf(rt | dec(response) ~ 
              0 + targ:trial  + targ:trial:difficulty  + (0 + targ:trial + targ:trial:difficulty|p|observer), 
              bs ~ 0 + trial + (0 + trial|p|observer), 
              ndt ~ 0 + trial,
              bias ~ 0 + trial + (0 + trial|p|observer))

get_prior(formula,
          data = d, 
          family = wiener(link_bs = "identity", 
                          link_ndt = "identity", 
                          link_bias = "identity"))

prior <- c(
  prior("normal(0, 2)", class = "b"),
  set_prior("normal(1.5, 1)", class = "b", dpar = "bs"),
  set_prior("normal(0.2, 0.1)", class = "b", dpar = "ndt"),
  set_prior("normal(0.5, 0.2)", class = "b", dpar = "bias")
)


make_stancode(formula, 
              family = wiener(link_bs = "identity", 
                              link_ndt = "identity",
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
    b_ndt = runif(tmp_dat$K_ndt, 0.01, 0.1),
    b_bias = rnorm(tmp_dat$K_bias, 0.5, 0.1),
    sd_1 = runif(tmp_dat$M_1, 0.5, 1),
    z_1 = matrix(rnorm(tmp_dat$M_1*tmp_dat$N_1, 0, 0.01),
                 tmp_dat$M_1, tmp_dat$N_1),
    L_1 = diag(tmp_dat$M_1)
  )
}



fit_wiener <- brm(formula,
                  data = d,
                  family = wiener(link_bs = "identity",
                                  link_ndt = "identity",
                                  link_bias = "identity"),
                  prior = prior,
                  inits = initfun,
                  iter = 2000,
                  chains = 4, cores = 4,
                  control = list(max_treedepth = 15))

saveRDS(fit_wiener, "wiener_fit.model")
