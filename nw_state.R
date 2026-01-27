library(dplyr)
library(ggplot2)

pctls <- read.csv("C:/Users/liuri001/Downloads/pctl_of_inc_all_data.csv")

# Source for RPP: https://www.bea.gov/news/2024/real-personal-consumption-expenditures-state-and-real-personal-income-state-and  
rpp <- read.csv("C:/Users/liuri001/Downloads/Table.csv")

rpp <- rpp %>%
  mutate(GeoFips = GeoFips/1000) %>%
  select(GeoFips,X2019)

pctls <- pctls %>%
  filter(level == "mafid" & year == "2019" & geo_var == "state" & inc_var == "NW" & group_var_val == "65plus") 
  


pctls <- pctls %>%
  merge(rpp, by.x = "geo_var_val", by.y = "GeoFips")

pctls %>%
  ggplot(mapping = aes(y = pctl50_adj, x = reorder(geo_abb,pctl50_adj))) +
  geom_col() 

pctls %>%
  ggplot(mapping = aes(x = X2019, y= pctl50_adj)) +
  geom_point() +
  geom_smooth() +
  geom_text(aes(label = geo_abb), nudge_x = 0.5) +
  xlab("Regional Price Parity (BEA)")
