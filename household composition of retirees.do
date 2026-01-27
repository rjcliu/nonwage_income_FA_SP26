**Code to chart household composition for retirees by race, using 2019 ACS

cap log close
clear frames
args geo samp y 

global home "C:\Users\IRRJL01\Dropbox\personal\IDDA\nuggets"
global raw  "$home\data" 
global do 	"$home\do"
global out "$home\graphs"


use "$raw/usa_00034", replace

*I. Demographic variables

* Hispanic ethnicity to code xrea
gen hispanic = 0 
replace hispanic = 1 if hispan > 0 
tab hispan hispanic, missing

**# **# Flagging for Natalie review: 
* 	ACS provide "raced", a more granular measure of race
* 	please confirm that selected code ranges make sense!
*	affected groups: Asian, AIAN, NHOPI
* Race/ethnicity

gen xrea = ""
replace xrea = "NH_White" if raced == 100 & hispanic == 0 
replace xrea = "NH_Black" if raced == 200 & hispanic == 0 
replace xrea = "NH_AIAN" if inrange(raced,300,399) & hispanic == 0
replace xrea = "NH_Asian" if (inrange(raced,400,620) | inrange(raced,640,679)) & hispanic == 0 
replace xrea = "NH_NHOPI" if (raced == 630 | inrange(raced,680,699)) & hispanic == 0
replace xrea = "Hispanic" if hispanic == 1
replace xrea = "NH_Other" if xrea == ""
tab race xrea if hispanic == 0, missing 
tab race xrea if hispanic == 1, missing 

gen xall = "All sample members"


gen retiree = age >= 65 
gen working = inrange(age,25,54)

by serial, sort: egen retirees = sum(retiree)
by serial, sort: egen workers = sum(working)


keep if retiree  
gen hhworker = workers > 0 

*graph hbox retirees workers, over(xrea)



encode xrea,gen(xrea_num)
reg hhworker ib7.xrea_num age, baselevels

collapse (mean) workers = hhworker (mean) retirees (semean) wse = hhworker ///
	(semean) rse = retirees [aw = perwt], by(xrea)
	
gen workersneg = -workers
sort workersneg 
gen num = _n 
	


 
*encode xrea, gen(num)

twoway (bar workers num if num == 1, barwidth(0.8)) || ///
		(bar workers num if num == 2, barwidth(0.8)) || ///
		(bar workers num if num == 3, barwidth(0.8) ) || ///
		(bar workers num if num == 4, barwidth(0.8)) || ///
		(bar workers num if num == 5, barwidth(0.8) ) || ///
		(bar workers num if num == 6, barwidth(0.8) ) || ///
		(bar workers num if num == 7, barwidth(0.8) ), ///
		legend(off) ///
		ylab(0(0.2)1) xlab(none) xtitle("")	 ///
		title("Proportion living with at least one working-aged indvl") ///
		subtitle("Given aged 65+") ///
		note("Source: 2019 ACS. Working-aged = Aged 25-54.") ///
		name(prb,replace) ///
		xlabel(1 "NHOPI" 2 "Asian" 3 "Hispanic" 4 "Black" 5 "Other" 6 "AIAN" 7 "White")
		
graph export "$out/prb.png", name(prb) replace

keep xrea workers

export delimited "$raw/hhcomp_retired.csv", replace

