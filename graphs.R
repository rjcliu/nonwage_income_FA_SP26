#=======================================#
#=== Charts for IDDA content nuggets====#
#=======================================#

# clear objects
rm(list = ls())

# load packages 
library(data.table)
library(tidyverse)
library(collapse)
library(ggplot2)
library(ggrepel)
library(maps)
library(extrafont)
library(tidycensus)
library(tidyverse)
library(fredr)
library(ggpattern)
library(colorspace)
library(forcats)

setwd('C:/Users/IRRJL01/Dropbox/nuggets')

raw <- paste0(getwd(),'/raw/')
out <- paste0(getwd(),'/out/')

in_tm <- fread(paste(raw,"transition_matrix_all_data.csv",sep = ""))
in_pctls <- fread(paste(raw,'pctl_of_inc_all_data.csv',sep = '')) 

state_pop <- fread('C:/Users/IRRJL01/Dropbox/personal/IDDA/nuggets/data/2019_state_populations.csv') 
setnames(state_pop, old = 'STATE', new = 'geo_var_val') 


# Save objects for chart formatting 
frm_colors <- c("#003b5c", "#cfb023", "#49c5b1", "#298fc2", "#75787b", "#ff6a39", "#71c538", "#f3dd6d",
                "#00968f", "#007367", "#a4123f", "#582c83")


theme_nugget <- function() { 
  theme(panel.background = element_rect(fill = "white"),
        plot.background = element_rect(fill = "white"),
        panel.border = element_rect(color = "grey20",fill = NA, linewidth = 0.15),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = "grey90", linewidth = 0.15),
        plot.margin = margin(l=0.1,r=0.1,t=0.1,b=0.1, unit = "cm")) +
  theme(axis.text.x = element_text(size = 12, color = "black"),
        axis.title.x = element_text(size = 12, color = "black"),
        axis.line.x = element_line(color = "grey20", linewidth = 0.15),
        axis.ticks.x=element_blank())+
  theme(axis.line.y = element_line(color = "grey20", linewidth = 0.15),
        axis.ticks.y = element_blank(),
        axis.text.y = element_text(size = 12, color = "black"))+
  theme(text = element_text(family = "Barlow SemiBold")) 
}


#NWI, 1998 vs 2019, paired columns 

fig2 <- in_pctls[inc_var == "NW" & geo_var == "usst" & group_var_val == '65plus'] 


fig2 <- fig2[,.(year,pctl10_adj,pctl50_adj,pctl90_adj)]

fig2 <- melt(fig2, 
             c('year'),
             variable.name = 'pctl')

fig2 %>%
  ggplot(mapping = aes(x = year, y = value, color = pctl)) +
  geom_point() +
  geom_line() +
  theme_nugget() +
  scale_y_continuous(labels = scales::dollar) +
  scale_color_manual(values = frm_colors[1:3], 
                     name = '', 
                     labels= c(  'pctl90_adj' = 'p90','pctl50_adj' = 'p50', 'pctl10_adj' = 'p10'),
                     breaks = c('pctl90_adj','pctl50_adj','pctl10_adj')) +
  ylab('Nonwage income, 65+')


fig3 <- in_pctls[inc_var == "NW" & year %in% c(1998,2019) & geo_var == "usst" & group_var_val == "65plus"]

vars <- c("year","pctl10_adj","pctl25_adj","pctl50_adj","pctl75_adj", "pctl90_adj", "pctl95_adj")


fig3 <- melt(
  fig3[,..vars],
  id.vars = "year",
  variable.name = "percentile",
  value.name = "value"
)

fig3[, percentile := gsub("_adj","",percentile)]
fig3[, percentile := gsub("pctl","",percentile)]
  

f3<- fig3 %>%
  ggplot(mapping = aes(x = percentile, y = value, fill = as.factor(year))) +
  geom_col(position = position_dodge()) +
  scale_fill_manual(values = frm_colors) +
  theme(panel.background = element_rect(fill = "white"),
        plot.background = element_rect(fill = "white"),
        panel.border = element_rect(color = "grey20",fill = NA, linewidth = 0.15),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = "grey90", linewidth = 0.15),
        plot.margin = margin(l=0.1,r=0.1,t=0.1,b=0.1, unit = "cm"))+
  guides(color = guide_legend(byrow = TRUE))+
  theme(axis.text.x = element_text(size = 12, color = "black"),
        axis.title.x = element_text(size = 12, color = "black"),
        axis.line.x = element_line(color = "grey20", linewidth = 0.15),
        axis.ticks.x=element_blank())+
  theme(axis.line.y = element_line(color = "grey20", linewidth = 0.15),
        axis.ticks.y = element_line(color = "grey20", linewidth = 0.15),
        axis.text.y = element_text(size = 12, color = "black"))+
  theme(text = element_text(family = "Barlow SemiBold")) +
  scale_y_continuous(labels = scales::dollar) +
  labs(fill = "year") +
  ylab("") +
  ggtitle("Nonwage income, usst, 65+")

