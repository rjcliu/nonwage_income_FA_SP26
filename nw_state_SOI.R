library(data.table)
library(tidyverse)


rm(list = ls())

setwd("C:/Users/IRRJL01/Dropbox/personal/IDDA/nuggets")
#setwd('C:/Users/richa/Dropbox/personal/IDDA/nuggets')


# original source: https://www.irs.gov/statistics/soi-tax-stats-adjusted-gross-income-agi-percentile-data-by-state 
shares_soi_22 <- fread(paste0(getwd(),"/data/22instateshares.csv"))


incs <- c("sal","int","div","businc","cpgain","iradist","pension","scorp")
pctls <- c("01","05","10","25","50","75","total")
ids <- c("statefips","state","state_name")

vals <- setdiff(names(shares_soi_22),ids)
shares_soi_22[, (vals) := lapply(.SD, as.numeric), .SDcols = vals]

setnames(shares_soi_22,old = paste0("total_",incs,"_amt"), new = paste0("sum_",incs,"_total"))
setnames(shares_soi_22,old = 'total_agi', new = 'sum_agi_total')

#Note - the sum of AGI components in SOI data does not sum to total AGI. AKA, total(sal, int, div, businc, cpgain, iradist, pension, scorp) != total_agi
  # I'm not certain why. The summed AGI components represent ~96% of total AGI. 
  # Later down, I create another category of 'other' income to represent this missing amount
lapply(pctls, function(p) { 
  
  incs_total <- paste0("sum_",incs,"_",p)
  shares_soi_22[,paste0("agi_proxy_",p) := rowSums(.SD), .SDcols = incs_total]

  
  shares_soi_22[,paste0("sum_other_",p) := sum_agi_p - rowSums(.SD), .SDcols = incs_total, env = list(sum_agi_p = paste0("sum_agi_",p))]
  
} )

incs <- c(incs,'other')
  
shares_soi_22[statefips != 0L, inc_rank := frank(-agi_proxy_total/total)]

ids <- c("inc_rank",ids)

draw_area_agicomp <- function(p){

dt_vars <- grep(p,names(shares_soi_22),value = T)
dt_vars <- c(ids,dt_vars)

dt <- shares_soi_22[,..dt_vars]

lapply(incs, function(f) 
  dt[, paste("share",f,p,sep = "_") := 
       get(paste("sum",f,p,sep = "_"))/
       get(paste0("sum_agi_",p))])

dt <- melt(dt, 
           ids,
           grep("share",names(dt),value = T),
           variable.name = "inc",
           value.var = "share_total_agi")
dt[,pctl := p]
dt[,inc := tstrsplit(inc, "_", fixed = TRUE)[2]]
}

share_of_income_by_component <- rbindlist(
  list(draw_area_agicomp("total")[statefips == 0L], 
       draw_area_agicomp("01")[statefips == 0L]))
setnames(share_of_income_by_component,old = 'value',new = 'share_total_agi')


share_of_income_by_component[!grep('sal',inc), share_total_nw := share_total_agi/sum(share_total_agi), by = pctl]


share_of_income_by_component[inc == 'iradist', temp := share_total_nw][,temp := max(temp,na.rm = T), by = pctl]
share_of_income_by_component[inc == 'pension', share_total_nw := share_total_nw + temp]
share_of_income_by_component <- share_of_income_by_component[inc != 'iradist']
share_of_income_by_component <- share_of_income_by_component[order(pctl,share_total_nw)]


share_of_income_by_component$inc <- factor(share_of_income_by_component$inc, 
                                           levels = c('pension','businc','int','other','div','scorp','cpgain'))
g2 <- ggplot(data = share_of_income_by_component[inc != 'sal'], mapping = aes(x = pctl, y = share_total_nw, fill = inc)) + 
  geom_col(position = 'stack') + 
  ggtitle('Shares of total non-wage income, US', subtitle = 'Source: IRS') +
  scale_y_continuous(labels = scales::percent)

ggsave(paste0(getwd(),'/graphs/shares_total_nwi.png'), g2)
write.csv(g2$data, file = paste0(getwd(),'/out/shares_total_nwi.csv'))



# Draw wage and salary share of AGI by percentiles of AGI, total US, 2022 data. 

usst_soi <- shares_soi_22[statefips == 0L]

lapply(pctls, function(p) usst_soi[, paste0("share_sal_",p) := 
                                     get(paste0("sum_sal_",p))/ 
                                     get(paste0("agi_proxy_",p))])

vars <- c(ids, paste0("share_sal_",pctls))

usst_soi <- melt(usst_soi, 
                 ids, 
                 paste0("share_sal_",pctls), 
                 variable.name = "pctl", 
                 value.name = "share_sal")


usst_soi[,pctl := gsub(".*_", "", pctl)]


g2 <- usst_soi %>%
  ggplot(mapping = aes(y = share_sal, x = pctl)) +
  geom_col() +
  theme_minimal() +
  scale_y_continuous(label = scales::percent) +
  xlab("top x percent in AGI") +
  ggtitle("Wage and salary share of summed AGI", 
          subtitle = "total US, 2022. Source = IRS, Statistics of Income Division.") +
  theme(legend.position = "none") +
  ylab("")

ggsave(paste0(getwd(),"/graphs/bar_wsishare_xpctl.png"), g2)


#scatter total dividend/capital gains 
soi <- rbindlist(lapply(13L:22L, function(y) { 
  dt <- fread(paste0(getwd(),'/data/',y,'instateshares.csv'))
  dt <- dt[statefips ==0L]
  dt <- dt[, .(total_div_amt,total_cpgain_amt)]
  dt[, year := (y+2000L)]
  return(dt)
  
}))

soi[year %in% c(2014L, 2016L, 2017L), total_div_amt := total_div_amt/1000]
soi[year %in% c(2014L, 2016L, 2017L), total_cpgain_amt := total_cpgain_amt/1000]

sp <- fredr('NASDAQCOM', frequency = 'a', observation_start = as.Date('2013-01-01'))
sp<- setDT(sp)
sp <- sp[, year := year(date)]


soi <- sp[,.(year,value)][soi, on = 'year']


soi[,finan_inc := total_div_amt + total_cpgain_amt]

ggplot(data = soi, mapping = aes(x = value, y = finan_inc)) +
  geom_point()

