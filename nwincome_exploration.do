global home "C:\Users\IRRJL01\Dropbox\personal\IDDA\nuggets"
global raw "$home\data"
global out "$home\graphs"

frames reset
frame create bea
frame create asec


import delimited "$raw\pctl_of_inc_all_data.csv", clear


keep if year == 2019  & group_var == "xaged" & level == "mafid" & inc_var == "NW" & geo_var == "state" & group_var_val == "65plus"

cwf asec
use "$raw\cps_00058.dta", replace 

gen retire = whynwly_1 == 0 & whynwly_2 == 5
keep if retire == 1
collapse (mean) rtr_age = age_1 [aw = asecwt_1], by(statefip_1) 

cwf bea
import delimited "$raw\Table.csv", clear

rename v3 rpp 
replace geofips = geofips/1000


cwf default

frlink 1:1 geo_var_val, frame(bea geofips) 
frget rpp, from(bea) 
frlink 1:1 geo_var_val, frame(asec statefip_1) 
frget rtr_age, from(asec)

reg pctl50_adj  rtr_age 

predict resid_p50_adj, resid 

reg rpp rtr_age 
predict resid_rpp, resid 

scatter resid_p50_adj resid_rpp, name(resid, replace) 
scatter pctl50_adj rp, name(raw, replace)

scatter pctl50_adj rtr_age, mlabel(geo_abb) xtitle("Mean retirement age (2011-2020)") ytitle("") ///
title("Median NW income, aged 65+") ///
note("Source: Monthly CPS, IPUMS") ///
name(ageXnwinc,replace)

graph export "$out/age_nw_sctr.png", name(ageXnwinc) replace




* Attempting to *roughly create a hh nonwage income measure using ASEC measures 

global home "C:\Users\IRRJL01\Dropbox\personal\IDDA\nuggets"
global raw "$home\data"

use $raw/cps_00063.dta,replace

keep if age >=15

loc nwincs incbus incfarm  incretir incint incdivid ///
	incrent incother 
	
replace inccapg = 0 if inccapg == 9999999
replace caploss = -caploss
replace incretir = . if incretir == 99999999


egen incnw = rowtotal(incbus incfarm incss incretir incint  incdivid  incrent  ///
	incother  incrann  incpens  inccapg  capgain  caploss) 
	
by cpsid, sort: egen hh_incnw = sum(incnw) 
collapse (mean) hh_incnw (mean) asecwth, by(cpsid year month)

