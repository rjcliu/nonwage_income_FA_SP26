global home "C:\Users\IRRJL01\Dropbox\personal\IDDA\nuggets"

use $home/data/hrs_cleaned.dta, replace 

*Generate aggregated components of nonwage income
* For reference
*gen hinw_idda = hidivin + hibusin + hirntin + hipena + hisret + hisdi +  hiunem + hisemp + hint + hiothr + hitrsin + histk + hiothi + hiirawy1 

*convert to real values for this exercise
foreach i in capital transfer pension earned socsec othr hinw_idda hiearn htot_idda { 
	
	replace `i' = `i'/PCEPI
} 

*calculate components of average household income by age
keep if hinw_idda != .
collapse (mean) capital (mean) transfer (mean) pension (mean) earned (mean) socsec (mean) othr (mean) hinw_idda (mean) htot_idda (mean) hiearn [aw = rwthh], by(xaged) 
***********************************
*Draw levels of average total household income divided into nonwage and wage 	
preserve

keep xaged hinw hiearn 
reshape long hi, i(xaged) j(income_type) string
bysort xaged: gen inc_high = sum(hi)
gen inc_low = inc_high - hi

twoway ///
	(rarea inc_low inc_high xaged if income_type == "earn", col(stc1)) ///
	(rarea inc_low inc_high xaged if income_type == "nw_idda", col(stc1%50)) ///
	if inrange(xaged,4,7), ///
	xlabel(,val) legend(order(1 "wages" 2 "non-wage income")) ///
	title("Average total household income") ///
	note("Source = HRS Wave 5+. Values are inflation-adjusted to 2019 dollars.") ///
	name(hi_levels, replace)

restore
***********************************
*Draw composition of average total household nonwage income over age


keep if inrange(xaged,4,7) 
foreach i in capital transfer pension earned socsec othr { 
	
	gen prop`i' = `i'/hinw_idda
}

keep xaged prop*

reshape long  prop, i(xaged) j(income_type) string
bysort xaged: gen prop_high = sum(prop)
gen prop_low = prop_high - prop

*replace income_type = "wages" if income_type == "hiearn"
 
 twoway ///
    (rarea prop_low prop_high xaged if inc=="capital" , color(stc1)) ///
    (rarea prop_low prop_high xaged if inc=="earned", color(stc2)) ///
	/*(rarea prop_low prop_high xaged if inc=="wages", color(stc7))*/ ///
	(rarea prop_low prop_high xaged if inc=="othr", color(stc3)) ///
    (rarea prop_low prop_high xaged if inc=="pension", color(stc4)) ///
	(rarea prop_low prop_high xaged if inc=="socsec", color(stc5)) ///
	(rarea prop_low prop_high xaged if inc=="transfer", color(stc6)), ///
	legend(order(1 "capital" 2 "earned"  3 "other" 4 "pension" 5 "social security" 6 "transfer")) ///
	xlabel(,val) title("Composition of total household non-wage income") ///
	note("Capital = financial/rental income. Earned = self-employment/business income. Pension = IRA disbursements/pensions." ///
	"Transfer = DI/UI. Source: HRS Wave 5+, pooled sample.") ytitle("proportion") xtitle("age") ///
	name(nwi_shares, replace)
	
*************************************
*levels of median earned, unearned income by age in HRS
	
global home "C:\Users\IRRJL01\Dropbox\personal\IDDA\nuggets"

use $home/data/hrs_cleaned.dta, replace 



*calculate components of average household income by age
keep if hinw_idda != .


foreach i in hinw_idda hiearn htot_idda { 
	
	replace `i' = `i'/PCEPI
}

collapse (median) hinw_iddamedian = hinw_idda (mean) hinw_iddamean = hinw_idda  (median) hiearnmedian = hiearn (mean) hiearnmean = hiearn (median) htot_iddamedian = htot_idda (mean) htot_iddamean = htot_idda [aw = rwthh], by(xagea) 

reshape long hinw_idda hiearn htot_idda, i(xagea) j(stat) string

graph bar hinw_idda hiearn , over(xagea) over(stat) legend(order(1 "Non-wage" 2 "Earnings")) stack ///
title("Household income components by age ($2022)") note("Source: HRS waves 5+. Median is derived from a pooled sample over multiple waves." "Values are inflation-adjusted before calculating median.") ///
name(median_incomecomp_xagea, replace)


graph export "$home/graphs/median_incomecomp_xagea.png" ,name(median_incomecomp_xagea) replace


*************************************
* draw scatter of wages to nonwage income by race for balanced panel of retirees 
clear
use $home/data/hrs_cleaned.dta, replace 

