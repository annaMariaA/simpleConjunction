plt_cors <- function(cp, param_to_plot) {
  
 
  cp <- get_cor_data(cp, param_to_plot)
  
  
  if ("target" %in% names(cp)) {
    plt <- ggplot(cp, aes(x = .value, y = target, fill = p_not_zero)) +
      ggridges::geom_density_ridges(alpha = 0.5)  
    
  } else {
    plt <- ggplot(cp, aes(x = .value, fill = p_not_zero)) +
      geom_density(alpha = 0.5)
    
  }
  
  plt <- plt + 
    geom_vline(xintercept = 0, linetype = 2) + 
    scale_fill_viridis_d("prob > 0", drop=FALSE) +
    scale_x_continuous("estimated correlation coefficent") +
    theme_bw() + 
    theme(axis.title.y = element_blank(), legend.position = "bottom") 
  
  if ("slope" %in% unique(cp$slope)) {
    plt <- plt + facet_grid(. ~ slope)
  } else {
    #plt <- plt + facet_wrap(~comparison, nrow = 1)
  }
  
  return(plt)
  
}


get_cor_data <- function(cp, param_to_plot) {
  
  if (param_to_plot == "drift rate") {
    
    cp %>% filter(!str_detect(var, "(_bs_|_bias_|_ndt_)"), str_detect(var, ":nD.+:nD")) %>%
      separate(var, 
               into = c("cor", "obs", "targ1", "paradigm1", NA, "targ2", "paradigm2", NA)) %>%
      filter(targ1 == targ2) %>%
      mutate(target =  str_remove_all(targ1, "targ"),
             paradigm1 = paste0(paradigm1, ":nD"),
             paradigm2 = paste0(paradigm1, ":nD")) -> cp_slopes
    
    cp %>% filter(!str_detect(var, "(_bs_|_bias_|_ndt_)"), !str_detect(var, ":nD")) %>%
      separate(var, 
               into = c("cor", "obs", "targ1", "paradigm1", "targ2", "paradigm2")) %>%
      filter(targ1 == targ2) %>%
      mutate(target =  str_remove_all(targ1, "targ")) -> cp_intercepts
    
    cp <- bind_rows(cp_slopes, cp_intercepts) %>%
      mutate(param = "drift rate")
    rm(cp_slopes, cp_intercepts)
    
  } else{
    
    str_to_match <- paste0("_", param_to_plot, ".*_", param_to_plot)
    cp %>% filter(str_detect(var, str_to_match )) %>%
      separate(var, 
               into = c("cor", "obs", "param", "paradigm1",  NA,  "paradigm2"),
               sep = "_+") -> cp
    rm(str_to_match)
  }
  
  cp %>% filter(paradigm1 != paradigm2) %>%
    mutate(comparison = paste(paradigm1, paradigm2)) %>%
    mutate(comparison = str_remove_all(comparison, "type")) %>%
    mutate(slope1 = str_detect(paradigm1, ":nD"), 
           slope2 = str_detect(paradigm2, ":nD"),
           comparison = str_remove_all(comparison, ":nD")) %>%
    filter(slope1 == slope2) %>%
    mutate(slope = slope1,
           slope = if_else(slope, "slope", "intercept")) %>% 
    select(-slope1, -slope2) -> cp
  
  return(cp)
  
}

