/*code to graph mean retirement age by race, using ASEC data that allows me to identify retirees */. 

global home "C:\Users\IRRJL01\Dropbox\personal\IDDA\nuggets"
global raw "$home\data"
global out "$home\graphs"


use "$raw\cps_00065.dta", replace 

gen retire = whynwly_1 == 0 & whynwly_2 == 5


* Race/ethnicity
gen xrea = ""
replace xrea = "NH White" if race_1 == 100 & hispan_1 == 0 
replace xrea = "NH Black" if race_1 == 200 & hispan_1 == 0 
replace xrea = "NH AIAN" if race_1 == 300 & hispan_1 == 0
replace xrea = "NH Asian" if race_1 == 651 & hispan_1 == 0 
replace xrea = "NH NHOPI" if race_1 == 652 & hispan_1 == 0
replace xrea = "Hispanic" if hispan_1 != 0
replace xrea = "NH Other" if xrea == ""
tab race_1 xrea if hispan_1 == 0, missing 
tab race_1 xrea if hispan_1 != 0, missing 


keep if retire == 1
collapse (mean) rtr_age = age_1 (count) age_1 (semean) rtr_se = age_1 [aw = asecwt_1], by(year_1 xrea) 

gen upbound = (rtr_se * 1.96) + rtr_age
gen lowbound = rtr_age - (rtr_se * 1.96) 

drop if inlist(xrea, "NH NHOPI", "NH AIAN", "NH Other")

encode xrea, gen(xrea_num)
codebook xrea_num, tab(6)

drop xrea age_1 rtr_se

reshape wide rtr_age upbound lowbound, i(year_1) j(xrea_num) 

		
twoway  (line  	rtr_age1 year_1, lc(red)) 		///
		(line 	rtr_age2 year_1, lc(blue)) 		///
		(line 	rtr_age3 year_1, lc(green)) 	///
		(line	rtr_age4 year_1, lc(orange))  	///
		(rcap upbound1 lowbound1 year_1, lc(red)) ///
		(rcap upbound2 lowbound2 year_1, lc(blue)) ///
		(rcap upbound3 lowbound3 year_1, lc(green)) ///
		(rcap upbound4 lowbound4 year_1, lc(orange)), ///
	legend(order(1 "Hispanic" 2 "NH Asian" 3 "NH Black" 4 "NH White")) ///
	title("Avg retirement age") note("Data: Longitudinal ASEC, sourced from IPUMS") ///
	name(g1, replace) 

graph export "$out/retirementage_xrace.png", name(g1) replace

