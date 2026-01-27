clear
import delimited "C:\Users\IRRJL01\Dropbox\OIGI MIDI\data\bulk_download\volatility_all_data.csv"

keep if group_var == "xfb"
keep if inc_var == "TC"
keep if geo_var == "usst"
keep if samp == "prime_age_working_w2"
keep if lag == 5
keep if pctl_y0 == "lt25" & inlist(pctl_y1,"10","50","90")


		
twoway 	connected (value y0) if group_var_val == "Foreign_Born" & pctl_y1 == "10", ||	/// 
		connected (value y0) if group_var_val == "Not_Foreign_Born" & pctl_y1 == "10", lstyle(dashed) ||	/// 
		connected (value y0) if group_var_val == "Foreign_Born" & pctl_y1 == "90"   || 	///
		connected (value y0) if group_var_val == "Not_Foreign_Born" & pctl_y1 == "90", lstyle(dashed) ///
 		legend(order(1 "FB P10" 2 "NFB P10" 3 "FB P90" 4 "NFB P90"))

		
clear 

import delimited "C:\Users\IRRJL01\Dropbox\OIGI MIDI\data\bulk_download\volatility_all_data.csv"

keep if group_var == "xreaXsex"
keep if inc_var == "TC"
keep if geo_var == "usst"
keep if samp == "prime_age_working_w2"
keep if lag == 5
keep if pctl_y0 == "lt25" & inlist(pctl_y1,"10","50","90")


		
twoway 	connected (value y0) if group_var_val == "NH_Black_Male" & pctl_y1 == "10", ||	/// 
		connected (value y0) if group_var_val == "NH_White_Male" & pctl_y1 == "10", lstyle(dashed) ||	/// 
		connected (value y0) if group_var_val == "NH_Black_Male" & pctl_y1 == "50"  ||	///
		connected (value y0) if group_var_val == "NH_White_Male" & pctl_y1 == "50", lstyle(dashed) ||	///
		connected (value y0) if group_var_val == "NH_Black_Male" & pctl_y1 == "90"   || 	///
		connected (value y0) if group_var_val == "NH_White_Male" & pctl_y1 == "90", lstyle(dashed) ///
 		legend(order(1 "B P10" 2 "W P10" 3 "B P50" 4 "W P50" 5 "B P90" 6 "W P90"))

		
				
twoway 	connected (value y0) if group_var_val == "NH_White_Female" & pctl_y1 == "10", ||	/// 
		connected (value y0) if group_var_val == "NH_White_Male" & pctl_y1 == "10", lstyle(dashed) ||	/// 
		connected (value y0) if group_var_val == "NH_White_Female" & pctl_y1 == "50"  ||	///
		connected (value y0) if group_var_val == "NH_White_Male" & pctl_y1 == "50", lstyle(dashed) ||	///
		connected (value y0) if group_var_val == "NH_White_Female" & pctl_y1 == "90"   || 	///
		connected (value y0) if group_var_val == "NH_White_Male" & pctl_y1 == "90", lstyle(dashed) ///
 		legend(order(1 "F P10" 2 "M P10" 3 "F P50" 4 "M P50" 5 "F P90" 6 "M P90"))

