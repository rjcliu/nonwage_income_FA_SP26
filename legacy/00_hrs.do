clear
clear mata
clear matrix
global home "C:\Users\IRRJL01\Dropbox\personal\IDDA\nuggets\" 


set maxvar 100000
frames reset

use $home\data\randrs1992_2022_merged.dta


loc tot h1itot h2itot h3itot h4itot h5itot h6itot h7itot h8itot h9itot h10itot h11itot h12itot h13itot h14itot h15itot h16itot

loc ftot h10iftot h11iftot h12iftot h13iftot h14iftot h15iftot h16iftot h1iftot h2iftot2 h2iftot h3iftot h4iftot h5iftot h6iftot h7iftot h8iftot h9iftot

loc othr h1iothr h2iothr h3iothr h4iothr h5iothr h6iothr h7iothr h8iothr h9iothr h10iothr h11iothr h12iothr h13iothr h14iothr h15iothr h16iothr

loc earn r1iearn s1iearn r2iearn s2iearn r3iearn s3iearn r4iearn s4iearn r5iearn s5iearn r6iearn s6iearn r7iearn s7iearn r8iearn s8iearn r9iearn s9iearn r10iearn s10iearn r11iearn s11iearn r12iearn s12iearn r13iearn s13iearn r14iearn s14iearn r15iearn s15iearn r16iearn s16iearn

loc pena  r1ipena s1ipena r2ipena s2ipena r3ipena s3ipena r4ipena s4ipena r5ipena s5ipena r6ipena s6ipena r7ipena s7ipena r8ipena s8ipena r9ipena s9ipena r10ipena s10ipena r11ipena s11ipena r12ipena s12ipena r13ipena s13ipena r14ipena s14ipena r15ipena s15ipena r16ipena s16ipena

loc ssdi r1issdi s1issdi r2issdi s2issdi r3issdi s3issdi r4issdi s4issdi r5issdi s5issdi r6issdi s6issdi r7issdi s7issdi r8issdi s8issdi r9issdi s9issdi r10issdi s10issdi r11issdi s11issdi r12issdi s12issdi r13issdi s13issdi r14issdi s14issdi r15issdi s15issdi r16issdi s16issdi

loc ssret r1isret s1isret r2isret s2isret r3isret s3isret r4isret s4isret r5isret s5isret r6isret s6isret r7isret s7isret r8isret s8isret r9isret s9isret r10isret s10isret r11isret s11isret r12isret s12isret r13isret s13isret r14isret s14isret r15isret s15isret r16isret s16isret

loc wthh r1wthh r2wthh r3wthh r4wthh r5wthh r6wthh r7wthh r8wthh r9wthh r10wthh r11wthh r12wthh r13wthh r14wthh r15wthh r16wthh

loc unwc r10iunwc r11iunwc r12iunwc r13iunwc r14iunwc r15iunwc r16iunwc r1iunwc r2iunwc r3iunwc r4iunwc r5iunwc r6iunwc r7iunwc r8iunwc r9iunwc s10iunwc s11iunwc s12iunwc s13iunwc s14iunwc s15iunwc s16iunwc s1iunwc s2iunwc s3iunwc s4iunwc s5iunwc s6iunwc s7iunwc s8iunwc s9iunwc

loc gxfr r1igxfr s1igxfr r2igxfr s2igxfr r3igxfr s3igxfr r4igxfr s4igxfr r5igxfr s5igxfr r6igxfr s6igxfr r7igxfr s7igxfr r8igxfr s8igxfr r9igxfr s9igxfr r10igxfr s10igxfr r11igxfr s11igxfr r12igxfr s12igxfr r13igxfr s13igxfr r14igxfr s14igxfr r15igxfr s15igxfr r16igxfr s16igxfr

loc cap h1icap h2icap h3icap h4icap h5icap h6icap h7icap h8icap h9icap h10icap h11icap h12icap h13icap h14icap h15icap h16icap

loc ira  h10iirawy1 h11iirawy1 h12iirawy1 h13iirawy1 h14iirawy1 h15iirawy1 h16iirawy1 h2iirawy1 h5iirawy1 h6iirawy1 h7iirawy1 h8iirawy1 h9iirawy1

loc almny h1ialmny h2ialmny h3ialmny h4ialmny h5ialmny h6ialmny

loc sayret r1sayret r2sayret r3sayret r4sayret r5sayret r6sayret r7sayret r8sayret r9sayret r10sayret r11sayret r12sayret r13sayret r14sayret r15sayret r16sayret 

loc wealth h1atotb h2atotb h3atotb h4atotb h5atotb h6atotb h7atotb h8atotb h9atotb h10atotb h11atotb h12atotb h13atotb h14atotb h15atotb h16atotb

loc nhwealth h1atotn h2atotn h3atotn h4atotn h5atotn h6atotn h7atotn h8atotn h9atotn h10atotn h11atotn h12atotn h13atotn h14atotn h15atotn h16atotn

