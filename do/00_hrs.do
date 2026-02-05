global home "C:\Users\IRRJL01\Dropbox\personal\IDDA\nuggets" 

frames reset 
clear
clear mata
clear matrix

set maxvar 100000

**load in RAND HRS files 
* merge major variables in HRS 'hrs' to component variables 'hrsimp'
*use $home\data\randhrs1992_2022v1.dta 
*merge 1:1 hhidpn using $home\data\randhrsimp1992_2022v1.dta 
*save $home\data\randrs1992_2022_merged.dta

use $home\data\randrs1992_2022_merged.dta


* It's useful to have all income variables in a standard naming format for reshaping to long
* Here I combine savings and stock income components in wave 2 into 1  variable
egen h2isav = rowtotal(h2isav1  h2isav2) 
egen h2istk = rowtotal(h2istk1  h2istk2)

* other asset income is split into variables h[survey $]iothi[1/2/3/4]. Create a summed total.
forvalues i = 2(1)16 { 
	
	 ds h`i'iothi*
	 loc vars `r(varlist)'

	 egen h`i'iothi = rowtotal(`vars') if r`i'wthh != . 
	*gen h`i'iothi = h`i'iothi1
}
rename h1iothin h1iothi 


* set locals for varlists I want to keep. These are almost all income variables. 
loc tot h1itot h2itot h3itot h4itot h5itot h6itot h7itot h8itot h9itot h10itot h11itot h12itot h13itot h14itot h15itot h16itot
loc ftot h10iftot h11iftot h12iftot h13iftot h14iftot h15iftot h16iftot h1iftot h2iftot h3iftot h4iftot h5iftot h6iftot h7iftot h8iftot h9iftot
loc othr h1iothr h2iothr h3iothr h4iothr h5iothr h6iothr h7iothr h8iothr h9iothr h10iothr h11iothr h12iothr h13iothr h14iothr h15iothr h16iothr
loc earn r1iearn s1iearn r2iearn s2iearn r3iearn s3iearn r4iearn s4iearn r5iearn s5iearn r6iearn s6iearn r7iearn s7iearn r8iearn s8iearn r9iearn s9iearn r10iearn s10iearn r11iearn s11iearn r12iearn s12iearn r13iearn s13iearn r14iearn s14iearn r15iearn s15iearn r16iearn s16iearn
loc pena  r1ipena s1ipena r2ipena s2ipena r3ipena s3ipena r4ipena s4ipena r5ipena s5ipena r6ipena s6ipena r7ipena s7ipena r8ipena s8ipena r9ipena s9ipena r10ipena s10ipena r11ipena s11ipena r12ipena s12ipena r13ipena s13ipena r14ipena s14ipena r15ipena s15ipena r16ipena s16ipena
loc ssdi r1issdi s1issdi r2issdi s2issdi r3issdi s3issdi r4issdi s4issdi r5issdi s5issdi r6issdi s6issdi r7issdi s7issdi r8issdi s8issdi r9issdi s9issdi r10issdi s10issdi r11issdi s11issdi r12issdi s12issdi r13issdi s13issdi r14issdi s14issdi r15issdi s15issdi  r16issdi s16issdi
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
loc cap h1icap h2icap h3icap h4icap h5icap h6icap h7icap h8icap h9icap h10icap h11icap h12icap h13icap h14icap h15icap h16icap
loc busin h1ibusin h2ibusin h3ibusin h4ibusin h5ibusin h6ibusin h7ibusin h8ibusin h9ibusin h10ibusin h11ibusin h12ibusin h13ibusin h14ibusin h15ibusin h16ibusin
loc rntn h1irntin h2irntin h3irntin h4irntin h5irntin h6irntin h7irntin h8irntin h9irntin h10irntin h11irntin h12irntin h13irntin h14irntin h15irntin h16irntin
loc trst h1itrsin h2itrsin h3itrsin h4itrsin h5itrsin h6itrsin
loc dividend h1idivin h2idivin h3idivin h4idivin h5idivin h6idivin h7idivin h8idivin h9idivin h10idivin h11idivin h12idivin h13idivin h14idivin h15idivin h16idivin
loc bndin h3ibndin h4ibndin h5ibndin h6ibndin h7ibndin h8ibndin h9ibndin h10ibndin h11ibndin h12ibndin h13ibndin h14ibndin h15ibndin h16ibndin
loc stk h2istk
loc chkin h3ichkin h4ichkin h5ichkin h6ichkin h7ichkin h8ichkin h9ichkin h10ichkin h11ichkin h12ichkin h13ichkin h14ichkin h15ichkin h16ichkin
loc sav h2isav
loc cdin h3icdin h4icdin h5icdin h6icdin h7icdin h8icdin h9icdin h10icdin h11icdin h12icdin h13icdin h14icdin h15icdin h16icdin
loc isemp r3isemp s3isemp r4isemp s4isemp r5isemp s5isemp r6isemp s6isemp r7isemp s7isemp r8isemp s8isemp r9isemp s9isemp r10isemp s10isemp r11isemp s11isemp r12isemp s12isemp r13isemp s13isemp r14isemp s14isemp r15isemp s15isemp r16isemp s16isemp
loc iunem r1iunem s1iunem r2iunem s2iunem r3iunem s3iunem r4iunem s4iunem r5iunem s5iunem r6iunem s6iunem r7iunem s7iunem r8iunem s8iunem r9iunem s9iunem r10iunem s10iunem r11iunem s11iunem r12iunem s12iunem r13iunem s13iunem r14iunem s14iunem r15iunem s15iunem r16iunem s16iunem
loc othi h1iothi h2iothi h3iothi h4iothi h5iothi h6iothi h7iothi h8iothi h9iothi h10iothi h11iothi h12iothi h13iothi h14iothi h15iothi h16iothi
loc wthh r1wthh r2wthh r3wthh r4wthh r5wthh r6wthh r7wthh r8wthh r9wthh r10wthh r11wthh r12wthh r13wthh r14wthh r15wthh r16wthh
loc sdi  s9isdi s8isdi s7isdi s6isdi s5isdi s4isdi s3isdi s2isdi s1isdi s16isdi s15isdi s14isdi s13isdi s12isdi s11isdi s10isdi r9isdi r8isdi r7isdi r6isdi r5isdi r4isdi r3isdi r2isdi r1isdi r16isdi r15isdi r14isdi r13isdi r12isdi r11isdi r10isdi

