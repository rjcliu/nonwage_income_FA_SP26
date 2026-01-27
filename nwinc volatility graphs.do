*Inspired by Illenin convo, 5/12/25

**Code to chart household composition for retirees by race, using 2019 ACS


global home "C:\Users\IRRJL01\Dropbox\personal\IDDA\nuggets"
global raw  "$home\data" 
global do 	"$home\do"
global out "$home\graphs"

clear

import delimited "$raw/transition_matrix_all_data.csv"


keep if inc_var == "NW"

keep if group_var_val == "65plus"

keep if geo_var == "state"
keep if lag == 5

gen tempvar = probability if pctl_y1 == "miss" 
by geo_abb y0 pctl_y0, sort: egen probmiss = sum(tempvar)
gen probadj = probability/(1-probmiss)

preserve
keep if pctl_y1 == "miss"
hist probmiss, by(pctl_y0) name(histmiss, replace)

restore 
drop if pctl_y1 == "miss" |pctl_y0 == "miss"
gen quart_y0 = 1 if pctl_y0 == "lt25" 
replace quart_y0 = 2 if pctl_y0 == "25t50" 
replace quart_y0 = 3 if pctl_y0 == "50t75" 
replace quart_y0 = 4 if pctl_y0 == "gt75"

gen 	quart_y1 = 1 if pctl_y1 == "lt25" 
replace quart_y1 = 2 if pctl_y1 == "25t50" 
replace quart_y1 = 3 if pctl_y1 == "50t75" 
replace quart_y1 = 4 if pctl_y1 == "gt75"

gen upvar = probadj if quart_y1 > quart_y0 
gen downvar = probadj if quart_y0 > quart_y1 
gen samevar = probadj if quart_y0 == quart_y1

by pctl_y0 geo_abb y0, sort: egen probup = sum(upvar) 
by pctl_y0 geo_abb y0, sort: egen probdown = sum(downvar)  
by pctl_y0 geo_abb y0, sort: egen probsame = sum(samevar)  

keep if pctl_y1 == "lt25" 
drop pctl_y1

keep group_var_val pctl_y0 geo_abb y0 y1 probup probdown probsame quart_y0

reshape long prob, i(geo_abb y0 y1 group_var_val pctl_y0 quart_y0) j(pctl_y1) string

lab def quart 1 "lt25" 2 "25t50" 3 "50t75" 4 "gt75" 
lab val quart_y0 quart


hist prob if pctl_y1 == "up" & pctl_y0 != "gt75", by(quart_y0, ///
	title("Probability of transition to higher income quartile") ///
	note("Transition probability measured over 5 years. Adjusted for individuals observed in both periods." ///
	"Indvls aged 65+, NW income, 1998-2014, all states")) ///
	name(probrise, replace)

hist prob if pctl_y1 == "down" & pctl_y0 != "lt25", by(quart_y0, ///
	title("Probability of transition to lower income quartile") ///
		note("Transition probability measured over 5 years. Adjusted for individuals observed in both periods." ///
	"Indvls aged 65+, NW income, 1998-2014, all states")) ///
	name(probfall, replace)
	
hist prob if pctl_y1 == "same", by(quart_y0, ///
	title("Probability of remaining in the same income quartile") ///
		note("Transition probability measured over 5 years. Adjusted for individuals observed in both periods." ///
	"Indvls aged 65+, NW income, 1998-2014, all states")) ///
	name(probsame, replace)
	
graph export "$out/probrise.png", name(probrise) replace
graph export "$out/probfall.png", name(probfall) replace
graph export "$out/probsame.png", name(probsame) replace
graph export "$out/histmiss.png", name(histmiss) replace

clear

import delimited "$raw/inc_change_distributions_all_data.csv"


keep if inc_var == "NW"

keep if group_var_val == "65plus"
keep if inlist(pctl_y1, "10","50", "90")
keep if lag == 5

keep if geo_var == "usst"

twoway 	(connected value y0 if pctl_y1 == "10") || ///
		(connected value y0 if pctl_y1 == "50") || ///
		(connected value y0 if pctl_y1 == "90"), ///
		legend(order(1 "10" 2 "50" 3 "90") r(1))	///
		by(pctl_y0,	///
		title("Nominal 5-yr nonwage income changes") ///
		note("For individuals aged 65 and above. Colors are different percentiles of income changes")) ///
		name("bcyclenw", replace)
	
graph export "$out/bcyclenw.png", name(bcyclenw) replace	
		
clear

import delimited "$raw/pctl_of_inc_all_data.csv"

keep if inlist(group_var_val, "65plus", "55to64")
keep if level == "mafid"
gen p9050= pctl90_adj/pctl50_adj

drop if group_var_val == "55to64" & inc_var == "NW"
drop if group_var_val == "65plus" & inc_var == "GI"
drop if inc_var == "GI_ADJ"
drop if geo_abb == "US"
keep year geo_abb inc_var p9050

reshape wide p9050, i(geo_abb year) j(inc_var) string
scatter  p9050NW p9050GI if year == 2018 & geo_abb != "DC", ///
	ytitle("") xtitle("p90p50 ratio of gross income for 55to64") ///
	title("p90p50 ratio of nonwage income for 65plus") /// 
	mlabel(geo_abb) note("Source: 2019 IDDA, percentiles module") ///
	name("ineq", replace)
	
graph export "$out/ineq.png", name(ineq) replace	

	

