*load in HRS detailed imputations file to get income components, trim and reshape long.

clear
clear mata
clear matrix
global home "C:\Users\IRRJL01\Dropbox\personal\IDDA\nuggets\" 

set maxvar 100000

use $home\data\randrs1992_2022_merged.dta


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

gen h2isav = h2isav1 + h2isav2 
gen h2istk = h2istk1 + h2istk2


* other asset income is split into variables h[survey $]iothi[1/2/3/4]. Create a summed total.
forvalues i = 2(1)16 { 
	
	 ds h`i'iothi*
	 loc vars `r(varlist)'

	 egen h`i'iothi = rowtotal(`vars')
	*gen h`i'iothi = h`i'iothi1
}
rename h1iothin h1iothi 
* rename to align with other variables 


keep hhidpn raracem ragender rabyear   `cap' `busin' `rntn' `trst' `dividend' `bndin' `stk' `chkin' `sav' `cdin' `isemp' `wthh' `othi' `iunem'


foreach resp in r s { 
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

loc y = 1992 
forvalues i = 1(1) 16 { 
		
	ds *h`i'i*
	loc vars `r(varlist)'
	foreach var in `vars' { 
		*disp "`var'"
		local newname : subinstr local var "h`i'" "" 
		rename `var' h`newname'`y'
		replace h`newname'`y' = 0 if inlist(h`newname'`y', .x, .u) 
				* replace valid missing with 0, particularly spousal variables
				
		}
	loc y = `y' +2	
	}

	
loc y = 1992
forvalues i = 1(1) 16 { 
	
	rename r`i'wthh rwthh`y' 
	loc y = `y' +2
}

reshape long  rwthh hicap hibusin hirntin hidivin hiothi hisav histk hitrsin risemp sisemp hibndin hichkin hicdin riunem siunem,i(hhidpn ragender raracem rabyear) j(year)

replace hiothi = . if rwthh == .

gen hisemp = risemp + sisemp if rwthh != . 

gen hiunem = riunem + siunem
