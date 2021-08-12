library(tidyverse)
library(rethinking)

options(digits = 2, mc.cores = 10)

# import, clean, and aggregate data
d <- read_csv("../data_prolific/accuracy_rt_data.txt") %>%
  mutate(
    targ_present = as_factor(targPresent),
    trial_type = as_factor(targetType),
    difficulty = as.numeric(as_factor(difficulty))) %>%
  select(observer, trial_type, targ_present, difficulty, n, rt, accuracy) %>%
  filter(accuracy == 1) %>%
  group_by(observer, trial_type, targ_present, difficulty  ) %>%
  summarise(rt = median(rt), .groups = "drop") %>%
  filter(trial_type == "line", targ_present == 1)

summary(d)

flist <- alist(
  rt ~ dnorm(mu, sigma),
  mu <- a + b*difficulty,
  a ~ dnorm(1,1), # prior for the intercept
  b ~ dnorm(0,1), # prior for the slope
  sigma ~ dexp(1) # prior for the standard deviation 
)

fit <- quap(flist, data = d)
summary(fit)

post <- rethinking::extract.samples(fit, n = 500)

ggplot() + 
  geom_point(data = d,  aes(x = difficulty, y = rt)) +
  geom_abline(data = post, aes(intercept = a, slope = b), alpha = 0.1, colour = "purple")
