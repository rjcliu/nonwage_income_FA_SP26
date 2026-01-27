import delimited "C:\Users\IRRJL01\Dropbox\OIGI MIDI\data\bulk_download\volatility_all_data.csv", clear



keep if group_var == "xall"
keep if samp == "all_1040_mafid"
keep if geo_var == "usst"
keep if inc_var == "GI" 
keep if pctl_y1 == "50" 
keep if lag == 1



twoway (connected value y0 if pctl_y0 == "lt25", ) ///
(connected value y0 if pctl_y0 == "25t50") ///
(connected value y0 if pctl_y0 == "50t75") ///
(connected value y0 if pctl_y0 == "75t90") ///
(connected value y0 if pctl_y0 == "gt90"), ///
legend(order(1 "lt25" 2 "25t50" 3 "50t75" 4 "75t90" 5 "gt90")) ///
title("year-to-year mean AGI change by starting income") ///
xtitle("year") ytitle("nominal dollars")
