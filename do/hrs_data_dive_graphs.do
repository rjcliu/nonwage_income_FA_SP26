*Draw stacked area charts of nonwage income components across age 
	* Draw charts by tercile of household earnings at age 53/54

global home "C:\Users\IRRJL01\Dropbox\personal\IDDA\nuggets"
use $home/data/hrs_cleaned.dta, replace 

*convert incomes to real values for this exercise
foreach i in capital transfer pension earned socsec othr hinw_idda hiearn htot_idda { 
	
	replace `i' = `i'/PCEPI
} 

*calculate mean value of nonwage income components by age and tercile of household income at age 53/54 (com)
keep if hinw_idda != . & TC != .
collapse (mean) capital (mean) transfer (mean) pension (mean) earned (mean) socsec (mean) othr (mean) hinw_idda (mean) htot_idda (mean) hiearn [aw = rwthh], by(xaged TC) 

foreach i in capital transfer pension earned socsec othr { 
	
	rename `i' mean`i'
}

keep if inlist(TC,1,3)
reshape long mean, i(xaged TC) j(income_type) string

/*convert string values to labeled numeric for easy ordering */ 
replace income_type = "5" if income_type == "transfer" 
replace income_type = "4" if income_type == "socsec" 
replace income_type = "3" if income_type == "pension"
replace income_type = "2" if income_type == "capital"
replace income_type = "1" if income_type == "earned"
replace income_type = "0" if income_type == "othr" 

destring income_type, replace 


label define income 5 "transfer" 4 "socsec" 3 "pension" 2 "capital" 1 "earned" 0 "othr" 
label values income_type income 

sort TC xaged -income_type 


bysort TC xaged: gen cum_sum_high = sum(mean)
gen cum_sum_low = cum_sum_high - mean

 twoway ///
    (rarea cum_sum_low cum_sum_high xaged if inc== 0 , color(stc1)) ///
    (rarea cum_sum_low cum_sum_high xaged if inc== 1, color(stc2)) ///
	(rarea cum_sum_low cum_sum_high xaged if inc== 2, color(stc3)) ///
    (rarea cum_sum_low cum_sum_high xaged if inc== 3, color(stc4)) ///
	(rarea cum_sum_low cum_sum_high xaged if inc== 4, color(stc5)) ///
	(rarea cum_sum_low cum_sum_high xaged if inc== 5, color(stc6)) if TC == 1, ///
	legend(order(6 "transfer" 5 "socsec" 4 "pension" 3 "capital" 2 "earned" 1 "othr")) ///
	xlabel(,val) title("Composition of total nonwage household income ($2022)") ///
	subtitle("Bottom tercile of income at age 53/54") ///
	note("Capital = financial/rental income. Earned = self-employment/business income. Pension = IRA disbursements/pensions." ///
	"Transfer = DI/UI. Source: HRS Wave 5+, pooled sample.") ytitle("") xtitle("age") ///
	name(hi_shares_bot, replace)
	
 twoway ///
    (rarea cum_sum_low cum_sum_high xaged if inc== 0 , color(stc1)) ///
    (rarea cum_sum_low cum_sum_high xaged if inc== 1, color(stc2)) ///
	(rarea cum_sum_low cum_sum_high xaged if inc== 2, color(stc3)) ///
    (rarea cum_sum_low cum_sum_high xaged if inc== 3, color(stc4)) ///
	(rarea cum_sum_low cum_sum_high xaged if inc== 4, color(stc5)) ///
	(rarea cum_sum_low cum_sum_high xaged if inc== 5, color(stc6)) if TC == 3, ///
	legend(order(6 "transfer" 5 "socsec" 4 "pension" 3 "capital" 2 "earned" 1 "othr")) ///
	xlabel(,val) title("Composition of total nonwage household income ($2022)") ///
	subtitle("Top tercile of income at age 53/54") ///
	note("Capital = financial/rental income. Earned = self-employment/business income. Pension = IRA disbursements/pensions." ///
	"Transfer = DI/UI. Source: HRS Wave 5+, pooled sample.") ytitle("") xtitle("age") ///
	name(hi_shares_top, replace)
	

graph export "$home/graphs/hi_shares_top.png", name(hi_shares_top) replace
graph export "$home/graphs/hi_shares_bot.png", name(hi_shares_bot) replace	


keep xaged TC income_type mean cum_sum_high cum_sum_low
order TC xaged income_type mean cum_sum_low cum_sum_high

export delimited "$home/out/data_dive_graphs.csv", replace