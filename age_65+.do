**Code to chart age distribution by race for individuals above 65+, using 2019 ACS

cap log close
clear frames
args geo samp y 

global home "C:\Users\IRRJL01\Dropbox\personal\IDDA\nuggets"
global raw  "$home\data" 
global do 	"$home\do"


use "$raw/usa_00034", replace

* Drop age < 16 (only universal sample selection)
drop if age < 16

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
replace xrea = "NH White" if raced == 100 & hispanic == 0 
replace xrea = "NH Black" if raced == 200 & hispanic == 0 
replace xrea = "NH AIAN" if inrange(raced,300,399) & hispanic == 0
replace xrea = "NH Asian" if (inrange(raced,400,620) | inrange(raced,640,679)) & hispanic == 0 
replace xrea = "NH NHOPI" if (raced == 630 | inrange(raced,680,699)) & hispanic == 0
replace xrea = "Hispanic" if hispanic == 1
replace xrea = "NH Other" if xrea == ""
tab race xrea if hispanic == 0, missing 
tab race xrea if hispanic == 1, missing 

gen xall = "All sample members"



keep if age >= 65 

*hist age [fweight = perwt], by(xrea)

graph hbox age [fweight = perwt], over(xrea) name(agedist,replace) ///
	note("Source: 2019 ACS, IPUMS") title("Age distribution by race/ethnicity, 65+")

graph export "$out/agedist.png", name(agedist) replace

