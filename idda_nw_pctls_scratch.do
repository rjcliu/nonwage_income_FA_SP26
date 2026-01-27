global home "C:\Users\IRRJL01\Dropbox\personal\IDDA\nuggets\" 

frames reset 

include $home\do\00_hrs.do
tempfile temp 
save `temp' 

keep if xagea == 4

keep if year == 2010

reg hinw age [aw = rwthh] 
predict hinw_h
gen hinw_e = hinw - hinw_h 

reg hiearn age [aw = rwthh] 
predict hiearn_h
gen hiearn_e = hiearn - hiearn_h 

xtile pctl_nw = hinw_e [aw = rwthh], nq(10)
xtile pctl_ws = hiearn_e [aw = rwthh], nq(10)

collapse (mean) pctl_nw, by(pctl_ws year)

twoway scatter pctl_nw pctl_ws, title("Mean decile of NWI, 55-64") xtitle("decile of WS, 55-64") ///
note("source = HRS 2010. earnings are residualized by age. ") ytitle("") name(pctls_hrs, replace)

graph export $home/graphs/pctls_hrs.png, name(pctls_hrs) replace




clear
import delimited $home\data\pctl_of_inc_all_data.csv

keep if inlist(inc_var,"WS","NW")
keep if geo_var_val == 0 & group_var_val == "55to64"

destring(pctl99_adj), replace

keep pctl50_adj pctl90_adj pctl99_adj year inc_var

twoway (line pctl50_adj pctl90_adj pctl99_adj year), by(inc_var, ///
note("source: IDDA. sample = tax filers aged 55 to 64. income = taxable income") ///
title("Real income percentiles ($ 2019)")) ///
legend(order(1 "p50" 2 "p90" 3 "p99")) ///
 name(idda_pctls, replace)

graph export $home/graphs/idda_pctls.png, name(idda_pctls) replace

/*
reshape wide pctl50_adj pctl90_adj pctl99_adj, i(year) j(inc_var) string

twoway 	(line pctl50_adjNW year, lp(dash) lc(stc1)) || ///
		(line pctl90_adjNW year, lp(dash) lc(stc2)) || ///
		(line pctl99_adjNW year, lp(dash) lc(stc3)) || ///
		(line pctl50_adjWS year, lp(solid) lc(stc1)) || ///
		(line pctl90_adjWS year, lp(solid) lc(stc2)) || ///
		(line pctl99_adjWS year, lp(solid) lc(stc3)) 

(line pctl50_adjWS pctl90_adjWS pctl99_adjWS year, lp(solid))

twoway (line pctl50_adj pctl90_adj pctl99_adj year), by(inc_var) 