keep hhid hhidp raracem rahispan ragender rabyear   `cap' `busin' `rntn' `trst' `dividend' `bndin' `stk' `chkin' `sav' `cdin' `isemp' `wthh' `othi' `iunem' `tot' `ftot' `othr' `earn' `pena' `ssdi' `ssret' `unwc' `gxfr' `cap' `ira' `wthh' `almny' `sayret' `wealth' `nhwealth' `sdi'

* keep one respondent (oldest) per household
* that individual will be considered the head, and we will take demographics (race/age/retirement) from that respondent 
egen maxage = min(rabyear), by(hhid)
replace maxage = maxage == rabyear
keep if maxage == 1
drop maxage

* to transform wide to long, change naming format from [r/s/h][survey wave #][var] to [r/s/h][var][survey year] 
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

/*rename wealth, weights, and retirement status variables to reshape wide to long*/ 
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

	* reshape long
reshape long hitot hiftot hiothr riearn siearn ripena sipena ///
		rissdi sissdi risret sisret riunwc siunwc rigxfr sigxfr hicap ///
		hiirawy1 rwthh hialmny rsayret hatotb hatotn hibusin ///
		hirntin hidivin hiothi hisav histk hitrsin risemp sisemp hibndin ///
		hichkin hicdin riunem siunem risdi sisdi, i(hhidpn ragender raracem rabyear) j(year)
		
*I am left with households where the age of head is <51. 
*	According to HRS documentation these shouldn't exist. Drop observations where age is too young . 		
gen age = year - rabyear
codebook hhid if age <51
drop if age < 51 

 * data from 1992 is biased since all households with household head above age 61  all have spouses in the HRS cohort (born 1931-41, so aged 51-60) which skews up their positive WSI. I will drop these individuals because they bias the results strongly  
 * https://hrs.isr.umich.edu/documentation/survey-design see 'longitudinal cohort sample design' for details
drop if year == 1992 & rabyear < 1931

* Similarly between 94 + 96, all households with oldest member born between 1924-1930 have spouses in the HRS cohort (aged 53-62/55-64), which skews up positive WSI. 
drop if inrange(year,1994,1996) & inrange(rabyear,1924,1930) 


*************************** Gen variables

* calculate total housing wealth from [total wealth] - [total non-housing wealth]
gen hatoth = hatotb - hatotn 

* generate household level income variables from summing respondent/spouse components
foreach i in pena ssdi sret unwc gxfr earn  semp unem sdi { 
	gen hi`i' = ri`i' + si`i'
}

*gen categorical variables for age, race/ethnicity 

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
replace xagea = 5 if inrange(age, 65, 74)
replace xagea = 6 if inrange(age, 75, 114)

lab define xaged 0 "16-24" 1 "25-34" 2 "35-44" 3 "45-54" 4 "55-64" 5 "65-74" 6 "75-84" 7 "85-94" 8 "95-104" 9 "105-114"   
lab val xaged xaged

lab define xagea 0 "16-24" 1 "25-34" 2 "35-44" 3 "45-54" 4 "55-64" 5 "65-74" 6 "75+"
lab val xagea xagea

gen xred = 0 if rarace == 1 & rahispan != 1 
replace xred = 1 if rarace == 2 & rahispan != 1 
replace xred = 2 if rahispan == 1 
replace xred = 3 if rarace == 3 & rahispan != 1 
 
lab define xred 0 "White" 1 "Black" 2 "Hispanic" 3 "Other"
lab val xred xred


* calculate an 'IDDA nonwage' equivalent using HRS components
* some components - trust, savings, and stock income are discontinued in later surveys. We impute these discontinued contents to 0, consistent with HRS practice of reporting a consistently named capital income measure without the discontinued components. 
foreach i in hisav histk {
	replace `i' = 0 if year != 1994 & rwthh !=. /*unavailable outside of wave 2 */ 
}