*keep if inrange(age, 59,69)
keep if inrange(age - retage, -6,4)

egen valid = count(hitot), by(hhidpn)
keep if valid == 6


gen hiearn_adj = hiearn/PCEPI if age < retage
gen hinw_adj = hinw_idda/PCEPI if age >= retage
collapse (mean) hiearn_adj hinw_adj age rwthh, by(hhidpn xred) 

/*
gen quintile_wages_xred = . 

foreach i in 0 1 2 { 
	
	xtile quintile_wages_temp = hiearn_adj [aw = rwthh] if xred == `i', nq(5)
	replace quintile_wages_xred = quintile_wages_temp if quintile_wages_xred == . 
	drop quintile_wages_temp
}

collapse (mean) hiearn_adj (mean) hinw_adj, by()*/
/*
gen y_pre = hitot/PCEPI if age < retage
gen y_post = hitot/PCEPI if age >= retage





foreach var in y_pre y_post hiearn_adj hinw_adj {
	
	quietly reg `var' age [aw = rwthh] 
	predict `var'_h
	gen e_`var' = `var' - `var'_h
	xtile p_`var' = e_`var' [aw = rwthh], nq(100)
}

gen lnhinw_adj = log(hinw_adj) 
gen lnhiearn_adj = log(hiearn_adj)
*/

binscatter hinw_adj hiearn_adj if inrange(age, 60,70) & xred != 3 & hiearn_adj >= 5000, ///
xtitle("Mean wages pre-retirement, 2022 dollars") ///
ytitle("") ///
msymbols(O T D) ///
note("Source: HRS wave 5+, individuals must be observed for 6 periods centered around retirement. " "Retirement age within 60-70. Mean earnings must be aboe $5,000. Data is binned into 5 equal-sized groups.") title("Mean non-wage income post-retirement, 2022 dollars") ///
name(scatter_ret_passthru_xred, replace) by(xred) line(none) n(5) ///
ylab(0(50000)200000) xlab(0(50000) 200000)

graph export "$home/graphs/scatter_ret_passthru_xred.png", name(scatter_ret_passthru_xred) replace

***********************************************************************
* Draw Pr(WSI >0 | htot_idda  quartile)

global home "C:\Users\IRRJL01\Dropbox\personal\IDDA\nuggets" 


use $home/data/hrs_cleaned.dta, replace 

*sensitivity check
*replace pos_wsi = 1 if hiearn > 1250 & hiearn != .  
*replace pos_wsi = 0 if hiearn <= 1250 

* keep 65 +
*keep if inrange(age,65,75) 
*keep if inlist(xaged, 5)
keep if xaged >= 5 
* calculate within-year quartiles of nonwage income for 65+
gen py0_nwi = .
gen py0_htot = . 
gen py0_asset = .
 * calculate for 2000 beyond only, because sample has a consistent age distribution after then - see, 'HRS Longitudinal Cohort sample design' https://hrs.isr.umich.edu/documentation/survey-design
forvalues year = 2000(2)2022 { 
	
	*xtile py0_nwi_`year' = hinw_idda [aw = rwthh] if year == `year'  , nquantiles(2)
	xtile py0_htot_`year' = htot_idda [aw = rwthh] if year == `year' , nquantiles(4)
	xtile py0_asset_`year' = hatotb [aw = rwthh] if year == `year' , nquantiles(4)
	
	*replace py0_nwi = py0_nwi_`year' if py0_nwi == . 
	replace py0_htot = py0_htot_`year' if py0_htot == . 
	replace py0_asset = py0_asset_`year' if py0_asset == . 
	
	*drop py0_nwi_`year' 
	drop py0_htot_`year' 
		drop py0_asset_`year' 
	}

*reg pos_wsi age [aw = rwthh]
*predict pos_wsi_hat
*gen resid_pos_wsi = pos_wsi - pos_wsi_hat
loc bin htot
keep if py0_`bin' != .
collapse (mean) pos_wsi (mean) age (count) hhidpn [aw = rwthh], by(year py0_`bin')

