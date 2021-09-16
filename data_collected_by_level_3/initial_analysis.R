cbPalette <- c("#4477AA", "#CC6677")#,"#4477AA", "#CC6677","#4477AA", "#CC6677","#4477AA", "#CC6677")#"#4477AA", "#CC6677")
library(ggplot2)
library(dplyr)
library(tidyr)
library(dplyr)
library(plyr)
library(readr)
library(tidyverse)
library(knitr)
library(kableExtra)
library(Rmisc)
mydir=setwd("C:/Users/Marcin/Documents/GitHub/simpleConjunction/data_collected_by_level_3")
myfiles = list.files(path=mydir, pattern="*.csv", full.names=TRUE)
dat_csv = ldply(myfiles, read_csv)
dat_csv %>% dplyr::select(rt="key_resp.rt",accuracy="key_resp.corr",targetType="targetName",numDist="numDist",observer="participant",targetPres="targPres",age="age",sex="sex",n="trials.thisN")%>%
             dplyr::filter(targetType=="greenverival" | targetType=="redHorizontal" )%>%
                    dplyr::mutate(targetType = fct_recode(targetType, greenVertical = "greenverival", redHorizontal = "redHorizontal"),
                                  observer= as.factor(observer),
                                  targetType= as.factor(targetType),
                                  targetPres= as.factor(targetPres),
                                  numDist= as.factor(numDist),
                                  numDist = fct_recode(numDist, "0" ="1",
                                                                 "3" ="4",
                                                                 "9"= "10",
                                                                  "15"="16"),
                                  observer = fct_recode(observer,"34"="Nathan Crush"))->totalDat
write.table(totalDat, "Rt_accuracy_extracted.txt", sep=",",row.names = F)
#looking at accuracy data
totalDat %>% group_by(targetPres) %>%
 dplyr::summarise(accuracy = mean(accuracy), .groups = 'drop')%>% 
  knitr::kable("simple",caption="accuracy data")
  write.table(acc_wide, "accuracy_summary.txt", sep=",",row.names = F)

totalDat %>% group_by(observer, targetType, targetPres) %>%
  dplyr::summarise(accuracy = mean(accuracy), .groups = 'drop') %>%
  ggplot(aes(x = targetType, y = accuracy*100, colour = targetPres)) +
  geom_boxplot(alpha = 0.25) +
  theme_bw() + facet_wrap(~targetType)+
  scale_y_continuous(limits = c(50, 100), name="accuracy (%)") +
  theme(legend.position="none")-> p_acc_targPres
ggsave("C:/Users/Marcin/Documents/GitHub/dataLevel3/plots/accuracy.png", p_acc_targPres, width = 6, height = 6)

#reaction time data
#Exclusions 
#Remove from RT analysis all RTs >3 seconds, and all incorrect RTs
#Any person with >15% of trials with RTs >3s
#Any person with >15% error rate:  subject 25

totalDat %>% 
  dplyr::mutate(observer= as.numeric(observer))%>%
  dplyr::filter(!observer %in% c("25","56","79"))%>%
  dplyr::mutate(observer= as.factor(observer),
                targetPres = fct_recode(targetPres, absent = "0", present = "1"))%>%
  filter( 
    accuracy == 1,
    rt<3)->dataS
summarydata<-summarySEwithin(dataS,measurevar = "rt", withinvars = c("numDist","targetType","targetPres"), idvar = "observer")
                   #rt_ci   = 1.96 * sd(rt)/sqrt(n()))%>%

  ggplot(summarydata, aes(x=numDist, y = rt, group=targetPres, shape=targetPres, colour=targetPres)) +
  geom_line(size=1)+
  geom_errorbar(aes(ymin=rt-ci, ymax=rt+ci), width=.2,
                position=position_dodge(.1))+
  facet_wrap(~targetType)+labs(color="target status", x="number of distractors", y="rt(s)")+
    theme(legend.position=c(0.88,0.19))->rt_slope_2
