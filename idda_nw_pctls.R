library(data.table)
library(ggplot2)
setwd('C:/Users/IRRJL01/Dropbox/personal/IDDA/nuggets/')

pctls <- fread(paste0(getwd(),"/data/Voorheis_pctl_of_inc_release_T13T26.csv"))
pctls <- pctls[inc_var_val %in% 'mafid_unearned_inc_pf' & year == 2023 & geo_var == 'usst' & group_var_val %in% c('65+','All Sample Members')]

#pctls[,group_var := NULL]

pctlvars <- grep("pctl",names(pctls), value = TRUE)
pctlvars <- setdiff(pctlvars, grep('adj',pctlvars,value=T))

idvars <- setdiff(names(pctls), pctlvars)


keepvars <- c(idvars, pctlvars)
pctls <- pctls[,..keepvars]



pctls <- melt(pctls, 
              id.vars = idvars,
              measure.vars = pctlvars, 
              variable.name = 'pctl') 

pctls[,pctl := gsub('pctl','',pctl)]
pctls[,group_var_val := factor(group_var_val, levels = c('All Sample Members','65+'))]
                                
nw_pctls_65_all <- ggplot(data = pctls[pctl %in% c(10L,50L,90L)], mapping = aes(x = pctl, y = value, fill = group_var_val)) +
  geom_col(position = 'dodge') + 
  ggtitle('Pctls of nonwage income in 2023', subtitle = "Source: IDDA, real values") 

ggsave(paste0(getwd(),"/graphs/nw_pctls_65_all.png"), nw_pctls_65_all)

write.csv(pctls, file = paste0(getwd(),'/out/nw_pctls_65_all.png'))