/* FB vs NFB transitions, 2007 + 2014  */ 

frames reset
clear
import delimited "C:\Users\IRRJL01\Dropbox\OIGI MIDI\data\bulk_download\volatility_all_data.csv"

keep if group_var == "xfb"
keep if inc_var == "TC"
keep if geo_var == "usst"
keep if samp == "prime_age_working_w2"
keep if lag == 5
keep if pctl_y0 == "lt25" & inlist(pctl_y1,"10","50","90")
keep if inlist(y0, 2007, 2014)
gen xfb = "fb" if group_var_val == "Foreign_Born"
replace xfb = "us" if group_var_val == "Not_Foreign_Born"

reshape wide value, i(y0 xfb) j(pctl_y1) string

frames create pctls 
cwf pctls

import delimited "C:\Users\IRRJL01\Dropbox\OIGI MIDI\data\bulk_download\pctl_of_inc_all_data.csv"
keep if group_var == "xfb"
keep if inc_var == "TC"
keep if geo_var == "usst"
keep if samp == "prime_age_working_w2"
gen xfb = "fb" if group_var_val == "Foreign_Born"
replace xfb = "us" if group_var_val == "Not_Foreign_Born"

foreach i in pctl90 pctl50 pctl25 {

	foreach j in fb us {
	
		foreach k in 2007 2014 {
	 
			sum `i' if xfb == "`j'" & year == `k' 
			loc `i'_`j'_`k' = `r(mean)'

		}	
	}
}	

cwf default 


foreach i in 10 50 90 { 

	replace value`i' = value`i'/`pctl25_fb_2007' if y0 == 2007 & xfb == "fb"
	replace value`i' = value`i'/`pctl25_us_2007' if y0 == 2007 & xfb == "us"
	replace value`i' = value`i'/`pctl25_fb_2014' if y0 == 2014 & xfb == "fb"
	replace value`i' = value`i'/`pctl25_us_2014' if y0 == 2014 & xfb == "us"
	
}


graph bar value10 value50 value90, over(xfb) by(y0,  ///
	title("Tails + median of income changes for bottom 25% earners") /// 
	note("Annualized 5-year, TC, usst, PAW-w2. FB = Foreign born, US = Non-foreign born" ///
			"Changes scaled to proportion of 25th percentile of income for xfb group in 2007/2014")) ///
	legend(order(1 "p10" 2 "p50" 3 "p90")) 
	
/* Male v Female transitions, 2009 + 2014 */ 

frames reset
clear
import delimited "C:\Users\IRRJL01\Dropbox\OIGI MIDI\data\bulk_download\volatility_all_data.csv"

keep if group_var == "xsex"
keep if inc_var == "TC"
keep if geo_var == "usst"
keep if samp == "prime_age_working_w2"
keep if lag == 5
keep if pctl_y0 == "25t50" & inlist(pctl_y1,"10","50","90")
keep if inlist(y0, 2007, 2014)


reshape wide value, i(y0 group_var_val) j(pctl_y1) string

foreach i in 10 50 90 { 
	
	replace value`i' = value`i'/1000
}

graph bar value10 value50 value90, over(group_var_val) by(y0,  ///
	title("Tails + median of income changes for 25t50 earners") /// 
	note("Annualized 5-year, TC, usst, PAW-w2. ")) ///
	legend(order(1 "p10" 2 "p50" 3 "p90"))  ytitle("$ (1000s)")
		
	

