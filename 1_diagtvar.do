***** diagtcol.do *****
/* Define programs for calculating PPV and sensitivity by n_col */
capture: program drop diagtcol

program define diagtcol 
syntax varlist(min=4 max=4 numeric) [if], [prefix(name) suffix(name)] 


/*** Define input vars
#a #b #c #d are, respectively, the numbers of true positives 
(diseased subjects with correct positive test results), false negatives 
(disease, but negative test), false positives (no disease, but positive 
test) and true negatives (no disease, negative test).
*/

local tp = word("`varlist'", 1)
local fn = word("`varlist'", 2)
local fp = word("`varlist'", 3)
local tn = word("`varlist'", 4)

di "tp: `tp', fn: `fn', fp: `fp', tn: `tn'"

*** Check for errors
if mi("`prefix'") & mi("`suffix'") {
    di as error "Either prefix or suffix must be provided"
	exit
}


*** New var names
local newppv = "`prefix'ppv`suffix'"
local newsen = "`prefix'sen`suffix'"

*** Calculations
** PPV
gen `newppv' = `tp'/(`tp'+`fp') `if'

** Sensitivity
gen `newsen' = `tp'/(`tp'+`fn') `if'

end