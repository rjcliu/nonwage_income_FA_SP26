clear
import delimited "C:\Users\IRRJL01\Dropbox\OIGI MIDI\data\bulk_download\volatility_all_data.csv"


keep if inc_var == "TC"
keep if geo_var == "usst"
keep if samp == "prime_age_working_w2"
keep if lag == 5
keep if inlist(pctl_y1,"10","50","90")

reshape wide value, i(y0 group_var_val pctl_y0) j(pctl_y1) string

gen dif9050 = value90 - value50 
gen dif5010 = value50 - value10

preserve
keep if inlist(pctl_y0, "gt90", "lt25")		
		
twoway 	connected (dif9050 y0) if group_var == "xall" || ///
		connected (dif5010 y0) if group_var == "xall", by(pctl_y0, ///
		note("Difference between median 5-year annualized transition and p90(blue)/p10(red)." "PAW-w2, usst, xall."))
		


