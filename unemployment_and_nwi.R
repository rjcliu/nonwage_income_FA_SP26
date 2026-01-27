#script to calculate the relationship between the gap between state and us unemployment rate and a state's level of nonwage income 

library(data.table)
library(stringr)
library(fredr)
library(tidyverse)

rm(list = ls())


fredr_set_key('543c049f91a27203f2354783e11d04cc')


# pull NWI income pctls by state across 98-19 for one demographic group 
dt <- fread("C:/Users/IRRJL01/Dropbox/nuggets/raw/pctl_of_inc_all_data.csv")
#dt <- fread("C:/Users/richa/Dropbox/nuggets/raw/pctl_of_inc_all_data.csv")
dt <- dt[inc_var == 'NW' & geo_var == 'state' & group_var_val == '65plus']
vars <- str_split_1('year level samp inc_var geo_var geo_var_val geo_abb group_var group_var_val pctl50_adj pctl75_adj pctl90_adj', ' ')
dt <- dt[,..vars]


#pull state/usst level unemployment rates across 98-19 from Fred
state_urs <- rbindlist(lapply(paste0(unique(dt[,geo_abb]),"UR"), function(state) {
  fredr(state, frequency = 'a', observation_start = as.Date('1998-01-01'), observation_end = as.Date('2019-01-01'))
}
))

state_urs <- setDT(state_urs)

state_urs[, ':=' (year = year(date), 
                  geo_abb = str_sub(series_id,start = 1L, end = 2L), 
                  urate = value)]
state_urs[,c('realtime_start','realtime_end','date','series_id', 'value') := NULL]

us_ur <- fredr('UNRATE',frequency = 'a', observation_start = as.Date('1998-01-01'), observation_end = as.Date('2019-01-01'))
us_ur <- setDT(us_ur)
us_ur[, ':=' (year = year(date), 
              usst_urate = value)]


#merge state/usst level unemployment rates to state-level IDDA nwi pctls 
dt <- state_urs[dt,on = c('year','geo_abb')]
dt <- us_ur[,c('year','usst_urate')][dt, on = .(year)]
dt[,urate_st_fe := urate - usst_urate]

#generate change in pctl level
dt <- dt[order(geo_var_val, year)]
values <- paste0(c('pctl50','pctl75','pctl90'),'_adj')

dt[, paste0('lead_', values) := 
     lapply(.SD, function(x) shift(x, n = 1, fill = NA, type = "lead")), 
   .SDcols = values, by = 'geo_abb']

dt[, ':=' (chg_pctl50_adj = - pctl50_adj + lead_pctl50_adj,
           chg_pctl75_adj = - pctl75_adj + lead_pctl75_adj, 
           chg_pctl90_adj = - pctl90_adj + lead_pctl90_adj,
           pchg_pctl50_adj = (lead_pctl50_adj/pctl50_adj) - 1, 
           pchg_pctl75_adj = (lead_pctl75_adj/pctl75_adj) - 1, 
           pchg_pctl90_adj = (lead_pctl90_adj/pctl90_adj) - 1)]

#basic scatter

draw_grouped_scatter <- function(stat) { 
  dt[year < 2019, lapply(.SD, mean), by = .(geo_abb), .SDcols = c(stat,'urate_st_fe')] %>%
    ggplot(mapping = aes(x = urate_st_fe, y = get(stat))) +
    geom_point() +
    geom_text(aes(label = geo_abb), nudge_x = 0.2) +
    ggtitle('1-year percentage change in real NWI pctl', 
            subtitle = paste0('Averaged across 1998-2018. Sample = 65 plus filers. Stat = ',stat)) +
    xlab('Average difference in state and national unemployment rate (pp)') +
    scale_y_continuous(labels = scales::percent) +
    ylab('')
  }
draw_grouped_scatter('pchg_pctl50_adj')


dt[geo_abb == 'UT'] %>%
  ggplot(mapping = aes(x = urate_st_fe, y = pchg_pctl50_adj)) +
  geom_point()

# IN PROGRESS 

#regressing within a state, urate gap (state - usst) effect on nwi pctl
  # AKA:  y = beta1 + gap * beta2 + i.state * betavector 

basic_fit <- lm(pchg_pctl90_adj ~ (urate_st_fe + geo_abb), data = dt)
summary(basic_fit)
