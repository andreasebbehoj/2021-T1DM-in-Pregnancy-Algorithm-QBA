***** 2_Import.do *****
/* 
Import number of TP, FP, FN, and TN for each algorithm and calculate uncorrected PPV and completeness
*/

import excel "InputData/tab2data.xlsx", sheet("Sheet1") firstrow clear

** Var names
ds
foreach var in `r(varlist)' {
	local lab = `var'[1]
	label var `var' "`lab'"
}
drop if _n==1

** Format 
foreach var in tp fp fn tn {
	destring `var', replace
}

** Algo labels
replace algo_text = substr(algo_text, strpos(algo_text, ". ")+2, .)

gen algoname = _n, before(algo)
labmask algoname, values(algo)

gen algonumber = real(substr(algo, 1, 1)), before(algoname)


*** Calculate uncorrected PPV and sens
egen total = rowtotal(tp fp fn tn)
diagtcol tp fn fp tn, prefix("algo_")


*** Save
save OutputData/uncorrected.dta, replace
export delimited using OutputData/uncorrected.csv, replace delim(tab)