replace hitrsin = 0 if year > 2002 & rwthh != . /*discontinued past wave 6 */

*Other components only began to be reported after 1996 (bond, cd, checking, self-employment). I will impute these to 0 when missing. For my analysis these imputations only affect hinw_idda_noira. In my analysis, I always use hinw_idda, which is calculated on 2000+ obs and these imputations shouldn't affect it. 

gen hint = hisav if year == 1994 
replace hint = hibndin + hicdin + hichkin if year >= 1996 /*savings accounts, bonds, cds, checking, */
replace hint = 0 if year == 1992 /*covered in dividends and other in 1992 */
replace hisemp = 0 if year < 1996 & hisemp == . /* covered by business income */ 


gen hinw_idda_noira = hidivin + hibusin + hirntin + hipena + hisret + hiunem + hisemp + hint + hisdi + hiothr + hitrsin + histk  + hiothi/* dividends, business, rental, pensions + annuities, socsec, DI, UI, self-employment, interest, misc. asset income, misc. nonasset non-wage income, + trust interest. Impute to 0 if missing. Only missing values now should be individuals in 1994 and 1996 who, due to skip patterns/different survey design, did not report all components and were not imputed by HRS*/
*tab year if hinw_idda_noira == . & rwthh != .
gen hinw_idda = hidivin + hibusin + hirntin + hipena + hisret + hiunem + hisemp + hint + hisdi + hiothr + hitrsin + histk  + hiothi +hiirawy1 /* dividends, business, rental, pensions + annuities, socsec, DI, UI, self-employment, interest, misc. asset income, misc. nonasset non-wage income, + trust interest + annual IRA disbursement. Missing values should be pre 2000 individuals (no hiirawy1 values) */
tab year if hinw_idda == . & rwthh != .

