***** fptnmover.do *****
/* Define programs for calculating PPV and sens by n_col */
capture: program drop fptnmover

program define fptnmover
syntax varlist(min=4 max=4 numeric) [if], [prefix(name) suffix(name)] Nmove(integer) PROPFP(real) PROPMAXfp(real)

/*** Define input vars
#a #b #c #d are, respectively, the numbers of true positives 
(diseased subjects with correct positive test results), false negatives 
(disease, but negative test), false positives (no disease, but positive 
test) and true negatives (no disease, negative test).

			| Gold-standard |
			| True	| False |
------------|-------|-------|
		Pos |  TP	|  FP	|
Test	----|-------|-------|
		Neg	|  FN	|  TN	|
------------|-------|-------|
	
Moves #nmove persons from right to left column:
	#nmove*#propfp are moved from FP (up to a limit of #propfpmax * FP)
	#nmove-(#nmove*#propfp) are moved from TN

*/


local tp = word("`varlist'", 1)
local fn = word("`varlist'", 2)
local fp = word("`varlist'", 3)
local tn = word("`varlist'", 4)

di "tp: `tp', fn: `fn', fp: `fp', tn: `tn'"

*** Check for errors
if inrange(`propfp', 0, 1)==0 | inrange(`propmaxfp', 0, 1)==0 {
    di as error "Invalid parameters. Proportions must be between 0 and 1" 
	exit 198
}

if mi("`prefix'") & mi("`suffix'") {
    di as error "Either prefix or suffix must be provided"
	exit
}

*** New var names
foreach var in label movefp movetn {
	local `var' = "`prefix'`var'`suffix'"
}
foreach var in tp fn fp tn {
	local new`var' = "`prefix'`var'`suffix'"
}

*** Calculate new values
* N to move from FP and TN
gen `movefp' = cond(`fp'*`propmaxfp'>(`nmove'*`propfp'), /// If #nmiss * #propfp < #propmaxfp % of #fp 
					`nmove'*`propfp', /// then take #nmiss * #propfp
					`fp'*`propmaxfp') // else take #propmaxfp * #fp
replace `movefp'=round(`movefp')

gen `movetn' = `nmove'-`movefp' // #nmove-movefp
assert `nmove'==(`movefp'+`movetn')

** Calc new counts
gen `newfp' = `fp'-`movefp'
gen `newtp' = `tp'+`movefp'

gen `newtn' = `tn'-`movetn'
gen `newfn' = `fn'+`movetn'
assert `tp'+`fn'+`fp'+`tn'==(`newtp'+`newfn'+`newfp'+`newtn') // Old total == new total

** Order
order `movefp' `movetn' `newtp' `newfp' `newfn' `newtn', last

** Label var
local text_perfp = `propfp'*100
local text_permaxfp = `propmaxfp'*100
gen `label' = "N=`nmove', `text_perfp'% from FP, max `text_permaxfp'%", before(`movefp')


end