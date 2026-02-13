library(data.table)
library(ggplot2)
#setwd('C:/Users/IRRJL01/Dropbox/personal/IDDA/nuggets/')
setwd('SET TO YOUR DIRECTORY HERE')

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

pctls[,legend := fifelse(group_var_val == 'All Sample Members','All individuals','Individuals aged 65+')]
pctls[,legend := factor(legend, levels = c('All individuals','Individuals aged 65+'))]
pctls[,percentile_label := fcase(
  pctl == 10L, '10th', 
  pctl == 50L, '50th',
  pctl == 90L, '90th'
)]


#draw bar graph                                 
nw_pctls_65_all <- ggplot(data = pctls[pctl %in% c(10L,50L,90L)], mapping = aes(x = percentile_label, y = value, fill = legend)) +
  geom_col(position = 'dodge') + 
  scale_y_continuous(labels = scales::dollar) +
  xlab('Percentile of the nonwage income distribution') +
  labs(fill = '') +
  ylab('')

ggsave(paste0(getwd(),"/graphs/figure_2.png"), nw_pctls_65_all)

pctls <- pctls[pctl %in% c(10L,50L,90L)][,.(value,legend, percentile_label)]
write.csv(pctls, file = paste0(getwd(),'/out/figure_2.csv'))