library(brms)
library(tidybayes)
library(tidyverse)
library(patchwork)

source("plot_ddm_model.R")


m <- readRDS("models/level3_full.model")

summary(m)

m %>% gather_draws(`cor.*`, regex = TRUE) %>%
  rename(var = ".variable") %>%
  mutate(var = str_remove(var, "cor_observer__")) -> cor_post 

cor_post %>% group_by(var) %>%
  summarise(p_not_zero = max(mean(.value > 0), mean(.value < 0))) %>%
  mutate(p_not_zero = cut(p_not_zero, c(0.5, 0.8, 0.9, 0.95, 0.99, 1))) %>%
  full_join(cor_post, by = "var") %>%
  select(-.chain, -.iteration , -.draw) -> cp


plt_rate_fx <- plot_model_params(m, "drift rate")
plt_rate_rn <- plt_cors(cp, "drift rate") 

plt_bs_fx <- plot_model_params(m, "bs")
plt_bs_rn <- plt_cors(cp, "bs") 

plt_bias_fx <- plot_model_params(m, "bias")
plt_bias_rn <- plt_cors(cp, "bias") 


(plt_rate_fx + plt_bs_fx + plt_bias_fx) / (plt_rate_rn + theme(legend.position = "none") + plt_bs_rn + plt_bias_rn)  + plot_layout(guides = "collect") & theme(legend.position = "none")
