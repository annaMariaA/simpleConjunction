library(brms)
library(tidyverse)
library(knitr)
library(patchwork)
library(bayesplot)

source("RTmixture.R")

ggplot2::theme_set(cowplot::theme_cowplot())
options(mc.cores = 4) # , brms.backend = "cmdstanr"

cache_dir <- "_RTmixture_cache"
if(!dir.exists(cache_dir)) {
  dir.create(cache_dir)
}


d <- read_csv("../data_prolific/accuracy_rt_data.txt") %>%
  mutate(
    targ_present = as_factor(targPresent),
    trial_type = as_factor(targetType),
    difficulty = as.numeric(as_factor(difficulty))) %>%
  select(observer, trial_type, targ_present, difficulty, n, rt, accuracy)%>%
  filter(accuracy == 1, targ_present == 1) %>%
  mutate(max_shift = 0.5, upper = 30)
summary(d)


fit_mix <- brm(rt | vreal(max_shift, upper) ~ 0+difficulty:trial_type, 
               data = d, 
               family = RTmixture, 
               stanvars = stan_funs_base, 
               refresh = 0,
               prior = c(prior(beta(1, 5), class = "mix")))

fit_base <- brm(rt ~ 0+difficulty:trial_type, data = d, family = shifted_lognormal, refresh = 0)

pp_mix <- pp_check(fit_mix, type = "dens_overlay", nsamples = 100,  cores = 1)  +
  ggtitle("Mixture") + xlim(0, 10)
pp_base <- pp_check(fit_base, type = "dens_overlay", nsamples = 100,  cores = 1) +
  ggtitle("Shifted lognormal") + xlim(0, 10)
pp_mix / pp_base


fit_mix <- add_criterion(fit_mix, "loo", cores = 1)
fit_base <- add_criterion(fit_base, "loo", cores = 1)
loo_compare(fit_mix, fit_base)