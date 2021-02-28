***** 4_Table.do *****
use OutputData/corrected.dta, clear


*** Summarize PPV and compleness by Nmove
* Add duplicates vars for collapse
rename corr_ppv corr_ppv_med
rename corr_sen corr_sen_med

foreach var in min max {
    gen corr_ppv_`var' = corr_ppv_med
	gen corr_sen_`var' = corr_sen_med
}

* Collapse 
collapse 	(max) algo_ppv algo_sen /// Uncorrected
			(p50) corr_ppv_med corr_sen_med /// best estimate % algo-pos
			(min) corr_ppv_min corr_sen_min /// 0% algo-pos
			(max) corr_ppv_max corr_sen_max /// 100% algo-pos 
			, by(algoname move_n)


*** Format for table 
global format = `"*100, 0.1), "%4.1f" "' // Percent with 1 digit
local varlist = ""

* Generate corrected column vars
levelsof move_n, local(nmove)
reshape wide corr_*, i(algoname) j(move_n)

foreach n of local nmove {
	foreach var in ppv sen {
		gen `var'_`n' = ///
			  string(round(corr_`var'_med`n' $format ) ///
			+ " (" ///
			+ string(round(corr_`var'_min`n' $format ) ///
			+ "-" ///
			+ string(round(corr_`var'_max`n' $format ) ///
			+ ")"
		local varlist = "`varlist' `var'_`n'"
	}
	
}

* Format uncorrected estimates
gen ppv_uncorrected = string(round(algo_ppv $format )
gen sen_uncorrected = string(round(algo_sen $format )

* Sort and algo name
gen sort = _n
decode algoname, gen(algorithm) 

* Save data
save OutputData/corrected_table.dta, replace
export delimited using OutputData/corrected_table.csv, replace delim(tab)


*** Export table as word doc
capture: frame drop table
frame put sort algorithm ppv_uncorrected sen_uncorrected `varlist', into(table)

frame table {
    ** Add column headers to table
	* Column header (PPV and compleness)
	qui: count
	local n = `r(N)'+1
	set obs `n'
	recode sort (.=0)
	
	* Column superheader (Nmove)
	local n = `n'+1
	set obs `n'
	recode sort (.=-1)

	sort sort

	* Rename 
	foreach var in uncorrected `nmove' {
		replace ppv_`var' = proper("`var'") if sort==-1
		replace ppv_`var' = "PPV, %" if sort==0
		replace sen_`var' = "Completeness, %" if sort==0
	}
	
	** Export to word
	putdocx clear
	putdocx begin, landscape
	putdocx paragraph
	putdocx text ("Table - Uncorrected and corrected PPV and completeness of algorithms with most likely estimates (and possible ranges).")
	putdocx table tbl1 = data(algorithm-sen_328)
	putdocx paragraph
	putdocx text ("Notes: Most likely estimate is based on the assumption that the average (uncorrected) PPV of algorithms for T1DM patients in the EPICOM cohort applies to T1DM patients not included the EPICOM study. Ranges refers to range from worst possible case (0% of non-EPICOM T1DM patients are algorithm positive) to best possible case (up to 100% of non-EPICOM T1DM patients are algorithm positive).")
	putdocx save OutputTables/TabCorrected, replace
}

frame drop table