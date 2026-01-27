* Draw Pr(WSI >0 | NWI quartile)

global home "C:\Users\IRRJL01\Dropbox\personal\IDDA\nuggets" 

use $home/data/hrs_cleaned.dta, replace 
* keep 65 +
keep if xagea == 5

reg pos_wsi age [aw = rwthh]
predict pos_wsi_hat
gen resid_pos_wsi = pos_wsi - pos_wsi_hat

collapse (mean) pos_wsi (mean) resid_pos_wsi (mean) age (mean) hiearn [aw = rwthh], by(year py0_nwi)

twoway 	(connected pos_wsi year if py0_nwi == 1) ///
		(connected pos_wsi year if py0_nwi == 2) ///
		(connected pos_wsi year if py0_nwi == 3) ///
		(connected pos_wsi year if py0_nwi == 4), ///
		xline(2007 2020) legend(order(1 "lt25" 2 "25t50" 3 "50t75" 4 "gt75")) ///
		title("Pr(WSI>0 | NWI quartile)") ///
		note("HRS Wave 5+, households where oldest member is 65+. Dashed lines = 2007, 2020.") ///
		name(pos_wsi, replace) 
		
graph export "$home/graphs/pos_wsi.png", replace 		

	
/* note that average age for each group is decreasing over this period. However the same graph with probability of positive earnings residualized by age still shows positive trend. */ 		
		

************** Draw percent change for income types over time 

clear
use $home/data/hrs_cleaned.dta,replace 

collapse (p90) p90_nw = hinw_idda (p50) p50_nw = hinw_idda (p10) p10_nw = hinw_idda ///
(p90) p90_tot = htot_idda (p50) p50_tot = htot_idda (p10) p10_tot = htot_idda ///
(p90) p90_earn = hiearn (p50) p50_earn = hiearn (p10) p10_earn = hiearn ///
[aw = rwthh], by(year) 		

foreach inc in nw tot earn {
	foreach i in p90 p50 p10 {
		summarize `i'_`inc' if year == 2000 
		gen `i'_`inc'_grwth = `i'_`inc' / `r(mean)'
	}
}

twoway connected  p90_tot_grwth p50_tot_grwth p10_tot_grwth year


twoway connected  p90_earn_grwth p50_earn_grwth p10_earn_grwth p90_nw_grwth p50_nw_grwth p10_nw_grwth year

* this is showing me that total income growth outpaces NW income growth in the HRS sample. Let's look at the same thing in IDDA. 


clear 
import delimited $home/data/pctl_of_inc_all_data.csv
keep if samp == "all_1040_mafid" & geo_var_val == 0
destring pctl95 pctl98 pctl99 pctl99_9 pctl99_99 pctl99_999, replace

* start by looking at full population
keep if group_var_val == "65plus"
* and keep similar period to HRS
keep if year >= 2000 

keep year level samp inc_var geo_var geo_var_val geo_abb group_var group_var_val  pctl25 pctl50 pctl90 pctl98

reshape wide pctl25 pctl50 pctl90 pctl98, i(year level samp geo_var geo_var_val geo_abb group_var group_var_val) j(inc_var) string

foreach inc in GI NW WS {
	foreach i in pctl90 pctl50 {
		summarize `i'`inc' if year == 2000 
		gen `i'`inc'_grwth = `i'`inc' / `r(mean)'
	}
}

twoway connected pctl90WS_grwth pctl50WS_grwth pctl90NW_grwth pctl50NW_grwth pctl90GI_grwth pctl50GI_grwth year

* In IDDA, in terms of growth since 2000, both WS and GI outpace NW.
* We wanted to show that since dispersion in AGI > dispersion in WSI that must imply that NWI is contributing to inequality. 

foreach inc in WS GI NW { 
	
	gen p98p50_`inc' = pctl98`inc'/pctl50`inc'
}

twoway connected  p98p50_WS p98p50_GI year

* Well. It looks like growth dispersion in WS actually outpaces that for GI. Hm. 
	* p90p50 larger for WSI than AGI (similar). p98p50 larger for AGI than WSI. 

** I think what Lisa was getting at was - 65+ AGI inequality is higher than 55-64 AGI inequality. If that's the case, then one of the reasons why is because more income is coming from fixed and unearned sources. 
	* Another way of saying this is - retirees are more unequal relative to each other than the working population? Why is that? Well, because their source of incomes are fixed. 
	* But I think another way of looking at it is, retirees are more unequal because their age distribution is more unequal than any one of the age groups that we've been comparing them to (EG 55-64). 
	* Is point 1 even true? 
	
clear 
import delimited $home/data/pctl_of_inc_all_data.csv
keep if samp == "all_1040_mafid" & geo_var_val == 0
destring pctl95 pctl98 pctl99 pctl99_9 pctl99_99 pctl99_999, replace

keep if inlist(group_var_val, "65plus", "All_sample_members") 
keep if inc_var == "GI"
keep year level samp inc_var geo_var geo_var_val geo_abb group_var group_var_val  pctl25 pctl50 pctl90 pctl98
reshape wide pctl25 pctl50 pctl90 pctl98, i(year level samp geo_var geo_var_val geo_abb group_var inc_var) j(group_var_val) string

foreach grp in All_sample_members 65plus { 
	
	gen p90p25_`grp' = pctl90`grp'/pctl25`grp'
}

twoway connected p90p25_65plus p90p25_All year if year != 2007

** Point 1 '65+ AGI inequality higher than 55-64 inequality' is true. But that doesn't eliminate the source of the difference from being different age variation in these two groups. To look at that directly. I'm going to go to HRS, and I'm going to compare 55-64 against 65-74. 

clear
use $home/data/hrs_cleaned.dta, replace 
keep if inlist(xaged,4,5) /*keep age groups 55-64, 65-74 */ 
collapse (p90) p90_tot = hitot (p25) p25_tot = hitot (p50) p50_tot = hitot [aw = rwthh], by(year xaged)

gen p90p25 = p90_tot/p25_tot

gen p90p50 = p90_tot/p50_tot  

twoway (connected p90p25 year if xaged == 4) (connected p90p50 year if xaged == 5), ///
legend(order (1 "55-64" 2 "65-74"))

** 55-64 p90p25 in total income for 55-64 is higher than p90p25 for 65-74. So it does appear as if higher income inequality within '65+' relative to households within '55-64' is caused by a wider age range in 65+. Once you restrict within 65+ to an age range of comparable size, you get 'less' income inequality than in the younger group. 





  



