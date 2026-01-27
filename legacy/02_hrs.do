*Draw stacked area charts to examine NW income components
* Current bug with trying to calculate NWI + IRA shares by age. 

*Limited to oldest member of household, and used TC instead of PE. Qualitatively similar results. 

loc inc TC

global home "C:\Users\IRRJL01\Dropbox\personal\IDDA\nuggets\" 

frames reset 

include $home\do\00_hrs.do
tempfile temp 
save `temp' 

clear
include $home\do\00_hrs_cap.do 
merge 1:1 hhidpn year using `temp', keep(3)



egen hint = rowtotal(hisav hibndin hicdin hichkin ) /*savings accounts, bonds, cds, checking, */
egen hicap_con = rowtotal(hibusin hirntin hisemp hint histk hiothi hidivin )
egen hidda_nw = rowtotal(hidivin hibusin hirntin hipena hisret hiunwc hisemp hint hiothr hiothi hiirawy1) /* dividends, business, rental, pensions + annuities, socsec, UI + wc, self-employment, interest, misc. asset income, misc. nonasset + nonwage income, + annual IRA disbursement */ /*excluding trust */ 



foreach i in hitot hinw hicap_con hidda_nw hiearn {
	gen `i'_adj = `i'/PCEPI
	loc adj_incs `adj_incs' `i'_adj
}


*preserve

preserve
collapse (mean) hitot `adj_incs' hiearn riearn siearn ///
hinw hicap hipena hissdi hisret hiunwc higxfr hiothr age hiirawy1 ///
hint hidivin hibusin hirntin hisemp hitrsin histk hiothi hidda_nw ///
[aw = rwthh], by(`inc' xaged)



keep if year >= 2000 /*using wave 5+ because that includes IRA*/ 

foreach i in cap pena ssdi sret unwc gxfr othr irawy1 { 
	
	gen prop_`i' = hi`i'/hinw
}

restore

preserve
collapse (mean) hitot `adj_incs' hiearn riearn siearn ///
hinw hicap hipena hissdi hisret hiunwc higxfr hiothr age hiirawy1 ///
hint hidivin hibusin hirntin hisemp hitrsin histk hiothi hidda_nw ///
[aw = rwthh], by(`inc' xaged)

