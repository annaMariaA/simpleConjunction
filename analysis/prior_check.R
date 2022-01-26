library(tidyverse)
library(brms)
library(tidybayes)

# options(mc.cores = 1)
n_chains <- 1
n_iter <- 1000

d <- read_csv("../cluster_level3/data_for_model.csv")  %>%
  filter(nD == 15) %>%
  mutate(obs = as.factor(obs))


dp <- d %>% group_by(targ, type) %>%
  summarise(rt = median(rt),
            response = 1, .groups = "drop")


#########################################
#### FULL model
#########################################
formula <- bf(rt | dec(response) ~ 
                # the first part is the linear predictor for drift rate
                0 + targ:type,
              # bs: boundary separation 
              bs ~ 0 + type, 
              # ndt: non-decision time
              ndt ~ 1,
              # bias: starting bias for TA or TP
              bias ~ 0 + type)

prior <- c(
  set_prior("normal(0, 1)", class = "b"), # rate intercepts
  set_prior("normal(2, 1)", class = "b", dpar = "bs"), #boundary sep
  set_prior("normal(0.0, 0.5)", class = "b", dpar = "bias"),
  set_prior("normal(-5, 0.5)", class = "Intercept", dpar = "ndt"))


tmp_dat <- make_standata(formula,
                         family = wiener(link_bs = "log",
                                         link_bias = "logit",
                                         link_ndt = "log"),
                         data = dp, prior = prior,
                         chains = n_chains)
str(tmp_dat, 1, give.attr = FALSE)

initfun <- function() {
  list(
    b = c(rnorm(tmp_dat$K/2, 0, 1), rnorm(tmp_dat$K/2, 0, 0.1)),
    b_bs = c(runif(tmp_dat$K_bs/2, 0.5, 1), runif(tmp_dat$K_bs/2, 0, 0.1)),
    Intercept_ndt = -10,
    b_bias = rnorm(tmp_dat$K_bias, 0.0, 0.1)
    #sd_1 = runif(tmp_dat$M_1, 0.5, 1),
    #z_1 = matrix(rnorm(tmp_dat$M_1*tmp_dat$N_1, 0, 0.01),
   #              tmp_dat$M_1, tmp_dat$N_1),
  #  L_1 = diag(tmp_dat$M_1)
  )
}

fit_wiener <- brm(formula,
                  data = dp,
                  family = wiener(link_bs = "log",
                                  link_bias = "logit",
                                  link_ndt = "log"),
                  sample_prior = "only",
                  prior = prior,
                  inits = initfun,
                  iter = n_iter,
                  chains = 1, cores = 1,
                  control = list(max_treedepth = 15, adapt_delta = 0.9))

# saveRDS(fit_wiener, "level3_prior.model")
fit_wiener <- readRDS("level3_prior.model")


pred_wiener <- dp %>% add_predicted_draws(fit_wiener, negative_rt = TRUE, ndraws = 100)
write_csv(pred_wiener, "prior_predictions_full.csv")

ggplot(pred_wiener, aes(.prediction, fill = type)) + 
  geom_density(bw =0.01) + 
  facet_wrap(~ targ ) + 
  coord_cartesian(xlim = c(-5, 5))



%>%
  ungroup() %>%
  select(-.chain, -.draw, -.iteration, -.row) %>%
  mutate(rt = if_else(response == 1, rt, -rt)) %>%
  pivot_longer(c(rt, .prediction), names_to = "emp_pre", values_to = "rt") %>%
  select(-response, -accuracy) %>%
  mutate(emp_pre = fct_recode(emp_pre, empirical = "rt", prediction = ".prediction"),
                              response = if_else(rt < 0, "absent", "present"),
                              response = as_factor(response),
                              accuracy = response == targ,
                              rt = abs(rt))
