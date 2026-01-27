*trim to a balanced panel of households in HRS, centered around retirement. Generate mean labor income before retirement age and mean nw income after retirement. Calculate percentiles, then scatter mean nwi pctl X mean earnings pctl
	* additionally, scatter pre and post-retirement total income pctls.

loc inc PE

global home "C:\Users\IRRJL01\Dropbox\personal\IDDA\nuggets\" 

frames reset 

include $home\do\00_hrs.do

 
*keep if inrange(age, 59,69)
keep if inrange(age - retage, -6,4)

egen valid = count(hitot), by(hhidpn)
keep if valid == 6


gen hiearn_adj = hiearn/PCEPI if age < retage
gen hinw_adj = hinw/PCEPI if age >= retage

gen y_pre = hitot/PCEPI if age < retage
gen y_post = hitot/PCEPI if age >= retage

collapse (mean) y_pre y_post hiearn_adj hinw_adj age rwthh, by(hhidpn xred) 



foreach var in y_pre y_post hiearn_adj hinw_adj {
	
	quietly reg `var' age [aw = rwthh] 
	predict `var'_h
	gen e_`var' = `var' - `var'_h
	xtile p_`var' = e_`var' [aw = rwthh], nq(100)
}

binscatter hinw_adj hiearn_adj [aw = rwthh] if inrange(age, 60,70) & xred != 3, ///
xtitle("Mean earnings pre-retirement, 2019 dollars") ///
ytitle("") ///
note("Source: HRS all waves, individuals must be observed for 6 periods centered around retirement. " "Retirement age within 60-70. Data is binned into 20 equal-sized groups. The binned mean is reported.") title("Mean non-wage income post-retirement, 2019 dollars") ///
name(scatter_ret_passthru_xred, replace) line(none) by(xred)

graph export $home/graphs/scatter_ret_passthru_xred.png, replace 

preserve
collapse (mean) avg = p_hinw_adj (max) max = p_hinw_adj (min) min = p_hinw_adj, by(p_hiearn_adj xred) 

twoway (scatter avg p_hiearn_adj) (lfit avg p_hiearn_adj), by(xred, ///
note("axes are across-race percentiles. earnings are residualized by retirement age.  race = race of oldest hh member." ///
"sample is HRS households where we observe 3 obs. pre- and post-retirement. earnings = household earnings.") ///
title("resid. nw earnings, post retirement") legend(off)) ///
xtitle("resid. labor earnings, pre-retirement")  ///
name("ret_passthru_xinc", replace) 


restore
preserve 
collapse (mean) avg = p_y_post (count) hhidpn, by(p_y_pre xred)
twoway (scatter avg p_y_pre) (lfit avg p_y_pre), by(xred, ///
note("axes are across-race percentiles. earnings are residualized by retirement age. race = race of oldest hh member." ///
"sample is HRS households where we observe 3 obs. pre- and post-retirement. earnings = household earnings. ") ///
title("resid. total earnings, post retirement") legend(off)) ///
xtitle("resid. total earnings, pre-retirement") ///
name("ret_passthru_xall", replace)


graph export $home/graphs/ret_passthru_xinc.png, name(ret_passthru_xinc) replace
graph export $home/graphs/ret_passthru_xall.png, name(ret_passthru_xall) replace

restore

drop p_*


foreach var in y_pre y_post hiearn_adj hinw_adj {
gen p_`var' = . 
} 

foreach race in 0 1 2 3 { 
foreach var in y_pre y_post hiearn_adj hinw_adj {
	xtile p_`var'_red = e_`var' [aw = rwthh] if xred == `race', nq(100)
	replace p_`var' = p_`var'_red if p_`var' == .
	drop p_`var'_red
}
}

preserve
collapse (mean) avg = p_hinw_adj (max) max = p_hinw_adj (min) min = p_hinw_adj, by(p_hiearn_adj xred) 

twoway (scatter avg p_hiearn_adj) (lfit avg p_hiearn_adj), by(xred, ///
note("axes are within-race percentiles. earnings are residualized by retirement age.  race = race of oldest hh member." ///
"sample is HRS households where we observe 3 obs. pre- and post-retirement. earnings = household earnings.") ///
title("resid. nw earnings, post retirement") legend(off)) ///
xtitle("resid. labor earnings, pre-retirement")  ///
name("ret_passthru_xinc_wn", replace) 


restore
preserve 

collapse (mean) avg = p_y_post (count) hhidpn, by(p_y_pre xred)

twoway (scatter avg p_y_pre) (lfit avg p_y_pre), by(xred, ///
note("axes are within-race percentiles. earnings are residualized by retirement age. race = race of oldest hh member." ///
"sample is HRS households where we observe 3 obs. pre- and post-retirement. earnings = household earnings. ") ///
title("resid. total earnings, post retirement") legend(off)) ///
xtitle("resid. total earnings, pre-retirement") ///
name("ret_passthru_xall_wn", replace)


graph export $home/graphs/ret_passthru_xinc_wn.png, name(ret_passthru_xinc_wn) replace
graph export $home/graphs/ret_passthru_xall_wn.png, name(ret_passthru_xall_wn) replace




