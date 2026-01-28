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

#rename cols so that columns follow identical naming format of 'sum_[inc]_[pctl]' 
setnames(shares_soi_22,old = paste0("total_",incs,"_amt"), new = paste0("sum_",incs,"_total"))
setnames(shares_soi_22,old = 'total_agi', new = 'sum_agi_total')

#Note - the sum of AGI components in SOI data does not sum to total AGI. AKA, total(sal, int, div, businc, cpgain, iradist, pension, scorp) != total_agi
  # I'm not certain why. The summed AGI components represent ~96% of total AGI. 
  # Here, I create another category of 'other' income to represent this missing amount
lapply(pctls, function(p) { 
  
  incs_total <- paste0("sum_",incs,"_",p)
  shares_soi_22[,paste0("sum_other_",p) := sum_agi_p - rowSums(.SD), .SDcols = incs_total, env = list(sum_agi_p = paste0("sum_agi_",p))]
  
} )

incs <- c(incs,'other')

#collapse, by percentile of agi, to a long (by income component) table of shares of agi 
collapse_to_long_table_of_agi_shares <- function(p){

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
  list(collapse_to_long_table_of_agi_shares("total")[statefips == 0L], 
       collapse_to_long_table_of_agi_shares("01")[statefips == 0L]))
setnames(share_of_income_by_component,old = 'value',new = 'share_total_agi')

#calculate shares of nonwage income by component
share_of_income_by_component[!grep('sal',inc), share_total_nw := share_total_agi/sum(share_total_agi), by = pctl]

#combine IRA distributions and pensions together
share_of_income_by_component[inc == 'iradist', temp := share_total_nw][,temp := max(temp,na.rm = T), by = pctl]
share_of_income_by_component[inc == 'pension', share_total_nw := share_total_nw + temp]
share_of_income_by_component <- share_of_income_by_component[inc != 'iradist']

#set 'inc' to a factor variable ordered by the order of nonwage income components within the 1st pctl of agi 
share_of_income_by_component <- share_of_income_by_component[order(pctl,share_total_nw)]
share_of_income_by_component[, inc := factor(inc, 
                                           levels = c('pension','businc','int','other','div','scorp','cpgain'))]

share_of_income_by_component[,pctl := factor(pctl, levels = c("total","01"))]


g2 <- ggplot(data = share_of_income_by_component[inc != 'sal'], mapping = aes(x = pctl, y = share_total_nw, fill = inc)) + 
  geom_col(position = 'stack') + 
  ggtitle('Shares of total non-wage income, US, 2022', subtitle = 'Source: IRS') +
  scale_y_continuous(labels = scales::percent)

ggsave(paste0(getwd(),'/graphs/shares_total_nwi.png'), g2)
write.csv(g2$data, file = paste0(getwd(),'/out/shares_total_nwi.csv'))