ggsave(filename = paste0(out,"/fig3.png"),plot = f3, 
       height = 5.5, width = 7, units = "in", device = png) 



#State distribution of NW income for 65+ 


state_pops <- fread("J:/RES-PA/Institute/IDDA/content_nuggets/code/2019_state_populations.csv")
state_pops <- state_pops[,geo_var_val := STATE]
state_pops <- state_pops[,c("geo_var_val","POPESTIMATE2019")]


fig3 <- in_pctls[inc_var == "NW" & year == "2019" & geo_var == "state" & group_var_val == "65plus" & geo_abb != "DC"]


fig3 %>%
  ggplot(mapping = aes(x = fct_reorder(geo_abb, pctl50), y = pctl50_adj)) +
  geom_col(fill = '#003b5c') +
  coord_flip() +
  geom_text(aes(label = geo_abb), size = 4, nudge_y = 5000, nudge_x = 0.1) +
  xlab('') +
  theme_nugget() +
  scale_y_continuous(labels = scales::dollar) +
  ylab('Median real nonwage income for individuals aged 65+ (2019)') + 
  theme(axis.text.y = element_blank()) +
  theme(legend.position = c(0.9, 0.1))


fig3 %>%
  ggplot(mapping = aes(x = fct_reorder(geo_abb, pctl90), y = pctl90_adj)) +
  geom_col(fill = '#003b5c') +
  geom_point(aes(y = pctl50_adj, color = 'median')) +
  coord_flip() +
  geom_text(aes(label = geo_abb), size = 4, nudge_y = 5000, nudge_x = 0.1) +
  xlab('') +
  scale_color_manual( 
    name = "",
    values = c('median' = "#f3dd6d")) +
  theme(axis.text.y = element_blank(),
        axis.ticks.y = element_blank(), 
        panel.background = element_rect(fill = "white"),
        plot.background = element_rect(fill = "white"),
        panel.border = element_rect(color = "grey20",fill = NA, linewidth = 0.15),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = "grey90", linewidth = 0.15),
        plot.margin = margin(l=0.1,r=0.1,t=0.1,b=0.1, unit = "cm"))+
  theme(axis.line.x = element_line(color = "grey20", linewidth = 0.15),
        axis.ticks.x = element_line(color = "grey20", linewidth = 0.15),
        axis.text.x = element_text(size = 12, color = "black")) +
  theme(legend.background = element_rect(color = "grey20", size = 0.5)) +
  scale_y_continuous(labels = scales::dollar) +
  ylab('90th percentile of real nonwage income for individuals aged 65+ (2019)') + 
  theme(legend.position = c(0.9, 0.1))

nw_retired <- in_pctls[inc_var == "NW" & group_var_val == "65plus" & geo_abb != "DC" & geo_var == 'state' & year == 2019]
ws_oldworkers <- in_pctls[inc_var == "TC" & group_var_val == "55to64" & geo_abb != "DC" & geo_var == 'state' & year == 2019]

fig4 <- lapply(list(nw_retired,ws_oldworkers), 
               function(dt) { 
                 dt[,.(geo_abb,pctl50_adj,inc_var)] 
                 dcast(dt, 
                       geo_abb ~ inc_var,
                       value.var = 'pctl50_adj')
                 }
              )
fig4 <- Reduce(function(x,y) merge(x,y,by = 'geo_abb', all = TRUE), fig4)

fig4 %>%
  ggplot(mapping = aes(x = TC, y = NW)) +
  geom_point() +
  geom_text(aes(label = geo_abb),nudge_x = 800, nudge_y = 400) +
  theme_minimal() +
  scale_y_continuous(labels = scales::dollar) +
  scale_x_continuous(labels = scales::dollar) +
  xlab('Median total compensation, 55-64 year olds') +
  ylab('Median nonwage income, 65 plus') + 
  theme(panel.background = element_rect(fill = "white"),
        plot.background = element_rect(fill = "white"),
        panel.border = element_rect(color = "grey20",fill = NA, linewidth = 0.15),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = "grey90", linewidth = 0.15),
        plot.margin = margin(l=0.1,r=0.1,t=0.1,b=0.1, unit = "cm")) +
  theme(axis.text.x = element_text(size = 12, color = "black"),
        axis.title.x = element_text(size = 12, color = "black"),
        axis.line.x = element_line(color = "grey20", linewidth = 0.15),
        axis.ticks.x=element_blank())+
  theme(axis.line.y = element_line(color = "grey20", linewidth = 0.15),
        axis.ticks.y = element_blank(),
        axis.text.y = element_text(size = 12, color = "black"))+
  theme(text = element_text(family = "Barlow SemiBold")) + 
  theme(plot.background = element_blank())



