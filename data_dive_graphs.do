global home "C:\Users\IRRJL01\Dropbox\personal\IDDA\nuggets"

use $home/data/hrs_cleaned.dta, replace 

*convert incomes to real values for this exercise
foreach i in capital transfer pension earned socsec othr hinw_idda hiearn htot_idda { 
	
	replace `i' = `i'/PCEPI
} 

*calculate components of average household income by age
keep if hinw_idda != . & TC != .
collapse (mean) capital (mean) transfer (mean) pension (mean) earned (mean) socsec (mean) othr (mean) hinw_idda (mean) htot_idda (mean) hiearn [aw = rwthh], by(xaged TC) 

foreach i in capital transfer pension earned socsec othr { 
	
	rename `i' mean`i'
}

keep if inlist(TC,1,3)

/*
foreach i in capital transfer pension earned socsec othr { 
	
	gen prop`i' = `i'/hinw_idda
}*/



reshape long mean, i(xaged TC) j(income_type) string
bysort xaged TC: gen mean_high = sum(mean)
gen mean_low = mean_high - mean

 twoway ///
    (rarea mean_low mean_high xaged if inc=="capital" , color(stc1)) ///
    (rarea mean_low mean_high xaged if inc=="earned", color(stc2)) ///
	/*(rarea prop_low prop_high xaged if inc=="wages", color(stc7))*/ ///
	(rarea mean_low mean_high xaged if inc=="othr", color(stc3)) ///
    (rarea mean_low mean_high xaged if inc=="pension", color(stc4)) ///
	(rarea mean_low mean_high xaged if inc=="socsec", color(stc5)) ///
	(rarea mean_low mean_high xaged if inc=="transfer", color(stc6)) if TC == 1, ///
	legend(order(1 "capital" 2 "earned"  3 "other" 4 "pension" 5 "social security" 6 "transfer")) ///
	xlabel(,val) title("Composition of total nonwage household income ($2022)") ///
	subtitle("Bottom tercile of income at age 53/54") ///
	note("Capital = financial/rental income. Earned = self-employment/business income. Pension = IRA disbursements/pensions." ///
	"Transfer = DI/UI. Source: HRS Wave 5+, pooled sample.") ytitle("") xtitle("age") ///
	name(hi_shares_bot, replace)
	
 twoway ///
    (rarea mean_low mean_high xaged if inc=="capital" , color(stc1)) ///
    (rarea mean_low mean_high xaged if inc=="earned", color(stc2)) ///
	/*(rarea prop_low prop_high xaged if inc=="wages", color(stc7))*/ ///
	(rarea mean_low mean_high xaged if inc=="othr", color(stc3)) ///
    (rarea mean_low mean_high xaged if inc=="pension", color(stc4)) ///
	(rarea mean_low mean_high xaged if inc=="socsec", color(stc5)) ///
	(rarea mean_low mean_high xaged if inc=="transfer", color(stc6)) if TC == 3, ///
	legend(order(1 "capital" 2 "earned"  3 "other" 4 "pension" 5 "social security" 6 "transfer")) ///
	xlabel(,val) title("Composition of total nonwage household income ($2022)") ///
	subtitle("Top tercile of income at age 53/54") ///
	note("Capital = financial/rental income. Earned = self-employment/business income. Pension = IRA disbursements/pensions." ///
	"Transfer = DI/UI. Source: HRS Wave 5+, pooled sample.") ytitle("") xtitle("age") ///
	name(hi_shares_top, replace)

graph export "$home/graphs/hi_shares_top.png", name(hi_shares_top) replace
graph export "$home/graphs/hi_shares_bot.png", name(hi_shares_bot) replace	