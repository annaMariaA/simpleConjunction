library(tidyverse)
library(brms)
library(tidybayes)


d <- read_csv("../data_prolific/accuracy_rt_data.txt") %>%
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


summary(d)

# remove some outliers
d <- filter(d, rt > 0.2, rt < 20)

d <- filter(d, difficulty == 1)

formula <- bf(rt | dec(response) ~ 
              0 + targ:trial  + targ:trial:difficulty  +  (0 + targ:trial|p|observer), 
              bs ~ 0 + trial + (0 + trial|p|observer), 
              ndt ~ 0 + trial,
              bias ~ 0 + trial + (0 + trial|p|observer))

get_prior(formula,
          data = d, 
          family = wiener(link_bs = "identity", 
                          link_ndt = "identity", 
                          link_bias = "identity"))

prior <- c(
  prior("cauchy(0, 5)", class = "b"),
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
    b = rnorm(tmp_dat$K-1),
    b_bs = runif(tmp_dat$K_bs, 1, 2),
    b_ndt = runif(tmp_dat$K_ndt, 0.01, 0.1),
    b_bias = rnorm(tmp_dat$K_bias, 0.5, 0.1),
    sd_1 = runif(tmp_dat$M_1, 0.5, 1),
    z_1 = matrix(rnorm(tmp_dat$M_1*tmp_dat$N_1, 0, 0.01),
                 tmp_dat$M_1, tmp_dat$N_1),
    L_1 = diag(tmp_dat$M_1)
  )
}



# fit_wiener <- brm(formula,
#                   data = d,
#                   family = wiener(link_bs = "identity",
#                                   link_ndt = "identity",
#                                   link_bias = "identity"),
#                   prior = prior,
#                   inits = initfun,
#                   iter = 1000,
#                   chains = 4, cores = 4,
#                   control = list(max_treedepth = 15))
# 
# saveRDS(fit_wiener, "tmp.model")

fit_wiener <- readRDS("tmp.model")

cor_idx <- get_variables(fit_wiener) %>% str_starts("cor")
cor_name <- get_variables(fit_wiener) [cor_idx]


fit_wiener %>% gather_draws(`cor.*`, regex = TRUE) %>%
  rename(var = ".variable") %>%
  mutate(var = str_remove(var, "cor_observer__")) -> cor_post 


paradigms <- "(tex|line|greenVertical)"
vars <- c("targpresent:trial", "targabsent:trial", "bias_trial", "bs_trial" )


comparisons <-  paste(vars, paradigms, "__", vars, paradigms, sep = "")


cor_post %>% group_by(var) %>%
  summarise(p_not_zero = mean(abs(.value) > 0.1)) %>%
  mutate(p_not_zero = round(p_not_zero, 1),
         p_not_zero = as.factor(p_not_zero)) %>%
  full_join(cor_post) %>%
  filter(str_detect(var, comparisons))-> cor_post

cor_post %>% separate(var, into = c("var", "paradigm1", "var2", "paradigm2")) %>%
  mutate(comparison = paste(paradigm1, paradigm2)) %>%
  select(var, comparison, .value, p_not_zero) -> cor_post

ggplot(cor_post, aes(x = .value, y= var, fill = p_not_zero)) + 
  geom_vline(xintercept = 0, linetype = 2) + 
  ggridges::geom_density_ridges(alpha = 0.5) +
  facet_wrap(~comparison) + 
  scale_fill_viridis_d() +
  theme_bw()


NPRED <- 1
pred_wiener <- predict(fit_wiener, 
                       summary = FALSE, 
                       negative_rt = TRUE, 
                       nsamples = NPRED,
                       re_formula = NULL)
d$p <- as.numeric(pred_wiener)

d %>% mutate(rt = if_else(response == 0, -rt, rt)) %>%
  pivot_longer(c(rt, p), names_to = "measure", values_to = "rt") %>%
  ggplot(aes(x = rt, fill = measure)) + 
  geom_vline(xintercept = 0) + 
  geom_density(alpha = 0.3) + 
  facet_wrap(targ ~ trial, scales="free")
