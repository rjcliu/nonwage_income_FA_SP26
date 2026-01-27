library(data.table)
library(ggplot2)
setwd('C:/Users/IRRJL01/Dropbox/personal/IDDA/nuggets/')


pctls <- fread(paste0(getwd(),"/data/Voorheis_pctl_of_inc_release_T13T26.csv"))

#subset IDDA percentiles to 2 rows, xall and 65+ in 2023, usst, nonwage income 
pctls <- pctls[inc_var_val %in% 'mafid_unearned_inc_pf' & year == 2023 & geo_var == 'usst' & group_var_val %in% c('65+','All Sample Members')]

#keep only nominal percentile columns
pctlvars <- grep("pctl",names(pctls), value = TRUE)
pctlvars <- setdiff(pctlvars, grep('adj',pctlvars,value=T))
idvars <- setdiff(names(pctls), pctlvars)
keepvars <- c(idvars, pctlvars)
pctls <- pctls[,..keepvars]

pctls[1]

# reshape from wide to long (eg cols = [id pctl10 pctl25 pctl50] ... to cols = [id pctl value])
pctls <- melt(pctls, 
              id.vars = idvars,
              measure.vars = pctlvars, 
              variable.name = 'pctl') 

pctls[,pctl := gsub('pctl','',pctl)]
pctls[,group_var_val := factor(group_var_val, levels = c('All Sample Members','65+'))]

#draw bar graph                                 
nw_pctls_65_all <- ggplot(data = pctls[pctl %in% c(10L,50L,90L)], mapping = aes(x = pctl, y = value, fill = group_var_val)) +
  geom_col(position = 'dodge') + 
  ggtitle('Pctls of nonwage income in 2023', subtitle = "Source: IDDA, nominal values") 

ggsave(paste0(getwd(),"/graphs/nw_pctls_65_all.png"), nw_pctls_65_all)

write.csv(pctls, file = paste0(getwd(),'/out/nw_pctls_65_all.png'))