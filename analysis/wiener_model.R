library(tidyverse)
library(brms)
library(tidybayes)
library(patchwork)


d <- read_csv("../cluster/data_for_model.csv") %>%
  mutate(
    targ = as_factor(targ)) %>%
  select(observer, trial, targ, difficulty, rt, accuracy) 

d$response <- NA
d$response[which(d$targ=="present" & d$accuracy==1)] = 1
d$response[which(d$targ=="present" & d$accuracy==0)] = 0
d$response[which(d$targ=="absent" & d$accuracy==1)] = 0
d$response[which(d$targ=="absent" & d$accuracy==0)] = 1


summary(d)


fit_wiener <- readRDS("models/wiener_fit.model")


#cor_idx <- get_variables(fit_wiener) %>% str_starts("cor")
#cor_name <- get_variables(fit_wiener) [cor_idx]


fit_wiener %>% gather_draws(`cor.*`, regex = TRUE) %>%
  rename(var = ".variable") %>%
  mutate(var = str_remove(var, "cor_observer__")) -> cor_post 


paradigms <- "(tex|ori|conj)"
vars <- c("targpresent:trial", "targabsent:trial", 
          "bias_trial", "bs_trial" )

comparison_intercepts <-  paste(vars, paradigms, "__", vars, paradigms, sep = "")
comparison_slopes <-   paste(vars, paradigms, ":difficulty__", vars, paradigms, ":difficulty", sep = "")

# intercepts

plt_cors <- function(comps, slopes = FALSE) {
  
  cor_post %>% group_by(var) %>%
    summarise(p_not_zero = max(mean(.value > 0), mean(.value < 0))) %>%
    mutate(p_not_zero = cut(p_not_zero, c(0.5, 0.8, 0.9, 0.95, 0.99, 1))) %>%
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
    scale_fill_viridis_d("prob >< 0", drop=FALSE) +
    scale_x_continuous("estimated correlation coefficent") +
    theme_bw() + 
    theme(axis.title.y = element_blank())
  
  return(plt)
  
}

plt_cor <- plt_cors(comparison_slopes, TRUE) + 
  ggtitle("correlation of observer rate slopes") 

plt_int <- plt_cors(comparison_intercepts[!str_detect(comparison_intercepts, "(bias_|bs_)")]) +
  ggtitle("correlation of observer rate interecepts") 
 
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
  select(-.chain, -.iteration) %>%
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
         intercept =  intercept + z_int) %>% #  
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


plt_rate / plt_cor / plt_int + plot_layout(guides = "collect")
ggsave("figs/rate_param.pdf", width = 6, height = 10)
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
  theme_bw() -> plt_boundary


plt_int <- plt_cors(comparison_intercepts[str_detect(comparison_intercepts, "(bias_|bs_)")]) +
  ggtitle("correlation of observer bias and boundary seperations") 

plt_boundary / plt_int + plot_layout(guides = "collect")
ggsave("figs/boundary_param.pdf", width = 6, height = 8)


#### plot predicted rt and acc against empirical values
NPRED <- 10
pred_wiener <- predict(fit_wiener, 
                       summary = FALSE, 
                       negative_rt = TRUE, 
                       nsamples = NPRED,
                       re_formula = NULL)
d$p_rt <- as.numeric(colMeans(abs(pred_wiener)))
d$p_ac <- colMeans((pred_wiener>0))
d$p_ac[which(d$targ == "absent")] <- 1 - d$p_ac[which(d$targ == "absent")]
rm(pred_wiener)



d %>%
  group_by(observer, trial, targ, difficulty) %>%
  summarise(
    accuracy = mean(accuracy),
    pred_acc = mean(p_ac)) %>%
  ggplot(aes(x = pred_acc, y = accuracy, colour = difficulty)) +
  geom_abline(linetype = 2) + 
  geom_jitter(alpha = 0.75, position = "jitter") +
  geom_smooth(method = "lm", aes(group = 1), colour = "grey") + 
  facet_grid(targ~trial) +
  scale_colour_viridis_d(end = 0.7) + 
  scale_x_continuous(breaks = c(0, 0.5, 1)) +
  scale_y_continuous(breaks = c(0, 0.5, 1)) +
  coord_fixed() -> plt_acc


## plot rt
d %>% filter(accuracy == 1) %>%
  group_by(observer, trial, targ, difficulty) %>%
  summarise(empirical = median(rt)) -> ed

d %>% filter(p_ac == 1)  %>%
  group_by(observer, trial, targ, difficulty) %>%
  summarise(model = median(rt)) -> pd

full_join(ed, pd) %>%
  ggplot(aes(x = model, y = empirical, colour = difficulty)) +
  geom_abline(linetype = 2) + 
  geom_point(alpha = 0.75) +
  facet_grid(targ~trial) +
  coord_fixed() + 
  scale_colour_viridis_d(end = 0.7) -> plt_rt

plt_acc / plt_rt + plot_layout(guides = "collect")
ggsave("figs/model_pred.png", height = 8, width = 6)


