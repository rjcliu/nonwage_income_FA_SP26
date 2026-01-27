
use "C:\Users\IRRJL01\Dropbox\personal\IDDA\nuggets\data\cps_00041.dta", replace

rename hispan hispanic

* Race/ethnicity
gen xrea = ""
replace xrea = "NH White" if race == 100 & hispanic == 0 
replace xrea = "NH Black" if race == 200 & hispanic == 0 
replace xrea = "NH AIAN" if race == 300 & hispanic == 0
replace xrea = "NH Asian" if race == 651 & hispanic == 0 
replace xrea = "NH NHOPI" if race == 652 & hispanic == 0
replace xrea = "Hispanic" if hispanic == 1
replace xrea = "NH Other" if xrea == ""

tab race xrea if hispanic == 0, missing 
tab race xrea if hispanic == 1, missing 


gen xall = "All sample members"

* Geography
gen usst = 0
gen state = statefip

* Sex
gen xsex = ""
replace xsex = "Male" if sex == 1
replace xsex = "Female" if sex == 2
tab sex xsex, missing 


keep if incwage !=. 

sum incwage, detail
keep if incwage >= `r(p90)'

gen xrea_factor = 0 if xrea == "NH White"
replace xrea_factor = 1 if xrea == "NH Black" 
replace xrea_factor = 2 if xrea == "NH AIAN"
replace xrea_factor = 3 if xrea == "NH Asian"
replace xrea_factor = 4 if xrea == "NH NHOPI"
replace xrea_factor = 5 if xrea == "Hispanic"
replace xrea_factor = 6 if xrea == "NH Other"  

label define race 0 "White" 1 "Black" 2 "AIAN" 3 "Asian" 4 "NHOPI" 5 "Hispanic" 6 "Other"
label values xrea_factor race 

reg incwage i.xrea_factor 