gi_oldworkers <- in_pctls[inc_var == "GI" & group_var_val == "55to64" & geo_abb != "DC" & geo_var == 'state' & year == 2019]

fig5 <- lapply(list(nw_retired,gi_oldworkers), 
               function(dt) { 
                 dt[,.(geo_abb,geo_var_val,pctl90_adj, pctl25_adj,inc_var)] 
                 dt[,p9025 := pctl90_adj/pctl25_adj]
                 dcast(dt, 
                       geo_abb + geo_var_val ~ inc_var,
                       value.var = 'p9025')
               }
)
fig5 <- Reduce(function(x,y) merge(x,y,by = c('geo_abb','geo_var_val'), all = T), fig5)

fig5 <- state_pop[fig5, on = 'geo_var_val']

fig5 %>%
  ggplot(mapping = aes(x = GI, y = NW, size = POPESTIMATE2019)) +
  geom_point(color = '#003b5c') +
  theme_minimal() +
  scale_x_continuous(breaks = seq(0,14,by = 2), limits = c(0,8)) + 
  scale_y_continuous(breaks = seq(4,14,by = 2), limits = c(4,14)) +
  xlab('Ratio of gross income, 55-64 year olds') +
  ylab('Ratio of nonwage income, 65 plus') +
  theme(legend.position = 'none')  + 
  theme_nugget() + 
  theme(plot.background = element_blank())



inc_retired_xred <- in_pctls[group_var == "xagedXrea" & inc_var %in% c('WS','NW') & geo_var == "usst" & year == 2019 & grepl("65plus", group_var_val)]
fig6 <- dcast(inc_retired_xred, 
                               group_var_val ~ inc_var,
                               value.var = 'pctl50_adj')
fig6[,race := sub(".*_(.*)$", "\\1", group_var_val)]
fig6[,xrea := sub("^[^_]*_", "", group_var_val)]

fig6 %>%
  ggplot(mapping = aes(x = NW, y = WS)) +
  geom_point(aes(shape = xrea)) +
  theme_nugget() +
  scale_x_continuous(labels = scales::dollar) +
  scale_y_continuous(labels = scales::dollar) +
  xlab('Median household nonwage income, 65+') +
  ylab('Median household wage and salary income, 65+')

#load in probability of living with at least one working aged individual conditional on being retired
hhcomp <- fread('C:/Users/IRRJL01/Dropbox/personal/IDDA/nuggets/data/hhcomp_retired.csv')

fig7 <- hhcomp[fig6, on = 'xrea']
fig7 %>%
  ggplot(mapping = aes(x = workers, y = WS)) +
  geom_point(aes(shape = race)) + 
  theme_nugget() +
  scale_y_continuous(labels = scales::dollar)  +
  xlab('Probability of residing with a working-aged individual if age 65+') +
  ylab('Median household wage and salary income, 65+')




#legacy


vars <- c("geo_abb","geo_var_val","pctl50_adj")

fig5 <- fig5[,..vars]

fig5 <- state_pops[fig5, on = "geo_var_val"]

fig5[, quantile := cut(pctl50_adj, 
                       quantile(pctl50_adj, probs = 0:4/4), 
                       include.lowest = TRUE,
                       labels = c("<25%", "25-50%", "50-75%", ">75%"))] 

fig5[!geo_abb %in% c("MN","AK","WV"),geo_abb := ""]


f5 <- fig5 %>%
  ggplot(aes(x = pctl50_adj, y = 0, size = POPESTIMATE2019, color = as.factor(quantile))) +
  geom_point(width = 0.2, alpha = 0.5) +
  geom_text(aes(label = geo_abb), 
            vjust = -2, 
            size = 4, color = "black", family = "Barlow SemiBold") +
  scale_size_continuous(range = c(1,12)) +
  scale_color_manual(values = frm_colors) +
  scale_x_continuous( labels = scales::dollar)  +
  theme_nugget() +
  ylab("") +
  xlab("Median nonwage income (2019)") +
  guides(size = "none") + 
  labs(color = "Rank") +
  guides(color = guide_legend(byrow = TRUE))


