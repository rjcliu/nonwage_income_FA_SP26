* Code for HRS IDDA comparison 11/4/25

global home "C:\Users\IRRJL01\Dropbox\personal\IDDA\nuggets\" 

frames reset 

include $home\do\00_hrs.do


collapse (p10) pctl10 = hinw (p50) pctl50 = hinw (p90) pctl90 = hinw [aw = rwthh], by(year xagea)

gen source = "HRS"

tempfile temp
save `temp'

clear

import delimited $home\data\pctl_of_inc_all_data.csv
keep if group_var == "xaged" & inc_var == "NW" & geo_abb == "US"
gen xagea = 0 if group_var_val == "16to24" 
replace xagea = 1 if group_var_val == "25to34"
replace xagea = 2 if group_var_val == "35to44" 
replace xagea = 3 if group_var_val == "45to54" 
replace xagea = 4 if group_var_val == "55to64" 
replace xagea = 5 if group_var_val == "65plus"

keep pctl10 pctl50 pctl90 xagea year 
gen source = "IDDA"

append using `temp'

twoway 	(connected pctl10 year) ///
(connected pctl50 year) ///
(connected pctl90 year) ///
if xagea == 5 & inrange(year, 1998,2019), by(source, ///
note("Sample = 65plus. HRS does not include capital gains/losses.")) ///
name(retirees_pctls, replace)

preserve

reshape wide pctl10 pctl50 pctl90, i(year xagea) j(source) string

foreach i in 10 50 90 { 
	
	gen pctl`i'_ratio = pctl`i'HRS / pctl`i'IDDA
	
}

twoway 	(connected pctl10_ratio year) ///
(connected pctl50_ratio year) ///
(connected pctl90_ratio year) /// 
if xagea == 5 & inrange(year, 1998,2019), ///
note("Sample = 65plus. HRS does not include capital gains/losses.") ///
yline(1) ///
title("HRS pctls relative to IDDA") name(ratio_retirees, replace)

twoway 	(connected pctl10_ratio year) ///
(connected pctl50_ratio year) ///
(connected pctl90_ratio year) /// 
if xagea == 4 & inrange(year, 1998,2019), ///
note("Sample = 55-64y/os. HRS does not include capital gains/losses.") ///
yline(1) ///
title("HRS pctls relative to IDDA") name(ratio_workers, replace)

restore 

twoway 	(connected pctl10 year) ///
(connected pctl50 year) ///
(connected pctl90 year) ///
if xagea == 4 & inrange(year, 1998, 2019), by(source, ///
note("Sample = 55-64 y/o. HRS does not include capital gains/losses.")) ///
name("workers_pctls", replace)


frlink m:1 year, frame(pce year) 
frget PCEPI, from(pce)
drop pce  

foreach i in 10 50 90 { 
	
	gen pctl`i'_adj = pctl`i'/PCEPI
}

twoway ///
(connected pctl10_adj year) ///
(connected pctl50_adj year) ///
(connected pctl90_adj year) if source == "HRS" & xagea == 5	& year >=1996 ///
,title("Real nonwage income percentiles") note("Source = HRS")


preserve 
keep if source == "HRS"
foreach i in 10 50 90 { 

gen pctl`i'_ref = .
	
	forvalues j = 1(1)5 { 
		quietly sum pctl`i'_adj if year == 1996 & xagea == `j'
		replace pctl`i'_ref = pctl`i'_adj/`r(mean)' if xagea == `j'
	}
}

twoway ///
(connected pctl10_ref year) ///
(connected pctl50_ref year) ///
(connected pctl90_ref year) if xagea == 5 & year >= 1996 ///
, title("Real growth in nonwage income percentiles, normalized to 1996") ///
note("Source = HRS")

restore







foreach i in 10 50 90 { 

gen pctl`i'_ref = .
	
	forvalues j = 0(1)5 { 
		sum pctl`i' if year == 1996 & xagea == `j' & source == "HRS"
		replace pctl`i'_ref = pctl`i'/`r(mean)' if xagea == `j' & source == "HRS"
	}
}


 
preserve 
collapse (median) hitot hiearn riearn siearn ///
hinw hicap hipena hissdi hisret hiunwc higxfr hiothr age hiirawy1 ///
[aw = rwthh], by(year)



twoway connected hinw hiearn year, name(nw_connect, replace)

restore
preserve


collapse (mean) hitot hiearn riearn siearn ///
hinw hicap hipena hissdi hisret hiunwc higxfr hiothr age hiirawy1 ///
[aw = rwthh], by(PE xaged)

foreach i in cap pena ssdi sret unwc gxfr othr irawy1 { 
	
	gen prop_`i' = hi`i'/hinw
}

keep xaged PE prop_*

drop prop_irawy1 

reshape long prop_, i(xaged PE) j(inc) string

sort xaged PE inc

bysort xaged PE (inc): gen cum_prop = sum(prop_)

gen prop_low = cum_prop - prop_

twoway ///
    (rarea prop_low cum_prop xaged if inc=="cap" , color(stc1)) ///
    (rarea prop_low cum_prop xaged if inc=="gxfr", color(stc2)) ///
    (rarea prop_low cum_prop xaged if inc=="othr", color(stc3)) ///
	(rarea prop_low cum_prop xaged if inc=="pena", color(stc4)) ///
	(rarea prop_low cum_prop xaged if inc=="sret", color(stc5)) ///
	(rarea prop_low cum_prop xaged if inc=="ssdi", color(stc6)) ///
	(rarea prop_low cum_prop xaged if inc=="unwc", color(stc7)) ///
	if PE == 5, /// 
    ytitle("share of nonwage income") xtitle("year") ///
	legend(order (1 "capital" 2 "oth. xfer" 3 "other" 4 "pension" 5 "socsec" 6 "ssdi" 7 "UI/comp")) ///
	name(nw_shares, replace) title("Shares of nonwage income") ///
	note("Source: HRS")

restore	





	
	
	
	