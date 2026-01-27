global home "C:\Users\IRRJL01\Dropbox\personal\IDDA\nuggets\" 

frames reset 

include $home\do\00_hrs.do
tempfile temp 
save `temp' 

clear
include $home\do\00_hrs_cap.do 
merge 1:1 hhidpn year using `temp', keep(3)

*keep only past wave 5+ since that's when IRA variable is introduced
keep if year >= 2000  

* calculate an 'IDDA nonwage' equivalent using HRS components
* some components - trust, savings, and stock income are discontinued in later surveys. We impute these discontinued contents to 0 (sum using rowtotal()) 
egen hint = rowtotal(hisav hibndin hicdin hichkin ) if rwthh != . /*savings accounts, bonds, cds, checking, */

egen hinw_idda = rowtotal(hidivin hibusin hirntin hipena hisret hiunem hisemp hint hiothr hitrsin histk hiothi hiirawy1) if rwthh != .  /* dividends, business, rental, pensions + annuities, socsec, UI, self-employment, interest, misc. asset income, misc. nonasset + nonwage income, + trust interest + annual IRA disbursement */


gen hitot_idda = hinw_idda + riearn + siearn



foreach i in hitot_idda hinw_idda hiearn hidivin hibusin hirntin hipena hisret hiunwc hisemp hint hiothr hitrsin histk hiothi hiirawy1 hatotb {
	gen `i'_adj = `i'/PCEPI
	loc adj_incs `adj_incs' `i'_adj
}
drop if age < 50


*generate cross section of nwi bin
gen py0_nw_idda = . 
forvalues y = 2000(2)2022 { 
		
		xtile py0_nw_idda_`y'  = hinw_idda if year == `y', ///
		nquantiles(4)
		
		replace py0_nw_idda = py0_nw_idda_`y' if py0_nw_idda == . 
		drop py0_nw_idda_`y'
	} 

gen hiearn_positive = hiearn > 0 *rwthh if hiearn != . 

collapse (sum) rwthh (sum) hiearn_positive , by(year py0_nw_idda)


/* Wealth v nonwage income */

binscatter hinw_idda hatotb [aw = rwthh] if year == 2010 & xred != 3, line(none) ///
title("Household non-wage income") note("Source: HRS, Wave 10 (2010)." "Non-wage income is total household income less earnings plus total IRA withdrawals in the last year.") xtitle("Total household wealth") ytitle("2019 dollars") name(scatter_wealth_nwi_xred, replace) by(xred)

graph export $home\graphs\scatter_wealth_nwi.png, name(scatter_wealth_nwi_xred) replace

collapse (mean) `adj_incs' [aw = rwthh], by(xaged)

preserve

keep hiearn_adj hinw_idda_adj xaged
reshape long hi, i(xaged) j(y) string 
by xaged: gen cum_sum = sum(hi)
gen cum_low = cum_sum - hi

twoway (rarea cum_sum cum_low xaged if y == "earn_adj", fc(stc1) fi(inten80) lc(gs15)) || ///
	(rarea cum_sum cum_low xaged if y == "nw_idda_adj", fc(stc1) fi(inten10)  lc(gs15)) ///
	if inrange(xaged, 4,7), ///
	legend(order(1 "labor income" 2 "nonwage income")) ///
	title("Average total real household income") name(hh_total, replace) xlabel(,value) ///
	xtitle("age") ytitle("2019 dollars") note("Source: Health and Retirement Study, wave 5+")
	
graph export $home/graphs/hh_total.png, name(hh_total) replace	

restore
preserve

keep xaged hicap_int hibusin hirntin hisemp hipen hissdi hisret hiunwc higxfr hiothr hiirawy1
reshape long hi, i(xaged) j(y) string 
by xaged: gen cum_sum = sum(hi)
gen cum_low = cum_sum - hi

twoway (rarea cum_sum cum_low xaged if y == "busin_adj") || ///
	(rarea cum_sum cum_low xaged if y == "cap_int_adj") ///
	(rarea cum_sum cum_low xaged if y == "gxfr_adj") ///
	(rarea cum_sum cum_low xaged if y == "irawy1_adj") ///
	(rarea cum_sum cum_low xaged if y == "othr_adj") ///
	(rarea cum_sum cum_low xaged if y == "pena_adj") ///
	(rarea cum_sum cum_low xaged if y == "rntin_adj") ///
	(rarea cum_sum cum_low xaged if y == "semp_adj") ///
		(rarea cum_sum cum_low xaged if y == "sret_adj") ///
		(rarea cum_sum cum_low xaged if y == "ssdi_adj") ///
		(rarea cum_sum cum_low xaged if y == "unwc_adj") ///
	if inrange(xaged, 4,7), ///
	legend(order(1 "business" 2 "financial" 3 "transfer" 4 "ira" 5 "other" 6 "pensions" 7 "rental" 8 "self-employment" 9 "soc-sec" 10 "ssdi" 11 "UI/comp")) ///
	title("Average total real  non-wage income") name(nw_total, replace) xlabel(,value) ///
	xtitle("age") ytitle("2019 dollars") note("Source: Health and Retirement Study, wave 5+")

graph export $home/graphs/nw_total.png, name(nw_total) replace	
	
	