ggsave(filename = paste0(out,"/fig5.png"),plot = f5, 
       height = 5.5, width = 7, units = "in", device = png) 



#fig 6, nonwage by race, 65+ 


nwinc <- in_pctls %>%
  filter(level == "mafid" & geo_var == "usst" & group_var == "xagedXrea" & year == 2018 & (inc_var == "WS" | inc_var == "NW"))

nwinc_sub <- nwinc[grep("65", nwinc$group_var_val), ]


nwinc_sub <-  nwinc_sub %>% 
  mutate(race = case_when( 
    group_var_val == "65plus_NH_Asian" ~ "Asian", 
    group_var_val == "65plus_NH_White" ~ "White", 
    group_var_val == "65plus_NH_Black" ~ "Black",
    group_var_val == "65plus_NH_AIAN" ~ "AIAN", 
    group_var_val == "65plus_NH_NHOPI" ~ "NHOPI",
    group_var_val == "65plus_Hispanic" ~ "Hispanic")) %>%
  mutate(inc_var_str = case_when( 
    inc_var == "NW" ~ "Median nonwage income", 
    inc_var == "WS" ~ "Median wage and salary income")) 


nwinc_sub$race <- factor(nwinc_sub$race, 
                         levels = c("Hispanic",
                                    "Black",
                                    "AIAN",
                                    "NHOPI",
                                    "Asian",
                                    "White"))


order <- nwinc_sub[inc_var == "WS", c("race","pctl50_adj")]
setnames(order, old = "pctl50_adj", new = "order")

nwinc_sub <- order[nwinc_sub, on = "race"] %>%
  mutate(race = reorder(race, -order))



nw1 <- nwinc_sub %>% 
  ggplot(mapping = aes(x = race, y = pctl50_adj, fill = inc_var_str)) + 
  geom_bar(stat = "identity", position = position_dodge()) +
  scale_fill_manual(values = frm_colors) + 
  theme(panel.background = element_rect(fill = "white"),
        plot.background = element_rect(fill = "white"),
        panel.border = element_rect(color = "grey20",fill = NA, linewidth = 0.15),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = "grey90", linewidth = 0.15),
        plot.margin = margin(l=0.1,r=0.1,t=0.1,b=0.1, unit = "cm"))+
  guides(color = guide_legend(byrow = TRUE))+
  theme(axis.text.x = element_text( color = "black", size =18),
        axis.title.x = element_text(color = "black"),
        axis.line.x = element_line(color = "grey20", linewidth = 0.15),
        axis.ticks.x=element_blank())+
  theme(axis.line.y = element_line(color = "grey20", linewidth = 0.15),
        axis.ticks.y = element_line(color = "grey20", linewidth = 0.15),
        axis.text.y = element_text(color = "black", size = 18), 
        axis.title.x = element_text(margin = margin(t = 10))) +
  theme(text = element_text(family = "Barlow SemiBold")) + 
  theme(strip.background = element_blank(), 
        strip.text = element_blank(),
        axis.text.y = element_text(color = "black"),
        axis.ticks.y = element_blank()) + 
  xlab("") +
  ylab("") + 
  scale_y_continuous(labels = scales::dollar_format(scale = .001, suffix = "K"))+
  theme(legend.title = element_blank(),
        legend.text = element_text(size = 20),
        legend.position = "bottom", 
        legend.justification = c(0,0)) + 
  guides(fill = guide_legend(nrow = 2,byrow = TRUE))

ggsave(filename = paste0(out,"/fig6.png"),plot = nw1, 
       height = 5.5, width = 7, units = "in", device = png) 


# Source for RPP: https://www.bea.gov/news/2024/real-personal-consumption-expenditures-state-and-real-personal-income-state-and  
rpp <- read.csv("J:/RES-PA/Institute/IDDA/content_nuggets/data/rpp.csv")

#BEA description: Regional price parities measure the differences in 
# price levels across states for a given year and are expressed as a percentage of the overall national price level.

rpp <- rpp %>%
  mutate(GeoFips = GeoFips/1000) %>%
  select(GeoFips,X2019)

nw_pctls <- in_pctls %>%
  filter(level == "mafid" & year == "2019" & geo_var == "state" & inc_var == "NW" & group_var_val == "65plus") 



nw_pctls <- nw_pctls %>%
  merge(rpp, by.x = "geo_var_val", by.y = "GeoFips")

nw_pctls %>%
  ggplot(mapping = aes(y = pctl50_adj, x = reorder(geo_abb,pctl50_adj))) +
  geom_col() 