forvalues i = 1(1) 5 {
	twoway connected hinw_adj xaged if `inc' == `i' & inrange(xaged,3,7), ///
	xlabel(,val) name(nw_connect_`inc'`i',replace) title("mean total real nw income, `inc' == `i'") ///
	note("Source: HRS wave 5+. Age of oldest household member. 2019 dollars")
	
	graph export $home\graphs\nw_connect_`inc'`i'.png, name(nw_connect_`inc'`i')
}

forvalues i = 1(1) 5 {
	twoway connected hicap_con_adj xaged if `inc' == `i' & inrange(xaged,3,7), ///
	xlabel(,val) name(cap_connect_`inc'`i',replace) title("mean total real capital income, `inc' == `i'") ///
	note("Source: HRS wave 5+. Age of oldest household member. 2019 dollars")
	
	graph export $home\graphs\cap_connect_`inc'`i'.png, name(cap_connect_`inc'`i')
}

restore 

preserve
collapse (mean) prop_* [aw = rwthh], by(`inc' xaged)

keep xaged `inc' prop_*

reshape long prop_, i(xaged `inc') j(inc) string

sort xaged `inc' inc

bysort xaged `inc' (inc): gen cum_prop = sum(prop_)

gen prop_low = cum_prop - prop_


forvalues i = 1(1)5 {
twoway ///
    (rarea prop_low cum_prop xaged if inc=="cap" , color(stc1)) ///
    (rarea prop_low cum_prop xaged if inc=="gxfr", color(stc2)) ///
	(rarea prop_low cum_prop xaged if inc=="irawy1", color(stc8)) ///
    (rarea prop_low cum_prop xaged if inc=="othr", color(stc3)) ///
	(rarea prop_low cum_prop xaged if inc=="pena", color(stc4)) ///
	(rarea prop_low cum_prop xaged if inc=="sret", color(stc5)) ///
	(rarea prop_low cum_prop xaged if inc=="ssdi", color(stc6)) ///
	(rarea prop_low cum_prop xaged if inc=="unwc", color(stc7)) ///
	if `inc' == `i' & inrange(xaged,3,7), /// 
    ytitle("share of nonwage income. `inc' = `i'") xtitle("age") ///
	legend(order (1 "capital" 2 "oth. xfer" 3 "ira" 4 "other" 5 "pension" 6 "socsec" 7 "ssdi" 8 "UI/comp")) ///
	name(nw_shares_`inc'`i', replace) title("Shares of nonwage income. `inc' = `i'") ///
	note("Source: HRS households wave 5+. Age by oldest member.") xlabel(,val)
	
	graph export $home\graphs\nw_shares_`inc'`i'.png, name(nw_shares_`inc'`i')
}	


*Capital income breakdown 
	* consistent components from wave 3 onwards - interest, other, self employment, rental, business, dividends, excluding trust and royalties.
	* sum of iothiX across all x in X != component of iothi in icap. Creating cap con to fix.

restore
preserve



keep if year >= 2000

collapse (mean) hitot hicap_con hiearn riearn siearn ///
hinw hicap hipena hissdi hisret hiunwc higxfr hiothr age hiirawy1 ///
hint hidivin hibusin hirntin hisemp hitrsin histk hiothi hidda_nw ///
[aw = rwthh], by(`inc' xaged)


foreach i in busin rntin semp nt othi divin { 
	
	gen prop_`i' = hi`i'/hicap_con
	
}

keep xaged `inc' prop_*

reshape long prop_, i(xaged `inc') j(inc) string
sort xaged `inc' inc
bysort xaged `inc' (inc): gen cum_prop = sum(prop_)
gen prop_low = cum_prop - prop_

forvalues i = 1(1)5 {
twoway ///
    (rarea prop_low cum_prop xaged if inc=="divin" , color(stc1)) ///
    (rarea prop_low cum_prop xaged if inc=="busin", color(stc2)) ///
    (rarea prop_low cum_prop xaged if inc=="rntin", color(stc3)) ///
	(rarea prop_low cum_prop xaged if inc=="semp", color(stc4)) ///
	(rarea prop_low cum_prop xaged if inc=="nt", color(stc5)) ///
	(rarea prop_low cum_prop xaged if inc=="othi", color(stc6)) ///
	if `inc' == `i' & inrange(xaged,3,7), /// 
    ytitle("share of nonwage income") xtitle("age") ///
	legend(order (1 "dividend" 2 "business" 3 "rental" 4 "self-emp" 5 "interest" 6 "other cap")) ///
	name(cap_shares_`inc'`i', replace) title("Shares of capital income. `inc' = `i'") ///
	note("Source: HRS wave 5+ households. Age from oldest member of household. Trust + royalties excluded.") xlabel(,val)
	
	graph export $home\graphs\cap_shares_`inc'`i'.png, name(cap_shares_`inc'`i')
	
}	


/*
*IDDA nonwage breakdown

/* dividends, business, rental, pensions + annuities, socsec, UI + wc, self-employment, interest, misc. asset income, misc. nonasset + nonwage income, + annual IRA disbursement */ /*excluding trust */ 

restore


preserve 

keep if year >= 2000 /*using wave 5+ because that includes IRA*/ 

collapse (mean) hitot hiearn riearn siearn ///
hinw hicap hipena hissdi hisret hiunwc higxfr hiothr age hiirawy1 ///
hint hidivin hibusin hirntin hisemp hitrsin histk hiothi hidda_nw ///
[aw = rwthh], by(`inc' xaged)



foreach i in divin busin rntin pena sret unwc semp nt othr othi irawy1 {
	
	gen prop_`i' = hi`i'/hidda_nw
}




keep xaged `inc' prop_*

reshape long prop_, i(xaged `inc') j(inc) string
sort xaged `inc' inc
bysort xaged `inc' (inc): gen cum_prop = sum(prop_)
gen prop_low = cum_prop - prop_

forvalues i = 1(1)5 {
twoway ///
    (rarea prop_low cum_prop xaged if inc=="divin" , color(stc1)) ///
    (rarea prop_low cum_prop xaged if inc=="busin", color(stc2)) ///
    (rarea prop_low cum_prop xaged if inc=="rntin", color(stc3)) ///
	(rarea prop_low cum_prop xaged if inc=="pena", color(stc4)) ///
	(rarea prop_low cum_prop xaged if inc=="sret", color(stc5)) ///
	(rarea prop_low cum_prop xaged if inc=="unwc", color(stc6)) ///
	(rarea prop_low cum_prop xaged if inc=="semp", color(stc7)) ///
	(rarea prop_low cum_prop xaged if inc=="nt", color(stc8)) ///
	(rarea prop_low cum_prop xaged if inc=="othr", color(stc9)) ///
	(rarea prop_low cum_prop xaged if inc=="othi", color(stc10)) ///
	(rarea prop_low cum_prop xaged if inc=="irawy1", color(stc11)) ///	
	if `inc' == `i' & inrange(xaged,3,7), /// 
    ytitle("share of taxable nonwage income") xtitle("age") ///
	legend(order (1 "dividend" 2 "business" 3 "rental" 4 "pension" 5 "socsec" 6 "UI/comp" 7 "self-emp." 8 "interest" 9 "othr" 10 "other cap" 11 "IRA")) ///
	name(idda_nw_`inc'`i', replace) title("Shares of taxable nonwage income. PE = `i'") ///
	note("Source: HRS Wave 5+ households. Age is taken from oldest member in household. ") xlabel(,val)
	
}	
