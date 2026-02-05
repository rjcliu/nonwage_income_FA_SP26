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


graph bar hinw_idda hiearn, over(xagea) legend(order(1 "Nonwage" 2 "Earnings")) stack /// 
name(median_incomecomp_xagea, replace) ///
legend(order(1 "Median nonwage income" 2 "Median wage and salary income") pos(6)) ///
ylabel(0 "$0" 20000 "$20,000" 40000 "$40,000" 60000 "$60,000" 80000 "$80,000") ///
    note("Age", position(6) ring(1))

	///note("Source: HRS waves 5+. Median is derived from a pooled sample over multiple waves." "Values are inflation-adjusted before calculating median.") ///

graph export "$home/graphs/figure_4.png" ,name(median_incomecomp_xagea) replace

rename hinw_idda nonwage_income
rename hiearn wage_income
export delimited "$home/out/figure_4.csv" , replace

//Figure 4 

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


keep if inrange(age, 60, 70)
keep if xred != 3 & hiearn_adj >= 5000
xtile wage_quintile = hiearn_adj [aw = rwthh], n(5)
collapse (mean) hinw_adj (mean) hiearn_adj [aw= rwthh] if xred != ., by(xred wage_quintile)

twoway (scatter hinw_adj hiearn_adj if xred == 0, ms(O)) ///
(scatter hinw_adj hiearn_adj if xred == 1, ms(T)) ///
(scatter hinw_adj hiearn_adj if xred == 2, ms(D)), ///
xtitle("Mean wages pre-retirement") ///
ytitle("Mean nonwage income post-retirement") ///
legend(order(1 "White" 2 "Black" 3 "Hispanic")) ///
ylab(20000 "$20,000" 40000 "$40,000" 60000 "$60,000" 80000 "$80,000" 100000 "$100,000") ///
xlab(0 "$0" 50000 "$50,000" 100000 "$100,000" 150000 "$150,000" 200000 "$200,000")  ///
name(scatter_y_prepostretirement, replace)


//note("Source: HRS wave 5+, individuals must be observed for 6 periods centered around retirement. " "Retirement age within 60-70. Mean earnings must be above $5,000. Data is binned into 5 equal-sized groups.")  

graph export "$home/graphs/figure_7.png", name(scatter_ret_passthru_xred) replace 

rename hinw_adj nonwage_income
rename hiearn_adj wage_income
drop wage_quintile
export delimited "$home/out/figure_7", replace

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
		legend(title("") order(1 "Bottom quartile household income" 2 "Top quartile household income") pos(6)) ///
		xtitle("") ///
		ytitle("Probability of working at age 65+") /// 
		ylabel(0 "0%" 0.2 "20%" 0.4 "40%" 0.6 "60%") ///
		name(pos_wsi, replace) 
		
//note("HRS waves 5+, households where oldest member is 65+.") ///
		
graph export "$home/graphs/figure_6.png", replace name(pos_wsi)	

keep if py0_htot == 1 | py0_htot == 4 
keep year py0_htot pos_wsi 
order py0_htot year pos_wsi
sort py0_htot year pos_wsi
label def quartiles 1 "bottom quartile" 2 "2nd quartile" 3 "3rd quartile" 4 "top quartile"

lab val py0_htot quartiles
export delimited "$home/out/figure_6.csv", replace
	
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
 * calculate for 2000 beyond only, because sample has a consistent age distribution after then - see, 'HRS Longitudinal Cohort sample design' https://hrs.isr.umich.edu/documentation/survey-design
forvalues year = 2000(2)2022 { 
	
	xtile py0_nwi_`year' = hinw_idda [aw = rwthh] if year == `year', nquantiles(4)
	xtile py0_htot_`year' = hitot [aw = rwthh] if year == `year' , nquantiles(4)
	
	replace py0_nwi = py0_nwi_`year' if py0_nwi == . 
	replace py0_htot = py0_htot_`year' if py0_htot == . 
	
	drop py0_nwi_`year' 
	drop py0_htot_`year'  
	}

collapse (median) median_nw_share = nw_share_of_total_income (mean) mean_nw_share = nw_share_of_total_income (count) n = nw_share_of_total_income [aw = rwthh], by(py0_htot)

label def quartiles 1 "bottom quartile" 2 "2nd quartile" 3 "3rd quartile" 4 "top quartile"
lab values py0_htot quartiles

graph bar mean_nw_share, over(py0_htot) ytitle("Nonwage share of household income") note("Household income quartile", pos(6)) ///
ylab(0 "0%" .25 "25%" 0.5 "50%" .75 "75%" 1 "100%") name(mean_nw_share,replace) 

/// note("Source: Pooled HRS wave 5+, where oldest member of household is 65+")

graph export "$home/graphs/figure_5.png", name(mean_nw_share) replace

keep py0_htot mean_nw_share 
drop if py0_htot == .
export delimited "$home/out/figure_5.csv", replace






