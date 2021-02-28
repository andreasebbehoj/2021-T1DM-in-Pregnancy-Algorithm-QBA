***** 3_CalcCorrected.do *****
/*
Calculate new corrected values of TP, FP, FN, and TN by moving a number of patients from right to left column:
			| EPICOM cohort |
			| True	| False |
------------|-------|-------|
		Pos |  TP	|  FP	|
Algo	----|-------|-------|
		Neg	|  FN	|  TN	|
------------|-------|-------|

Assumptions:
Either 74 or 328 patients will be moved. 

Either 0%, 100% or best estimate" (76%) will be assumed to algo positive (moved from FP to TP). "Best estimate" is defined as average uncorrected PPV of all algorithms

The maximum number of FP that can be moved is limited to 76% of the uncorrected FP. Example: an algorithm have an uncorrected number of 100 FP. If moving 328 patients, a maximum of 76 are moved from FP to TP while the remaining 328-76 are moved from TN to FN.

*/

use OutputData/uncorrected.dta, clear 


*** Define algo positive values 
su algo_ppv
global ppv_ave = round(`r(mean)', 0.001)

global algoposprop = "0 $ppv_ave 1" // 0%, best estimate and 100% algo pos


*** Move N from FP and TN
foreach n in 74 328 { // Loop over N to move
	foreach proppos of global algoposprop { // Loop over algo-pos 
		di _col(5) "N=`n'" _col(15) "PropFP=`proppos'"
		local proptext = string(round(`proppos'*100, 1), "%4.0f")
		di "`proptext'"
		qui: fptnmover tp fn fp tn, ///
			nmove(`n') /// N to move
			propfp(`proppos') /// assumed algo-pos
			propmaxfp($ppv_ave) /// maximum prop FP that can be moved
			suffix("_`n'_`proptext'") 
	}
}

*** Calculate corrected PPV and completeness
* Reshape
reshape long label_ movefp_ movetn_ tp_ fp_ fn_ tn_, i(algonumber algoname) j(x) string

* Gen vars
gen move_n=real(substr(x, 1, strpos(x, "_")-1)), after(x)
gen move_per=real(substr(x, strpos(x, "_")+1, .)), after(move_n)

sort algoname move_n move_per
gen row=_n, before(algonumber)

* Calculate PPV and completeness
diagtcol tp_ fn_ fp_ tn_, prefix("corr_")


*** Save results
save OutputData/corrected.dta, replace
export delimited using OutputData/corrected.csv, replace delim(tab)