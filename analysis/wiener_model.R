library(tidyverse)
library(brms)
library(tidybayes)
library(patchwork)


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

rm(tmp_dat)

fit_wiener <- readRDS("tmp.model")

#cor_idx <- get_variables(fit_wiener) %>% str_starts("cor")
#cor_name <- get_variables(fit_wiener) [cor_idx]


fit_wiener %>% gather_draws(`cor.*`, regex = TRUE) %>%
  rename(var = ".variable") %>%
  mutate(var = str_remove(var, "cor_observer__")) -> cor_post 


paradigms <- "(tex|line|greenVertical)"
vars <- c("targpresent:trial", "targabsent:trial", 
          "bias_trial", "bs_trial" )


comparison_intercepts <-  paste(vars, paradigms, "__", vars, paradigms, sep = "")
comparison_slopes <-   paste(vars, paradigms, ":difficulty__", vars, paradigms, ":difficulty", sep = "")


# intercepts

plt_cors <- function(comps, slopes = FALSE) {
  
  cor_post %>% group_by(var) %>%
    summarise(p_not_zero = max(mean(.value > 0), mean(.value < 0))) %>%
    mutate(p_not_zero = round(p_not_zero, 1),
           p_not_zero = as.factor(p_not_zero)) %>%
    full_join(cor_post) -> cp
  
  if (slopes) {
  
      cp  %>%  filter(str_detect(var, comps))  %>% 
      separate(var,   into = c("targ1", "paradigm1", "diff1", "targ2", "paradigm2", "diff2")) -> cp
    
    
  } else {
    
    cp %>%
      filter(str_detect(var, comps), !str_detect(var, "difficulty")) %>% 
      separate(var, into = c("targ1", "paradigm1", "trag2", "paradigm2")) -> cp
      
  }
  
  cp %>% mutate(comparison = paste(paradigm1, paradigm2), target = targ1) %>%
    select(target, comparison, .value, p_not_zero) %>% 
    mutate(
      target = str_remove_all(target, "targ"),
      comparison = str_remove_all(comparison, "trial")) ->  cp
  
  plt <- ggplot(cp, aes(x = .value, y= target, fill = p_not_zero)) + 
    geom_vline(xintercept = 0, linetype = 2) + 
    ggridges::geom_density_ridges(alpha = 0.5) +
    facet_wrap(~comparison) + 
    scale_fill_viridis_d("prob >< 0") +
    scale_x_continuous("estimated correlation coefficent") +
    theme_bw() + 
    theme(axis.title.y = element_blank())
  
  return(plt)
  
}

plt_cors(comparison_slopes, TRUE) + ggtitle("correlation of observer rate slopes") -> plt_cor

plt_cors(comparison_intercepts[!str_detect(comparison_intercepts, "(bias_|bs_)")]) +
  ggtitle("correlation of observer rate interecepts") -> plt_int
 
 linear_pred <- function(ii, d) {
   
   x = 1:3
   
   out <- tibble(
     participant = d$participant[ii],
     targ = d$targ[ii],
     trial = d$trial[ii],
     x  =1:3,
     rate = d$intercept[ii] + x * d$slope[ii]
   )
   
   return(out)
   
 }

# get fixed effects
fit_wiener %>% gather_draws(`b.*`, regex = TRUE) %>%
   rename(var = ".variable") %>%
   mutate(var = str_remove(var, "b_"))  %>%
  filter(!str_detect(var, "(bs|bias|ndt)_")) %>%
  mutate(param = if_else(str_detect(var, "difficulty"), "slope", "intercept"),
         var = str_remove(var, ":difficulty")) %>%
  separate(var, into = c("targ", "trial")) %>%
  mutate(targ = str_remove(targ, "targ"),
         trial = str_remove(trial, "trial")) %>% 
     pivot_wider(names_from = "param", values_from = ".value")  -> rate_samples

# get participant estimates
fit_wiener %>% gather_draws(`r_observer\\[.*`, regex = TRUE) %>%
  separate(.variable, into = c("participant", "param"), sep = ",") %>%
  mutate(param = str_remove(param, "\\]"),
         participant = str_remove(participant, "r_observer\\["),
         param = if_else(str_detect(param, "difficulty"), param, paste(param, ":intercept", sep=""))) %>%
  separate(param, c("targ", "trial", "param")) %>%
  mutate(targ = str_remove(targ, "targ"),
         trial = str_remove(trial, "trial")) %>% 
  group_by(targ, trial, param, participant) %>%
  summarise(value = mean(.value), .groups = "drop") %>%
  pivot_wider(names_from = param, values_from = "value") %>%
  rename(z_slo = "difficulty", z_int = "intercept") %>%
  left_join(rate_samples %>% group_by(targ,trial) %>%
              summarise(intercept = mean(intercept),
                        slope = mean(slope))) %>%
  mutate(slope = slope + z_slo,
         intercept =  intercept + z_int) %>%
  select(targ, trial, participant, intercept, slope) -> rate_participants