twoway 	(connected pos_wsi year if py0_`bin' == 1) ///
		(connected pos_wsi year if py0_`bin' == 4), ///
		title("Pr(WSI>0 | aged 65+)") ///
		note("HRS waves 5+, households where oldest member is 65+.") ///
		legend(title("household income") order(1 "Bottom-quartile" 2 "Top-quartile")) ///
		name(pos_wsi, replace) 
		
		
loc bin htot		
foreach i in 1 2 3 4 { 
	
	sum pos_wsi if year == 2000 & py0_`bin' == `i' 
	replace pos_wsi = pos_wsi/`r(mean)' if py0_`bin' == `i'
	
} 	

twoway 	(connected pos_wsi year if py0_`bin' == 1) ///
		(connected pos_wsi year if py0_`bin' == 4), ///
		title("Growth in pr(WSI>0 | aged 65+) since 2000") ///
		note("HRS waves 5+, households where oldest member is 65+.") ///
		legend(title("household income") order(1 "Bottom-quartile" 2 "Top-quartile")) ///
		name(pos_wsi_growth, replace) 
			
		
graph export "$home/graphs/pos_wsi.png", replace name(pos_wsi)	

graph export "$home/graphs/pos_wsi_grwth.png", replace name(pos_wsi_growth)		

***********************************************************************
* Draw Pr(WSI_t+1 > 0) | WSI_t ==0) for 65+, by hh inc quartile

global home "C:\Users\IRRJL01\Dropbox\personal\IDDA\nuggets" 
use $home/data/hrs_cleaned.dta, replace 

*sensitivity check
*replace pos_wsi = 1 if hiearn > 1250 & hiearn != .  
*replace pos_wsi = 0 if hiearn <= 1250 

* keep 65 +
*keep if inrange(age,65,75) 
keep if xaged >= 5 
* calculate within-year quartiles of nonwage income for 65+
gen py0_nwi = .
gen py0_htot = . 
gen py0_asset = .
 * calculate for 2000 beyond only, because idda income variables only defined past then
forvalues year = 2000(2)2022 { 
	
	*xtile py0_nwi_`year' = hinw_idda [aw = rwthh] if year == `year'  , nquantiles(2)
	xtile py0_htot_`year' = htot_idda [aw = rwthh] if year == `year' , nquantiles(4)
	xtile py0_asset_`year' = hatotb [aw = rwthh] if year == `year' , nquantiles(4)
	
	*replace py0_nwi = py0_nwi_`year' if py0_nwi == . 
	replace py0_htot = py0_htot_`year' if py0_htot == . 
	replace py0_asset = py0_asset_`year' if py0_asset == . 
	
	*drop py0_nwi_`year' 
	drop py0_htot_`year' 
		drop py0_asset_`year' 
	}
	
tsset(hhidpn year)

by hhidpn: gen change_to_nonwage_income = ( hinw_idda[_n]/ hinw_idda[_n-1]) - 1

by hhidpn: gen enter_labor_force = (hiearn[_n] == 0) & (hiearn[_n +1] > 0 & hiearn[_n +1] != .)

keep if hiearn == 0	

binscatter  enter_labor_force change_to_nonwage_income if change_to_nonwage_income < 5 & inlist(py0_htot,1,4)  [aw = rwthh], by(py0_htot)  ms(T O) ///
title("Prob(wsi{sub:t+1} > 0) | wsi{sub:t} == 0") note("Source: HRS Waves 5+, households where oldest member is 65+, pooled sample""Binned scatterplot, each group is divided into 20 equal-sized groups. lt25 n = 10,070, gt75 n = 2,762""Obs with shock > 5 dropped") ///
xtitle("(nwi{sub:t} / nwi{sub:t-1}) - 1") legend(title("hh income quartile")  lab(1 "lt25")  lab(2 "gt75")) ///
name(labor_force_entry_post_shock,replace) line(qfit)

graph export "$home/graphs/labor_force_entry_post_shock.png", name(labor_force_entry_post_shock) replace
	
**********************************************

*keep working on fan out for wsi vs nwi

use $home/data/hrs_cleaned.dta, replace
keep if hinw_idda != .


replace hinw_idda = hinw_idda/PCEPI
replace hiearn = hiearn/PCEPI


gen py0_htot_65 = .
forvalues year = 2000(2)2022 { 
	
	xtile py0_htot_`year' = htot_idda [aw = rwthh] if year == `year' & xaged >= 5, nquantiles(2)
	replace py0_htot_65 = py0_htot_`year' if py0_htot_65 == .
	drop py0_htot_`year'  
}
gen py0_htot_55t64 = .
forvalues year = 2000(2)2022 { 
	
	xtile py0_htot_`year' = htot_idda [aw = rwthh] if year == `year' & xaged == 4, nquantiles(2)
	replace py0_htot_55t64 = py0_htot_`year' if py0_htot_55t64 == .
	drop py0_htot_`year'  
}
 
	
preserve	
collapse (median) p50 = hinw_idda [aw = rwthh], by(year py0_htot_65)
tempfile temp
gen inc = "nwi, 65+"
rename py0_htot_65 py0_htot
save `temp' 

restore
collapse (median) p50 = hiearn [aw = rwthh], by(year py0_htot_55t64)
gen inc = "wsi, 55t64"
rename py0_htot_55t64 py0_htot
append using `temp'


/*
twoway (connected p50 year if py0_htot == 4) ///
(connected p50 year if py0_htot == 1),  name(pctl_levels,replace) ///
	title("Real non-wage household income ($ 2019)") subtitle("Sample = household head aged 65+") ///
	note("Source: HRS wave 5+. Household head = oldest household member") 
*/ 
foreach v in "wsi, 55t64" "nwi, 65+" {
foreach i in 1 2 { 
	
	sum p50 if year == 2000 & py0_htot == `i' & inc == "`v'"
	replace p50 = p50/`r(mean)' if py0_htot == `i' & inc == "`v'"
	
}
}

twoway (connected p50 year if py0_htot == 1) (connected p50 year if py0_htot == 2), by(inc)

twoway (connected p50 year if py0_htot == 4) ///
(connected p50 year if py0_htot == 1),  name(pctl_grwth,replace) ///
	title("Real growth in median non-wage household income") subtitle("Normalized to 2000 values. Sample = household head aged 65+") ///
	note("Source: HRS wave 5+. Household head = oldest household member") legend(title("hh income quartile") lab(1 "gt75") lab(2 "lt25"))
	
	
graph export "$home/graphs/median_nwi_growth.png", name(pctl_grwth) replace	

**********************************************



use $home/data/hrs_cleaned.dta, replace
keep if hinw_idda != .

replace hinw_idda = hinw_idda/PCEPI
replace hiearn = hiearn/PCEPI


gen py0_htot_65 = .
forvalues year = 2000(2)2022 { 
	
	xtile py0_htot_`year' = htot_idda [aw = rwthh] if year == `year' & xaged >= 5, nquantiles(4)
	replace py0_htot_65 = py0_htot_`year' if py0_htot_65 == .
	drop py0_htot_`year'  
}
gen py0_htot_55t64 = .
forvalues year = 2000(2)2022 { 
	
	xtile py0_htot_`year' = htot_idda [aw = rwthh] if year == `year' & xaged == 4, nquantiles(4)
	replace py0_htot_55t64 = py0_htot_`year' if py0_htot_55t64 == .
	drop py0_htot_`year'  
}
 


sort hhidpn year

by hhidpn: gen chg_nwi = (hinw_idda[_n+1] / hinw_idda[_n]) - 1 		
by hhidpn: gen chg_wsi = (hiearn[_n+1] / hiearn[_n]) - 1 	


preserve	
collapse (p50) p50 = chg_nwi [aw = rwthh], by(year py0_htot_65)
tempfile temp
gen inc = "nwi, 65+"
rename py0_htot_65 py0_htot
save `temp' 

restore
collapse (p50) p50 = chg_wsi [aw = rwthh], by(year py0_htot_55t64)
gen inc = "wsi, 55t64"
rename py0_htot_55t64 py0_htot
append using `temp'


twoway (connected p50 year if py0_htot == 4) ///
(connected p50 year if py0_htot == 1) ///
, by(inc, title("Median income change")) legend(title("hh inc quartile") order(1 "gt75" 2 "lt25")) ///
name(median_chg_xinc, replace) 

graph export $home/graphs/median_chg_xinc.png, name(median_chg_xinc) replace

**********************************************
*mean nwi share of hhincome by total hh income quartile

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
	*xtile py0_asset_`year' = hatotb [aw = rwthh] if year == `year' , nquantiles(2)
	
	replace py0_nwi = py0_nwi_`year' if py0_nwi == . 
	replace py0_htot = py0_htot_`year' if py0_htot == . 
	*replace py0_asset = py0_asset_`year' if py0_asset == . 
	
	drop py0_nwi_`year' 
	drop py0_htot_`year' 
	*	drop py0_asset_`year' 
	}