nw2 <- nw_pctls %>%
  ggplot(mapping = aes(x = X2019, y= pctl50_adj)) +
  geom_point() +
  geom_smooth(method = lm) +
  geom_text(aes(label = geo_abb), nudge_x = 1) +
  theme(panel.background = element_rect(fill = "white"),
        plot.background = element_rect(fill = "white"),
        panel.border = element_rect(color = "grey20",fill = NA, linewidth = 0.15),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = "grey90", linewidth = 0.15),
        plot.margin = margin(l=0.1,r=0.1,t=0.1,b=0.1, unit = "cm"))+
  guides(color = guide_legend(byrow = TRUE))+
  theme(axis.text.x = element_text(size = 12, color = "black"),
        axis.title.x = element_text(size = 12, color = "black"),
        axis.line.x = element_line(color = "grey20", linewidth = 0.15),
        axis.ticks.x=element_blank())+
  theme(axis.line.y = element_line(color = "grey20", linewidth = 0.15),
        axis.ticks.y = element_line(color = "grey20", linewidth = 0.15),
        axis.text.y = element_text(size = 12, color = "black")) + 
  scale_y_continuous( labels = scales::dollar_format(scale = .001, suffix = "K"))+
  xlab("Regional Price Parity (BEA)") +
  ylab("") +
  ggtitle("Median nonwage income, 2019, 65+") + 
  theme(text = element_text(family = "Barlow SemiBold")) 

ggsave(plot = nw2, filename = paste0(out_path, "figures/state_nw.png"),
       height = 5.5, width =7, units = "in",  device = png)


# persistence_of_NWI_xstates <- in_tm[
#   group_var_val == "65plus" &
#     inc_var == "NW" &
#     geo_var == "state" &
#     y0 == 2014 & 
#     lag == 5 ]
# 
# probmiss <- persistence_of_NWI_xstates[pctl_y1 == "miss"]
# probmiss[,prob_nomiss := 1 - probability]
# probmiss <- probmiss[,c("geo_abb", "pctl_y0", "prob_nomiss")]
# 
# persistence_of_NWI_xstates <- persistence_of_NWI_xstates[pctl_y1 != "miss"]
# persistence_of_NWI_xstates <- probmiss[persistence_of_NWI_xstates,on = .(geo_abb, pctl_y0)]
# persistence_of_NWI_xstates <- persistence_of_NWI_xstates[,prob_rescaled := probability/prob_nomiss]
# 
# persistence_of_NWI_xstates <- persistence_of_NWI_xstates[
#   pctl_y0 == pctl_y1 & 
#     pctl_y0 %in% c("lt25","gt75")
# ]
# 
# 
# state_pops <- fread("J:/RES-PA/Institute/IDDA/content_nuggets/code/2019_state_populations.csv")
# state_pops <- state_pops[,geo_var_val := STATE]
# state_pops <- state_pops[,c("geo_var_val","POPESTIMATE2019")]
# 
# persistence_of_NWI_xstates <- state_pops[persistence_of_NWI_xstates, on = "geo_var_val"]
# 
# 
# 
# persistence_of_NWI_xstates[pctl_y0 == "lt25"] %>%
#   ggplot(aes(x = prob_rescaled, y = 0, size = POPESTIMATE2019, color = geo_abb)) +
#   geom_point(alpha = 0.5) +
#   scale_size_continuous(range = c(1,8))+
#   scale_alpha_manual(values = c(0.8, 0.4))+
#   scale_x_continuous( labels = scales::percent_format()) +
#   xlab("Persistence in bottom quartile (2014 to 2019)")+
#   ylab("")+
#   theme(panel.background = element_rect(fill = "white"),
#         plot.background = element_rect(fill = "white"),
#         panel.border = element_rect(color = "grey20",fill = NA, linewidth = 0.15),
#         panel.grid.minor = element_blank(),
#         panel.grid.major = element_line(color = "grey90", linewidth = 0.15),
#         plot.margin = margin(l=0.1,r=0.1,t=0.1,b=0.1, unit = "cm"))+
#   guides(color = guide_legend(byrow = TRUE))+
#   theme(axis.text.x = element_text(size = 12, color = "black"),
#         axis.title.x = element_text(size = 12, color = "black"),
#         axis.line.x = element_line(color = "grey20", linewidth = 0.15),
#         axis.ticks.x=element_blank())+
#   theme(axis.line.y = element_line(color = "grey20", linewidth = 0.15),
#         axis.ticks.y = element_line(color = "grey20", linewidth = 0.15),
#         axis.text.y = element_text(size = 12, color = "black"))+
#   theme(text = element_text(family = "Barlow SemiBold")) +
#   theme(legend.position = "none") 
# 
# 


