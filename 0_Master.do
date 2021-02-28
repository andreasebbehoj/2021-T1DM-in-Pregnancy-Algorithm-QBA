***** 0_Master.do *****
log using "log", replace

*** Setup 
* General settings
version 16.1
clear

/* Install dependencies
ssc install grstyle, replace
ssc install palettes, replace
ssc install colrspace, replace
*/

* Define programs
do 1_diagtvar.do
do 1_fptnmover.do


*** Import uncorrected values
do 2_Import.do


*** Calculate corrected values
do 3_CalcCorrected.do


*** Present results
do 4_Graph.do
do 4_Table.do


log close