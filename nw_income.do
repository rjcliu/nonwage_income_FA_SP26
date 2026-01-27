clear
import delimited "C:\Users\IRRJL01\Dropbox\OIGI MIDI\data\bulk_download\pctl_of_inc_all_data.csv"

keep if level == "mafid"
keep if year == 2019
keep if inlist(group_var,"xall","xaged", "xagedXrea")
keep if geo_var == "usst"


foreach i in 99_9 99_99 99_999{ 
	
	 replace pctl`i'_adj = "" if pctl`i'_adj == "NA"
}

foreach i in 10 25 50 75 90 95 98 99 99_9 99_99 99_999 { 
	
	
	 destring pctl`i'_adj, replace  
	 drop pctl`i'
	 rename pctl`i'_adj pctl`i'
}



reshape long pctl, i(inc_var group_var_val) j(pct) string

rename pctl value

replace pct = subinstr(pct, "_", ".",. )

reshape wide value, i(group_var_val pct) j(inc_var) string 

/*Median NW by age group */ 

*preserve
keep if group_var == "xaged"
keep if pct == "50"
graph bar valueNW if pct == "50", over(group_var_val) ///
	title("Median nonwage income by age group") ///
	name(nw_age,replace)
*restore

/* Distribution of WS vs NW */


preserve 
keep if group_var == "xall"

graph bar valueWS valueNW, over(pct) ///
	title("Nonwage vs wage&salary income pctls") ///
	legend(order(1 "WS" 2 "NW" ))
	

/*Median WS vs NW income for 65+ indvls, by race */ 	
restore 	
preserve
keep if group_var == "xagedXrea"
keep if substr(group_var_val,1,6) == "65plus"	


gen xrea = "Hispanic" if strpos(group_var_val,"Hispanic") 

foreach i in Asian AIAN Black White { 

	replace xrea = "`i'" if strpos(group_var_val,"`i'") 
	replace xrea = "`i'" if strpos(group_var_val,"`i'") 
}



graph bar valueNW valueWS if pct == "50", over(xrea) ///
	legend(order(1 "NW" 2 "WS")) ///
	title("Median nonwage + wage&salary income for 65+")
	
preserve

/*Median GI vs NW income for 65+ indvls, by region */
clear
import delimited "C:\Users\IRRJL01\Dropbox\OIGI MIDI\data\bulk_download\pctl_of_inc_all_data.csv"

keep if level == "mafid"
keep if year == 2019
keep if inlist(group_var,"xall","xaged", "xagedXrea")
keep if geo_var_val != 0 

loc NE 9,10,23,24,25,33,34,36,42,44,50 
loc MW 17,18,19,20,26,27,29,31,38,39,46,55
loc SE 12,13,21,37,45,47,51,54 
loc SW 1,4,5,22,28,35,40,48
loc W 2,6,8,15,16,30,32,41,49,53,56

gen region = . 
replace region = 1 if inlist(geo_var_val, `NE') 
replace region = 2 if inlist(geo_var_val,`MW') 
replace region = 3 if inlist(geo_var_val,`SE')
replace region = 4 if inlist(geo_var_val,`SW')
replace region =5 if inlist(geo_var_val,`W')

label def region 1 "NE" 2 "MW" 3 "SE" 4 "SW" 5 "W"
lab val region region

foreach i in 99_9 99_99 99_999{ 
	
	 replace pctl`i'_adj = "" if pctl`i'_adj == "NA"
}

foreach i in 10 25 50 75 90 95 98 99 99_9 99_99 99_999 { 
	
	
	 destring pctl`i'_adj, replace  
	 drop pctl`i'
	 rename pctl`i'_adj pctl`i'
}

drop pctl99 pctl99_9 pctl99_99 pctl99_999

reshape long pctl, i(inc_var group_var_val geo_abb) j(pct) string

rename pctl value

replace pct = subinstr(pct, "_", ".",. )

reshape wide value, i(group_var_val pct geo_abb) j(inc_var) string 

/*Median WS vs NW income for 65+ indvls, by race */ 	
keep if group_var == "xaged"
keep if substr(group_var_val,1,6) == "65plus"	


*gen valueWS = valueGI - valueNW 

graph bar valueNW valueGI if pct == "50", over(region) ///
	legend(order(1 "NW" 2 "GI" )) ///
	title("Median nonwage + gross income for 65+") ///
	note("Year == 2019, values in 2019 dollars")
	