plot_model_params <- function(m, param_to_plot) {
  
  ###########################################
  # get fixed effects
  ###########################################
  m %>% gather_draws(`b.*`, regex = TRUE) %>%
    rename(var = ".variable") %>%
    mutate(var = str_remove(var, "b_")) -> md
  
  # extract relavant param
  if (param_to_plot == "drift rate")     {
    
    md <- filter(md, !str_detect(var, "(bs|bias|ndt)_"))
    
  }   else     {
    
    param_to_plot_ <- paste(param_to_plot, "_", sep = "")
    md <- filter(md, str_detect(var, param_to_plot_)) %>%
      mutate(var = str_remove(var, param_to_plot_))
    
    rm(param_to_plot_)
    
  }
  
  # work out which coefs to split into
  coefs <- unlist(str_extract_all(md$var[1], "(targ|type)"))
  
  md %>% mutate(param = if_else(str_detect(var, "nD"), "slope", "intercept"),
                var = str_remove(var, ":nD"),
                var = str_remove_all(var, "targ|type")) -> md
  
  if (length(coefs) > 1) {
    md <- separate(md, var, coefs) 
  } else {
    md <- rename(md, !!coefs:=var)
  }
  
  md %>% select(-.chain, -.iteration) %>%
    pivot_wider(names_from = "param", values_from = ".value")  -> samples
  
  rm(md, coefs)
  
  ###########################################
  # get participant level effects
  ###########################################
  
  prm_str <- ifelse(param_to_plot == "drift rate", 
                    "r_obs\\[.*",
                    paste("r_obs__", param_to_plot, "\\[.*", sep = "") )   
  
  m %>% gather_draws( !!sym(prm_str), regex = TRUE) %>%
    separate(.variable, into = c("participant", "var"), sep = ",") %>%
    mutate(
      obs = parse_number(participant),
      param = str_extract(participant, param_to_plot),
      param = if_else(is.na(param), "drift rate", param),
      var = str_remove(var, "\\]"),
      var = if_else(str_detect(var, "nD"), var, paste(var, ":intercept", sep=""))) %>%
    select(-participant) -> md
  
  ## check to see if we have slopes with difficulty
  using_slopes <- sum(str_detect(md$var, ":nD")) > 0
  
  coefs <- c(unlist(
    str_extract_all(md$var[1], "(targ|type)")), 
    "var")
  
  md %>% mutate(var = str_remove_all(var, "type|targ")) %>%
    separate(var, coefs) -> md
  
  if ("targ" %in% coefs) {
    
    md  %>% group_by(param, targ, type, var, obs) -> md
  } else {
    md  %>% group_by(param, type, var, obs) -> md
  }
  
  md %>%
    summarise(value = mean(.value), .groups = "drop") %>%
    pivot_wider(names_from = var, values_from = "value") -> md 
  
  if (using_slopes) {
    if ("targ" %in% names(md)) {
      md %>% rename(z_slo = "nD", z_int = "intercept") %>%
        left_join(samples %>% group_by(targ, type) %>%
                    summarise(intercept = mean(intercept),
                              slope = mean(slope)),
                  .groups = "drop") %>%
        mutate(slope = slope + z_slo,
               intercept =  intercept + z_int) %>% #  
        select(param, targ, type, obs, intercept, slope) %>% 
        rename(participant = "obs") %>%
        mutate(participant = as.factor(participant)) -> samples_p
      
    } else {
      md %>% rename(z_slo = "nD", z_int = "intercept") %>%
        left_join(samples %>% group_by(type) %>%
                    summarise(intercept = mean(intercept),
                              slope = mean(slope)),
                  .groups = "drop") %>%
        mutate(slope = slope + z_slo,
               intercept =  intercept + z_int) %>% #  
        select(param, type, obs, intercept, slope) %>% 
        rename(participant = "obs") %>%
        mutate(participant = as.factor(participant)) -> samples_p
      
    }
    
  } else  {
    if ("targ" %in% names(md)) {
      md %>% rename( z_int = "intercept") %>%
        left_join(samples %>% group_by(type, targ) %>%
                    summarise(intercept = mean(intercept)),
                  .groups = "drop")   %>%
        mutate(intercept =  intercept + z_int) %>% #  
        select(param, targ, type, obs, intercept) %>% 
        rename(participant = "obs") %>%
        mutate(participant = as.factor(participant),
               type = str_remove(type, "type")) -> samples_p
    } else {
      md %>% rename( z_int = "intercept") %>%
        left_join(samples %>% group_by(type) %>%
                    summarise(intercept = mean(intercept)),
                  .groups = "drop")   %>%
        mutate(intercept =  intercept + z_int) %>% #  
        select(param, type, obs, intercept) %>% 
        rename(participant = "obs") %>%
        mutate(participant = as.factor(participant),
               type = str_remove(type, "type")) -> samples_p
      
      }
    
    md
    
  }
  
  
  ###########################################
  # now plot!
  ###########################################
  
  if (using_slopes) {
    plt <- plot_slopes(samples, samples_p, param_to_plot)
  } else {
    plt <- plot_density(samples, samples_p, param_to_plot)
    
  }
  
  return(plt)
  
}

plot_slopes <- function(samples, samples_p, param_to_plot) {
  
  samples <- bind_rows(
    samples %>% mutate(participant = "fixd"), 
    samples_p)
  
  r <- map_dfr(1:nrow(samples), linear_pred, samples)
  
  if ("targ" %in% names(r)) {
   ggplot(r, aes(x = x, y = rate, fill = type, group = targ)) +
    geom_path(data = filter(r, participant != "fixd"), 
              aes(colour = type, group = interaction(targ, type,participant)),
              alpha = 0.5, linetype = 2) -> plt
    }  else {
    ggplot(r, aes(x = x, y = rate, fill = type)) +
    geom_path(data = filter(r, participant != "fixd"), 
              aes(colour = type, group = interaction(type,participant)),
              alpha = 0.5, linetype = 2) -> plt
    }
  
  plt + geom_hline(yintercept = 0) +
    stat_lineribbon(data = filter(r, participant == "fixd"), 
                    .width = c(0.53, 0.89, 0.97), 
                    alpha = 0.5) -> plt 
    
# 
  #  plt <- plt + facet_wrap(targ~type)
 # } else  {
    plt <- plt + facet_wrap(~type)
    
 # }
  plt + 
    theme_bw() + 
    scale_x_continuous("number of distracters") +
    scale_y_continuous(param_to_plot) +
    scale_fill_manual(values = c("#228833", "#EE6677")) + 
    scale_color_manual(values = c("#228833", "#EE6677")) +
    theme(legend.position = "none") -> plt
  
}

plot_density <-  function(samples, samples_p, param_to_plot) {
  
  samples %>% 
    ggplot(aes(x = intercept, fill = type)) + 
    geom_vline(xintercept = 0, linetype = 2) + 
    geom_density(alpha = 0.33) + 
    geom_jitter(data = samples_p, 
                aes(colour = type, y=-0.5), height = 0.1, alpha = 0.4) +
    theme_bw() +
    scale_x_continuous(param_to_plot) +
    scale_y_continuous("density") + 
    scale_fill_manual(values = c("#228833", "#EE6677")) + 
    theme(legend.position = "none") + 
    scale_color_manual(values = c("#228833", "#EE6677")) -> plt
  
  if ("targ" %in% names(samples)) {
    plt <- plt + 
      facet_wrap(~targ)
  }
  
  return(plt)
  
}

linear_pred <- function(ii, d) {
  
  x = seq(0, 1, 0.2)
  
  if ("targ" %in% names(d)) {
    out <- tibble(
      participant = d$participant[ii],
      targ = d$targ[ii],
      type = d$type[ii],
      x  =   seq(0, 1, 0.2),
      rate = d$intercept[ii] + x * d$slope[ii] )
  } else {
    out <- tibble(
      participant = d$participant[ii],
      type = d$type[ii],
      x  =   seq(0, 1, 0.2),
      rate = d$intercept[ii] + x * d$slope[ii])
    
  }
  
  return(out)
  
}