gen htot_idda = hinw_idda + hiearn

*aggregate income components for easier visualization in the data dive
gen capital = hidivin + hirntin + hint + hiothi + hitrsin + histk 
gen transfer = hisdi + hiunem
gen pension = hipena + hiirawy1 
gen earned = hibusin + hisemp
gen socsec = hisret
gen othr = hiothr




/*gen 'lifetime' income bins */
* Useful way of categorizing individuals. Two options - one is PE, which is  quintile of average total household income over the period we observe in the sample, adjusted for age.
* The other is TC, quintile of household income at age 53/54. 

*To calculate PE I need to inflation adjust incomes so that I can calculate the average income over the sample period using a standard unit. 
*get PCE for inflation adjustment 
frame create pce 
cwf pce 
freduse PCEPI 
gen year = year(daten)
collapse (mean) PCEPI, by(year)
quietly sum PCEPI if year == 2022 
loc reference = `r(mean)'
replace PCEPI = PCEPI/`reference'
cwf default
frlink m:1 year, frame(pce year) 
frget PCEPI, from(pce)
drop pce  

*calculate PE, weight regression and quintiles  
preserve
gen hitot_adj = hitot / PCEPI 
collapse (mean) hitot_adj (mean) rwthh (mean) age, by(hhidpn)
reg hitot_adj age [aw = rwthh]
predict hat_tot
gen resid_hitot_adj = hitot_adj - hat_tot
xtile PE = resid_hitot_adj [aw = rwthh], nq(4)
keep hhidpn PE
tempfile temp
save `temp' 
restore
merge m:1 hhidpn using `temp', nogen

*calculate TC, weight quintiles 
preserve 
keep if inlist(age, 53,54)
xtile TC = hitot/PCEPI [aw = rwthh], nq(3) 
keep hhidpn TC
tempfile temp
save `temp' 
restore
merge m:1 hhidpn using `temp', nogen



**calculate retirement age =  earliest year in which reported fully retired, or if they always report retired through the survey, in which case we use survey entry year as a proxy. 
preserve
keep if rsayret == 1 
egen retage = min(age), by(hhidpn) 
collapse (mean) retage, by(hhidpn)
tempfile temp
save `temp' 
restore
merge m:1 hhidpn using `temp', nogen


* gen indicator for positive earnings
gen pos_wsi = .
replace pos_wsi = 1 if hiearn > 0 & hiearn != .  
replace pos_wsi = 0 if hiearn == 0 


* gen generation indicator
gen generation = . 
replace generation = 0 if rabyear < 1924 
replace generation = 1 if inrange(rabyear,1924,1930) 
replace generation = 2 if inrange(rabyear,1931,1941) 
replace generation = 3 if inrange(rabyear,1942,1947) 
replace generation = 4 if inrange(rabyear,1948,1953)
replace generation = 5 if inrange(rabyear,1954,1959)
replace generation = 6 if inrange(rabyear,1960,1965) 
replace generation = 7 if inrange(rabyear,1966,1971)

lab define generation 0 "AHEAD" 1 "CODA" 2 "HRS" 3 "WB" 4 "EBB" 5 "MBB" 6 "LBB" 7 "EGENX" 
lab val generation generation
 
 
gen gena = . 
replace gena = 0 if rabyear < 1928 
replace gena = 1 if inrange(rabyear,1928,1945) 
replace gena = 2 if inrange(rabyear,1946,1964) 
replace gena = 3 if inrange(rabyear,1965,1980) 

lab define gena 0 "Greatest generation" 1 "Silent generation" 2 "Baby boomers" 3 "Gen X"




save $home/data/hrs_cleaned.dta, replace 