collapse (median) median_nw_share = nw_share_of_total_income (mean) mean_nw_share = nw_share_of_total_income (count) n = nw_share_of_total_income [aw = rwthh], by(py0_htot)

graph bar mean_nw_share, over(py0_htot) note("Source: Pooled HRS wave 5+, where oldest member of household is 65+") ytitle("") title("Mean nonwage share of household income | 65+") subtitle("By quartiles of household income") ///
ylab(0(0.25)1) name(mean_nw_share,replace)

graph export "$home/graphs/mean_nw_share.png", name(mean_nw_share) replace


/*
*********************************************
* exposure of HRS panel 2016-2022 to rising prices, sample is households aged 65-70 in 2016, by above/below median of total household income (wealth) in 2016

global home "C:\Users\IRRJL01\Dropbox\personal\IDDA\nuggets"

use $home/data/hrs_cleaned.dta, replace 

*keep panel of individuals observed between 2016-22
keep if inrange(year, 2016,2022)
drop if hitot == .
egen count_obs = count(hitot), by(hhidpn)
keep if count_obs == 4
drop count_obs

egen earnings_sum = total(hiearn), by(hhidpn)

*restrict further to those who are aged 65-70 in 2016
preserve
keep if year == 2016
gen age_y0 = age 
gen retired_2016 = age >= retage
gen zero_earnings_2016 = hiearn == 0
keep hhidpn age_y0 retired_2016 zero_earnings_2016
tempfile temp 
save `temp'
restore
merge m:1 hhidpn using `temp', nogen
*keep if retired_2016 == 1
*keep if inlist(age_y0, 65,66)
keep if inrange(age_y0, 65,70)
*keep if earnings_sum == 0 & inrange(age_y0, 65,70)
*keep if retage == age_y0 & inrange(age_y0, 65,75)

* calculate above/below median of household income/wealth in 2016 amongst sample
preserve
keep if year == 2016
xtile nwi_2016 = hinw_idda [aw = rwthh], n(2)  
xtile wealth_2016 = hatotb [aw = rwthh], n(2)
xtile income_2016 = htot_idda [aw = rwthh], n(2)
keep hhidpn nwi_2016 income_2016 wealth_2016
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
keep if `bin'_2016!= .
*keep if TC != . 



collapse (median) hinw_idda (median) hinw_idda_unearned (mean) pos_wsi (median) htot_idda (mean) pos_earn [aw = rwthh], by(`bin'_2016 year)
reshape wide hinw_idda hinw_idda_unearned pos_wsi htot_idda pos_earn, i(year) j(`bin'_2016)

foreach i in 1 2 { 
	
	sum hinw_idda`i' if year == 2016
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
		

 
/*
binscatter lnhinw_adj lnhiearn_adj [aw = rwthh] if inrange(age, 60,70) & xred != 3 & hiearn_adj >= 40000, ///
xtitle("Log mean wages pre-retirement, 2019 dollars") ///
ytitle("") ///
note("Source: HRS all waves, individuals must be observed for 6 periods centered around retirement. " "Retirement age within 60-70. Data is binned into 20 equal-sized groups. The binned mean is reported.") title("Log mean non-wage income post-retirement, 2019 dollars") ///
name(scatter_ret_passthru_xred, replace) by(xred) line(none)

binscatter y_pre y_post [aw = rwthh] if inrange(age, 60,70) & xred != 3, ///
xtitle("Mean wages pre-retirement, 2019 dollars") ///
ytitle("") ///
note("Source: HRS all waves, individuals must be observed for 6 periods centered around retirement. " "Retirement age within 60-70. Data is binned into 20 equal-sized groups. The binned mean is reported.") title("Mean non-wage income post-retirement, 2019 dollars") ///
name(scatter_ret_passthru_xred, replace) by(xred) line(none)*/

