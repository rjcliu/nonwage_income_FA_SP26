*Tried this for great recession (2004-2012). It just looks like older households are declining in income and employment probability monotonically with age, creating a pre-trend that makes it hard to conduct an event-study. 

* It's hard to see if older households have an nonwage income response to higher prices or higher unemployment. 

* exposure of HRS panel 2016-2022 to rising prices, sample is households aged 65-70 in 2016, by above/below median of total household income (wealth) in 2016

global home "C:\Users\IRRJL01\Dropbox\personal\IDDA\nuggets"

use $home/data/hrs_cleaned.dta, replace 

*keep panel of individuals observed between 2016-22
keep if inrange(year, 2004,2012)
drop if hitot == .
egen count_obs = count(hitot), by(hhidpn)
keep if count_obs == 5
drop count_obs

egen earnings_sum = total(hiearn), by(hhidpn)

*restrict further to those who are aged 65-70 in 2016
preserve
keep if year == 2004
gen age_y0 = age 
gen retired_2004 = age >= retage
gen zero_earnings_2004 = hiearn == 0
keep hhidpn age_y0 retired_2004 zero_earnings_2004
tempfile temp 
save `temp'
restore
merge m:1 hhidpn using `temp', nogen
*keep if retired_2016 == 1
*keep if inlist(age_y0, 65,66)
keep if inrange(age_y0, 65,75)
*keep if earnings_sum == 0 & inrange(age_y0, 65,70)
*keep if retage == age_y0 & inrange(age_y0, 65,75)

* calculate above/below median of household income/wealth in 2016 amongst sample
preserve
keep if year == 2004
xtile nwi_2004 = hinw_idda [aw = rwthh], n(2)  
xtile wealth_2004 = hatotb [aw = rwthh], n(2)
xtile income_2004 = htot_idda [aw = rwthh], n(2)
keep hhidpn nwi_2004 income_2004 wealth_2004
tempfile temp 
save `temp'
restore
merge m:1 hhidpn using `temp', nogen



*convert incomes to real values for this exercise
foreach i in capital transfer pension earned socsec othr hinw_idda hiearn htot_idda { 
	
	replace `i' = `i'/PCEPI
} 


gen hinw_idda_unearned = hinw_idda - earned -othr
gen pos_earn = (hiearn + earned) > 0

loc bin wealth
keep if `bin'_2004!= .
*keep if TC != . 


collapse (mean) pos_earn [aw = rwthh], by(year `bin'_2004)

twoway (connected pos_earn year if wealth_2004 == 1) (connected pos_earn year if wealth_2004 == 2)



(mean) capital (mean) transfer (mean) pension (mean) earned (mean) socsec (mean) othr (mean) hinw_idda (mean) htot_idda (mean) hiearn (mean) hinw_idda_unearned (mean) hatotb [aw = rwthh], by(year `bin'_2004) 

twoway (connected htot_idda year if wealth_2004 == 1) (connected htot_idda year if wealth_2004 == 2)


preserve

sort(`bin'_2004 year)
keep year `bin'_2004 capital transfer pension socsec

foreach i in capital transfer pension socsec { 
	
	rename `i'  inc_`i'
}
reshape long inc_, i(year `bin') j(inc) string

bysort year `bin': gen inc_high = sum(inc_)
gen inc_low = inc_high - inc_

label def wealth_qtle 1 "below-median wealth, 2016" 2 "above-median wealth, 2016" 
lab val wealth_2004 wealth_qtle

twoway (rarea inc_low inc_high year if inc == "capital") ///
(rarea inc_low inc_high year if inc == "pension") ///
(rarea inc_low inc_high year if inc == "socsec") ///
(rarea inc_low inc_high year if inc == "transfer"), by(`bin'_2016, ///
title("Average unearned income by component") ///
note("Sample: Panel of HRS households observed across 2016-2022, whose head is aged 65-70 in 2016." "Unearned income = capital, pension, socsec, and transfer income."))  ///
legend(order(1 "capital" 2 "pension" 3 "socsec" 4 "transfer")) name(mean_unearn_comp, replace)



collapse (median) hinw_idda (median) hinw_idda_unearned (mean) pos_wsi (median) htot_idda (mean) pos_earn [aw = rwthh], by(`bin'_2004 year)
reshape wide hinw_idda hinw_idda_unearned pos_wsi htot_idda pos_earn, i(year) j(`bin'_2004)

foreach i in 1 2 { 
	
	sum hinw_idda`i' if year == 2004
	gen grwth_nw_`i' = hinw_idda`i'/`r(mean)'
	
	sum hinw_idda_unearned`i' if year == 2016
	gen grwth_unearned_`i' = hinw_idda_unearned`i'/`r(mean)'
	
	sum htot_idda`i' if year == 2016
	gen grwth_tot_`i' = htot_idda`i'/`r(mean)'
}


twoway 	(connected hinw_idda_unearned1 year ) ///
		(connected hinw_idda_unearned2 year ) ///
		, title("Real median unearned household income") ///
		note("Sample: Panel of HRS households observed across 2016-2022, whose head is aged" "65-70 in 2016. Unearned income = capital, pension, socsec, and transfer income.") ///
		legend(order(1 "bottom half" 2 "top half") sub("`bin' bin, 2016")) ///
		name("panel_unearned_lvl_`bin'", replace) 


twoway 	(connected grwth_unearned_1 year ) ///
		(connected grwth_unearned_2 year ) ///
		, title("Real growth in median unearned household income since 2016") ///
		note("Sample: Panel of HRS households observed across 2016-2022, whose head is aged" "65-70 in 2016. Unearned income = capital, pension, socsec, and transfer income.") ///
		legend(order(1 "bottom half" 2 "top half") sub("`bin' bin, 2016")) ///
		name("panel_unearned_grwth_`bin'", replace) 
		
twoway 	(connected pos_earn1 year ) ///
		(connected pos_earn2 year ) ///
		, title("Probability of positive earnings") ///
		note("Sample: Panel of HRS households observed across 2016-2022, that whose head is aged" "65-70 in 2016.") ///
		legend(order(1 "bottom half" 2 "top half") sub("`bin' bin, 2016")) ///
		name("panel_pos_earn_`bin'", replace) 		
		
graph export $home/graphs/panel_unearned_lvl_`bin'.png, name(panel_unearned_lvl_`bin') replace
graph export $home/graphs/panel_unearned_grwth_`bin'.png, name(panel_unearned_grwth_`bin') replace		
graph export $home/graphs/panel_pos_earn_`bin'.png, name(panel_pos_earn_`bin') replace			
		

 

 
 
		









