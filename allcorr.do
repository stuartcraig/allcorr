 
// Select base directory and create a folder to hold all of the figures
cd ~/Dropbox/codesnippets
cap mkdir allcorr
cd allcorr


sysuse auto, clear

qui summ price
qui gen std_lhs = (price - r(mean))/r(sd)

qui ds
foreach v in `r(varlist)' {
	// Skip the LHS variable or any strings
	if inlist("`v'","price","std_lhs") continue
	cap confirm numeric var `v'
	if _rc!=0 continue
	
	// Standardize the RHS and generate the correlation coefficient
	cap drop std_rhs
	qui summ `v'
	qui gen std_rhs=(`v' - r(mean))/r(sd)
	qui reg std_lhs std_rhs
	
	// Clean up the regression coefficient
	loc rho = _b[std_rhs]	
	loc neg ""
	if `rho'<0 loc neg "neg" 	// can comment out this line if you 
								// just want to sort by abs(rho)
	loc r = subinstr(string(abs(`rho')),".","",.)
	loc r = substr("`r'",1,3)
	
	// Create a figure and save for easy sorting
	tw 	scatter price `v', ms(O) || ///
		lfit price `v', legend(off) lw(medthick) ytitle("Price")
	graph export Allcorr_`neg'`r'_`v'.png, replace	
}
	
exit	