keep hhid hhidpn raracem rahispan ragender rabyear   `tot' `ftot' `othr' `earn' `pena' `ssdi' `ssret' `unwc' `gxfr' `cap' `ira' `wthh' `almny' `sayret' `wealth' `nhwealth'



* keep one respondent (oldest) per household
egen maxage = min(rabyear), by(hhid)
replace maxage = maxage == rabyear
keep if maxage == 1

* to transform wide to long, change naming format from [r/s/h][survey #][var] to [r/s/h][var][survey #] 
foreach resp in r s h { 
	loc y = 1992 
	forvalues i = 1(1) 16 { 
		
		ds *`resp'`i'i*
		loc vars `r(varlist)'
		foreach var in `vars' { 
			
			*disp "`var'"
			local newname : subinstr local var "`resp'`i'" "" 
			rename `var' `resp'`newname'`y'
			replace `resp'`newname'`y' = 0 if inlist(`resp'`newname'`y', .x, .u) 
				* replace valid missing with 0, particularly spousal variables
				
		}
	loc y = `y' +2	
	}
}


foreach var in atotb atotn { 
loc y = 1992
	forvalues i = 1(1) 16 { 
		rename h`i'`var' h`var'`y' 
		loc y = `y' +2	
		}
	}

foreach var in wthh sayret { 
loc y = 1992
	forvalues i = 1(1) 16 { 
		rename r`i'`var' r`var'`y' 
		loc y = `y' +2	
		}
	}
	
reshape long hitot hiftot hiothr riearn siearn ripena sipena ///
		rissdi sissdi risret sisret riunwc siunwc rigxfr sigxfr hicap ///
		hiirawy1 rwthh hialmny rsayret hatotb hatotn, ///
		i(hhidpn hhid ragender raracem rabyear) j(year)	

	
*gen some vars
	
gen hatoth = hatotb - hatotn /*non-housing wealth */
	
foreach i in pena ssdi sret unwc gxfr earn  { 
	gen hi`i' = ri`i' + si`i'
} /*household versions of income components */ 

gen age = year - rabyear
drop if year == 21994	
drop if age < 16

gen xaged = 0 if inrange(age, 16,24)
replace xaged = 1 if inrange(age, 25,34) 
replace xaged = 2 if inrange(age,35,44)
replace xaged = 3 if inrange(age, 45, 54) 
replace xaged = 4 if inrange(age, 55,64) 
replace xaged = 5 if inrange(age,65,74) 
replace xaged = 6 if inrange(age,75,84) 
replace xaged = 7 if inrange(age,85,94)
replace xaged = 8 if inrange(age,95,104) 
replace xaged = 9 if inrange(age,105,114) 

gen xagea = 0 if inrange(age, 16,24)
replace xagea = 1 if inrange(age, 25,34) 
replace xagea = 2 if inrange(age,35,44)
replace xagea = 3 if inrange(age, 45, 54) 
replace xagea = 4 if inrange(age, 55,64) 
replace xagea = 5 if inrange(age, 65, 114)

lab define xaged 0 "16t24" 1 "25t34" 2 "35t44" 3 "45t54" 4 "55t64" 5 "65t74" 6 "75t84" 7 "85t94" 8 "95t104" 9 "105t114"   
lab val xaged xaged

 lab define xagea 0 "16t24" 1 "25t34" 2 "35t44" 3 "45t54" 4 "55t64" 5 "65+"
 lab val xagea xagea

 
 gen xred = 0 if rarace == 1 & rahispan != 1 
 replace xred = 1 if rarace == 2 & rahispan != 1 
 replace xred = 2 if rahispan == 1 
 replace xred = 3 if rarace == 3 & rahispan != 1 
 
 lab define xred 0 "NH White" 1 "NH Black" 2 "Hispanic" 3 "NH Other"
lab val xred xred


frame create pce 
cwf pce 
freduse PCEPI 
gen year = year(daten)
collapse (mean) PCEPI, by(year)
quietly sum PCEPI if year == 2019 
loc reference = `r(mean)'
replace PCEPI = PCEPI/`reference'

cwf default
frlink m:1 year, frame(pce year) 
frget PCEPI, from(pce)
drop pce  

preserve
gen hitot_adj = hitot / PCEPI 
collapse (mean) hitot_adj (mean) rwthh (mean) age, by(hhidpn)

reg hitot_adj age [aw = rwthh]
predict hat_tot
gen resid_hitot_adj = hitot_adj - hat_tot
xtile PE = resid_hitot_adj [aw = rwthh], nq(5)
keep hhidpn PE
tempfile temp
save `temp' 
restore
merge m:1 hhidpn using `temp', nogen


/*PE is - the quartile of average total household income across the whole time in sample, residualized by mean age in sample */

preserve 
keep if inlist(age, 53,54)
xtile TC = hitot/PCEPI [aw = rwthh], nq(5)
keep hhidpn TC
tempfile temp
save `temp' 
restore
merge m:1 hhidpn using `temp', nogen

preserve
keep if rsayret == 1 
egen retage = min(age), by(hhidpn) 
collapse (mean) retage, by(hhidpn)
tempfile temp
save `temp' 
restore
merge m:1 hhidpn using `temp', nogen


	