ggsave("C:/Users/Marcin/Documents/GitHub/dataLevel3/plots/rtSlope.png", rt_slope_2, width = 5, height = 3)


  
totalDat %>% 
  dplyr::mutate(observer= as.character(observer))%>%
  dplyr::filter(!observer %in% c("25","56","79"))%>%
  dplyr::mutate(observer= as.factor(observer))%>%
  filter( 
    accuracy == 1,
    rt<3) %>%	
  dplyr::group_by(observer, targetPres, numDist,targetType) %>% 
  dplyr::summarise(median_rt = median(rt), .groups = 'drop')%>%
  pivot_wider(names_from = c("targetType", "numDist","targetPres"), 
              values_from = median_rt,
              names_sep = "_")->data_wide
  write.table(data_wide, "rt_summary.txt", sep=",",row.names = F)
  ggplot(aes(x = targetPres, y = median_rt,color=targetPres)) + 
  geom_boxplot(alpha = 0.25,show.legend = FALSE) +
  geom_jitter(color="black", size=0.4, alpha=0.9)+
  facet_grid(targetPres~numDist) +
  theme_bw() -> p_rt
ggsave("C:/Users/Marcin/Documents/GitHub/dataLevel3/plots/Rt for different target numbers.png", p_rt, width = 8, height = 5)


 
 totalDat %>% dplyr::group_by(observer,targetPres) %>%
   filter(accuracy=='1') %>%
   dplyr::summarize(medianRT=median(rt),na.rm=TRUE)%>%
   ggplot(aes(x = targetPres, y = medianRT,color=targetPres)) + 
   geom_boxplot(alpha = 0.25,show.legend = FALSE) +
   geom_jitter(color="black", size=0.4, alpha=0.9)+
   theme_bw() -> p_rt_total
 ggsave("C:/Users/Marcin/Documents/GitHub/dataLevel3/plots/rt_total.png", p_rt_total, width = 8, height = 5)

  totalDat %>% group_by(observer, targetType, targetPres,numDist) %>%
   dplyr::summarise(medianRT = median(rt), .groups = 'drop') %>%
   ggplot(aes(x = targetType, y = medianRT, colour = targetType)) +
   geom_boxplot(alpha = 0.25) +
   facet_grid(targetPres~numDist) +
   theme_bw()  + labs(fill = "condition")+
   scale_y_continuous(limits = c(0, 2), name="rt(s)")  -> p_rt_targPres
  ggsave("C:/Users/Marcin/Documents/GitHub/dataLevel3/plots/rt_all_conditions.png", p_rt_targPres, width = 8, height = 5)
  
  #
  install.packages('rmcorr')
  library(rmcorr)
  
  totalDat %>% dplyr::group_by(targetType,observer,targetPres) %>%
    filter(accuracy=='1') %>%
    dplyr::summarize(medianRT=median(rt),na.rm=TRUE)%>%
    pivot_wider(
      names_from = targetType, 
      values_from = medianRT)->data_corr
  rmc.out <- rmcorr(observer,
                    greenVertical, redHorizontal, data_corr, CIs =
                      c('analytic', 'bootstrap'), nreps = 100,
                    bstrap.out = F)
  jpeg("rplot.jpg")
   plot(rmc.out, data_corr, overall = T, palette
       = NULL, xlab = NULL, ylab = NULL,
       overall.col = 'gray60', overall.lwd = 3,
       overall.lty = 2)
 dev.off()
  
    ggplot( aes(x=greenVertical, y=redHorizontal, color=targetPres)) + geom_point(shape=1) +
    scale_colour_hue(l=50) + # Use a slightly darker palette than normal
    geom_smooth(method=lm,   # Add linear regression lines
                se=FALSE,    # Don't add shaded confidence region
                fullrange=TRUE) ->p_corr
  ggsave("C:/Users/Marcin/Documents/GitHub/dataLevel3/plots/corr_red_green.png", p_corr, width = 8, height = 8)
  