*************************************
* Mean probability of positive WSI over age by generation 
clear
global home "C:\Users\IRRJL01\Dropbox\personal\IDDA\nuggets"
use $home/data/hrs_cleaned.dta, replace 
keep if year >= 1998  
* calculate for 1998 beyond only, because sample has a consistent age distribution after then - see, 'HRS Longitudinal Cohort sample design' https://hrs.isr.umich.edu/documentation/survey-design
collapse (mean) pos_wsi (count) n = pos_wsi [aw = rwthh], by(gena age)


twoway	(connected pos_wsi age if gena == 0) ///
		(connected pos_wsi age if gena == 1) ///
		(connected pos_wsi age if gena == 2)  if inrange(age,65,85), ///
		legend(order(1 "greatest" 2 "silent" 3 "boom" ) sub("generation")) ///
		xlabel(,value) ///
		title("Probability of positive wsi") note("source = HRS, waves 2+") name("pos_wsi_xgene", replace)

		graph export $home/graphs/pos_wsi_xgene.png, name(pos_wsi_xgene) replace
		
/*		
twoway	(connected pos_wsi age if generation == 0) ///
		(connected pos_wsi age if generation == 1) ///
		(connected pos_wsi age if generation == 2) ///
		(connected pos_wsi age if generation == 3) ///
		(connected pos_wsi age if generation == 4) ///
		(connected pos_wsi age if generation == 5) ///
		if inrange(age,65,85), 
		xlabel(,value)
*/		


 
 
		









