*************************************
*levels of median earned, unearned income by age in HRS
	
global home "C:\Users\IRRJL01\Dropbox\personal\IDDA\nuggets"

use $home/data/hrs_cleaned.dta, replace 

*calculate components of average household income by age
keep if hinw_idda != .


foreach i in hinw_idda hiearn { 
	
	replace `i' = `i'/PCEPI
}

collapse (median) hinw_idda (median) hiearn  [aw = rwthh], by(xagea) 


graph bar hinw_idda hiearn, over(xagea) legend(order(1 "Non-wage" 2 "Earnings")) stack ///
title("Household income components by age ($2022)") note("Source: HRS waves 5+. Median is derived from a pooled sample over multiple waves." "Values are inflation-adjusted before calculating median.") ///
name(median_incomecomp_xagea, replace)


graph export "$home/graphs/median_incomecomp_xagea.png" ,name(median_incomecomp_xagea) replace


*************************************
* draw scatter of wages pre-retirement to nonwage income post-retirement by race for balanced panel of retirees 
clear
use $home/data/hrs_cleaned.dta, replace 

*keep if inrange(age, 59,69)
keep if inrange(age - retage, -6,4)

egen valid = count(hitot), by(hhidpn)
keep if valid == 6


gen hiearn_adj = hiearn/PCEPI if age < retage
gen hinw_adj = hinw_idda/PCEPI if age >= retage
collapse (mean) hiearn_adj hinw_adj age rwthh, by(hhidpn xred) 

binscatter hinw_adj hiearn_adj if inrange(age, 60,70) & xred != 3 & hiearn_adj >= 5000, ///
xtitle("Mean wages pre-retirement, 2022 dollars") ///
ytitle("") ///
msymbols(O T D) ///
note("Source: HRS wave 5+, individuals must be observed for 6 periods centered around retirement. " "Retirement age within 60-70. Mean earnings must be above $5,000. Data is binned into 5 equal-sized groups.") title("Mean non-wage income post-retirement, 2022 dollars") ///
name(scatter_ret_passthru_xred, replace) by(xred) line(none) n(5) ///
ylab(0(50000)200000) xlab(0(50000) 200000)

graph export "$home/graphs/scatter_ret_passthru_xred.png", name(scatter_ret_passthru_xred) replace

***********************************************************************
* Draw Pr(WSI >0 | htot_idda  quartile) over time
use $home/data/hrs_cleaned.dta, replace 

* keep 65 +
keep if xaged >= 5 
* calculate within-year quartiles of household income for 65+
gen py0_htot = . 

 * calculate for 2000 beyond only, because sample has a consistent age distribution after then - see, 'HRS Longitudinal Cohort sample design' https://hrs.isr.umich.edu/documentation/survey-design
forvalues year = 2000(2)2022 { 
	
	xtile py0_htot_`year' = htot_idda [aw = rwthh] if year == `year' , nquantiles(4)
	
	replace py0_htot = py0_htot_`year' if py0_htot == . 
	
	*drop py0_nwi_`year' 
	drop py0_htot_`year' 
	}

keep if py0_htot != .
collapse (mean) pos_wsi (mean) age (count) hhidpn [aw = rwthh], by(year py0_`bin')

twoway 	(connected pos_wsi year if py0_`bin' == 1) ///
		(connected pos_wsi year if py0_`bin' == 4), ///
		title("Pr(WSI>0 | aged 65+)") ///
		note("HRS waves 5+, households where oldest member is 65+.") ///
		legend(title("household income") order(1 "Bottom-quartile" 2 "Top-quartile")) ///
		name(pos_wsi, replace) 
		
graph export "$home/graphs/pos_wsi.png", replace name(pos_wsi)	
	
**********************************************
*mean nwi share of hhincome by total hh income quartile using pooled sample 

global home "C:\Users\IRRJL01\Dropbox\personal\IDDA\nuggets"

use $home/data/hrs_cleaned.dta, replace 

gen nw_share_of_total_income = hinw_idda/htot_idda

keep if xaged >= 5 
* calculate within-year quartiles of nonwage income for 65+
gen py0_nwi = .
gen py0_htot = . 
gen py0_asset = .
 * calculate for 1998 beyond only, because sample has a consistent age distribution after then - see, 'HRS Longitudinal Cohort sample design' https://hrs.isr.umich.edu/documentation/survey-design
forvalues year = 2000(2)2022 { 
	
	xtile py0_nwi_`year' = hinw_idda [aw = rwthh] if year == `year', nquantiles(4)
	xtile py0_htot_`year' = hitot [aw = rwthh] if year == `year' , nquantiles(4)
	
	replace py0_nwi = py0_nwi_`year' if py0_nwi == . 
	replace py0_htot = py0_htot_`year' if py0_htot == . 
	
	drop py0_nwi_`year' 
	drop py0_htot_`year'  
	}

collapse (median) median_nw_share = nw_share_of_total_income (mean) mean_nw_share = nw_share_of_total_income (count) n = nw_share_of_total_income [aw = rwthh], by(py0_htot)

graph bar mean_nw_share, over(py0_htot) note("Source: Pooled HRS wave 5+, where oldest member of household is 65+") ytitle("") title("Mean nonwage share of household income | 65+") subtitle("By quartiles of household income") ///
ylab(0(0.25)1) name(mean_nw_share,replace)

graph export "$home/graphs/mean_nw_share.png", name(mean_nw_share) replace






