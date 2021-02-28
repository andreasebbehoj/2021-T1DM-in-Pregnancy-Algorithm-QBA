***** 4_Graph.do *****

*** Graph settings
** General
set scheme s2color
grstyle init graphlayout, replace
grstyle set plain // No plot region color, white background + other tweaks

** Size
grstyle set graphsize 560pt 560pt // in pixels, default is 5.5 inches *72 pt/inch = 396pt
grstyle set symbolsize medium
grstyle set size 25pt: axis_title // X and Y axis text size

** Axis
grstyle anglestyle vertical_tick horizontal // Horizontal "tick"text on y-axis
grstyle color major_grid gs11 // colour of horizontal lines

** Legend
grstyle set legend ///
	10, /// clock position of legend (1-12).
	nobox /// no legend background
	inside // inside plotregion

** Settings for each subgraph
local layout1 = "msymbol(O)"
local layout2 = "msymbol(D)"
local layout3 = "msymbol(T)"


*** Make graphs
use OutputData/corrected, clear
qui: levelsof algonumber, local(algonumbers)
qui: levelsof algoname, local(algonames)
qui: levelsof move_n, local(subcats)

gen labshort = string(move_per) + "%"

foreach algoname of local algonames { // Loop over subalgorithms
	** Data for subalgo graph
	qui: su row if algoname==`algoname'
	local title : label algoname `algoname'
	local subtitle = algo_text[`r(min)']
	local sens = algo_sen[`r(min)'] // uncorrected value
	local ppv = algo_ppv[`r(min)'] // uncorrected value
	di "`title' - `subtitle'"
	
	** Graph by N moved 
	local twoway = ""
	local label = ""
	local x = 1
	foreach n of local subcats {
		local twoway = "`twoway' (scatter corr_ppv corr_sen if algoname==`algoname' & move_n==`n'" ///
		+ ", mcolor() mlabel(labshort) mlabsize(small) `layout`x'')"
		local label = `" `x' "N=`n' moved" `label' "'
		
		local x =`x'+1
	}
	
	** Graph
	twoway `twoway' ///
		(scatteri `ppv' `sens', `layout`x'') /// PPV and sens without correction
		, xlabel(0.5(0.1)1.0) ylabel(0.6(0.1)1.0) ytick(0.6(0.1)1.0) ///
		title("Algorithm `title'") ///
		subtitle("`subtitle'", size(1.5)) ///
		xtitle("Completeness in %") ytitle("PPV in %") ///
		legend(ring(0) position(10) order(`label' 3 "Uncorrected") ) ///
		name("algo_`algoname'", replace)
	qui: graph export OutputFigures/algo_`algoname'.png, replace
}

** Combine figures
qui: levelsof algonumber, local(algonumbers)
foreach algonumber of local algonumbers {
	local combine = ""
	levelsof algoname if algonumber==`algonumber', local(algonames)
	foreach algoname of local algonames {
		local combine = "`combine' algo_`algoname'"
	}
	di "`combine'"
	graph combine `combine', altshrink name(comb_`algonumber', replace) col(2) ysize(297mm) xsize(210mm)
	graph export OutputFigures/comb_`algonumber'.png, replace
}