rates <- bind_rows(
  rate_samples %>% mutate(participant = "fixd"), 
  rate_participants)


map_dfr(1:nrow(rates), linear_pred, rates) -> r

ggplot(r, aes(x = x, y = rate, fill = targ)) + 
  geom_hline(yintercept = 0) +
  stat_lineribbon(data = filter(r, participant == "fixd"), .width = c(0.53, 0.89, 0.97), alpha = 0.25)  +
  geom_path(data = filter(r, participant != "fixd"), 
            aes(colour = targ, group = interaction(targ,participant)),
            alpha = 0.5, linetype = 2) + 
  facet_wrap(~trial) + 
  theme_bw() + 
  scale_x_continuous("search difficulty", breaks = 1:3, labels = c("easy", "mid","hard")) +
  scale_y_continuous("drift rate") + 
  ggthemes::scale_fill_ptol() + 
  ggthemes::scale_colour_ptol() + 
  ggtitle("fixed effects for drift rate") -> plt_rate



map_dfr(1:nrow(rate_samples), linear_pred, rate_samples) %>%
  ggplot(aes(x = x, y = rate, fill = targ)) + 
  geom_hline(yintercept = 0) +
  stat_lineribbon(.width = c(0.53, 0.89, 0.97), alpha = 0.25)  +
  facet_wrap(~trial) + 
  theme_bw() + 
  scale_x_continuous("search difficulty", breaks = 1:3, labels = c("easy", "mid","hard")) +
  scale_y_continuous("drift rate") + 
  ggthemes::scale_fill_ptol() + 
  ggtitle("fixed effects for drift rate") -> plt_rate

  
plt_rate / plt_cor / plt_int + plot_layout(guides = "collect")

ggsave("rate_param.pdf", width = 6, height = 10)
rm(rate_samples)


## plot boundary sep (bs) and bias

fit_wiener %>% gather_draws(`b.*`, regex = TRUE) %>%
  rename(var = ".variable") %>%
  mutate(var = str_remove(var, "b_"))  %>%
  filter(str_detect(var, "(bs|bias)_")) %>%
  separate(var, into = c("param", "trial")) %>%
  mutate(trial = str_remove(trial, "trial")) %>% 
  ggplot(aes(x = .value, fill = trial)) + 
  geom_density(alpha = 0.44) + 
  facet_wrap(~param, scales = "free") +
  ggthemes::scale_fill_fivethirtyeight() + 
  theme_bw()




#### plot predicted rt and acc against empirical values
NPRED <- 1
pred_wiener <- predict(fit_wiener, 
                       summary = FALSE, 
                       negative_rt = TRUE, 
                       nsamples = NPRED,
                       re_formula = NULL)
d$p <- as.numeric(pred_wiener)


## plot accuracy
d %>% mutate(
  p_rt = if_else(targ == "absent", -p, p),
  p_re = if_else(p < 0, 0, 1),
  p_ac = if_else((targ=="present")==p_re, 1, 0)) -> d

d %>%
  group_by(observer, trial, targ, difficulty) %>%
  summarise(
    accuracy = mean(accuracy),
    pred_acc = mean(p_ac)) %>% 
  pivot_longer(c(accuracy, pred_acc), names_to = "type", values_to = "accuracy") %>%
  ggplot(aes(x = difficulty, y = accuracy, colour = type, group = interaction(type,observer))) +
  geom_path() +
  facet_grid(targ~trial) +
  ggthemes::scale_colour_ptol()
ggsave("model_pred_acc.png", height = 4, width = 6)
## plot rt

d %>% filter(accuracy == 1) %>%
  group_by(observer, trial, targ, difficulty) %>%
  summarise(empirical = median(rt)) -> ed

d %>% filter(p_ac == 1)  %>%
  group_by(observer, trial, targ, difficulty) %>%
  summarise(model = median(rt)) -> pd

full_join(ed, pd) %>%
  pivot_longer(c(empirical, model), names_to= "type", values_to = "rt") %>%
  ggplot(aes(x = difficulty, y = rt, colour = type, group = interaction(type,observer))) +
  geom_path() +
  facet_grid(targ~trial) +
  ggthemes::scale_colour_ptol()
ggsave("model_pred_rt.png", height = 4, width = 6)

d %>% mutate(rt = if_else(response == 0, -rt, rt)) %>%
  pivot_longer(c(rt, p), names_to = "measure", values_to = "rt") %>%
  ggplot(aes(x = rt, fill = measure)) + 
  geom_vline(xintercept = 0) + 
  geom_density(alpha = 0.3) + 
  facet_wrap(targ ~ trial, scales="free")
