**The compustat data need some modification to merge without error:
pwd
use "../in/compa.dta", clear
* Rename fyear and make gvkey numeric (why did Sufi do that?)
ren fyear yeara
destring gvkey, replace

**Create the "Years since IPO" variable
gen year_if_price_nonmissing = year if !mi(prcc_f)
rangestat (firstnm) year_if_price_nonmissing, interval(yeara . .) by(gvkey)
ren year_if_price_nonmissing_firstnm ipo_year
gen firmage = yeara - ipo_year

* NOTE: Now I don't need to hold on to the extra years.
drop if yeara < 1990

* Declare panel data
drop if mi(gvkey) | mi(yeara)
duplicates drop gvkey yeara, force
xtset gvkey yeara, y

**Generate derived variables
gen bd = (dlc + dltt) / at
* Lagged cashless variables
loc to_lag "cflc tanglc nwlc asslc mblc"
gen asslc = at - che
gen cflc = oibdp / asslc
gen tanglc = ppent / asslc
gen nwlc = (asslc - lt) / asslc
gen mblc = (asslc - (at - lt - pstkl + txditc) + csho * prcc_f) / asslc
foreach v of loc to_lag {
	gen `v'l1 = l.`v'
}

**Make the sales-based volatility measure from quarterly data
preserve
use "../in/compq.dta", clear
* SIC codes are in a different database table
merge m:1 gvkey using "../in/names.dta"
keep if _merge==3
drop _merge
* Same key modifications as before
ren fyearq yeara
destring gvkey, replace
* Turn this into a quarterly panel (we need lags of sales)
gen yq = yq(yeara, fqtr)
format yq %tq
drop if mi(gvkey) | mi(yq)
duplicates drop gvkey yq, force
xtset gvkey yq, q
* Start generating volatility info
gen sale_diff = saleq - l.saleq
bys gvkey yeara: egen avg_at = mean(atq)
bys gvkey yeara: egen sd_sale_diff = sd(sale_diff)
gen volat = sd_sale_diff / avg_at
* Calculate it by year and 3-digit SIC code
gen sic3 = substr(sic, 1, 3)
bys sic3 yeara: egen q_salesvar = median(volat)
* Collapse to annual
keep gvkey yeara q_salesvar sic
bys _all: keep if _n==1
* Save the result as temp file
loc tmp1 "../tmp/compustat_q_vars.dta"
save `tmp1', replace
* Go back to annual dataset
restore

**Merge volatility and SIC codes from quarterly data
merge 1:1 gvkey yeara using `tmp1'
keep if _merge==3
drop _merge

**Make the Mackie-Mason CF variance measure
sort gvkey yeara
gen oibdp_diff = oibdp - l.oibdp
rangestat (sd) oibdp_diff (mean) asslc, interval(yeara -4 -1) by(gvkey)
gen cfvar = oibdp_diff_sd / asslc_mean

**Winsorize financial variables
loc fin_vars "bd cflcl1 tanglcl1 nwlcl1 mblcl1"
****** NOTE: HE SEEMS TO HAVE NOT WINSORIZED asslcl1 !
winsor2 `fin_vars', cuts(5 95) replace

**Make the "In an S&P index" variable
preserve
use "../in/SPMIM_data.dta", clear
drop if mi(spmim)
* All obs left are S&P index obs. Collapse data and add indicator.
keep gvkey //year
bys _all: keep if _n==1
gen spind = 1
* Prepare for merge
//ren year yeara
* Save the result as temp file
loc tmp2 "../tmp/spind.dta"
save `tmp2', replace
* Go back to main compustat dataset
restore

**Merge the "In an S&P index" variable
//merge 1:1 gvkey yeara using `tmp2'
merge m:1 gvkey using `tmp2'
drop if _merge == 2
drop _merge
* NOTE: NO COVERAGE AFTER 2004; but Sufi stops in 2003.
replace spind = 0 if mi(spind)

**Create the "Traded OTC" variable
gen exch = inlist(exchg, 13, 19)

* Save the result as temp file
loc tmp3 "../tmp/compustat_built.dta"
save `tmp3', replace

**Build the merged panel dataset
use "../in/sufi_rfs_linesofcredit20070221data.dta", clear
merge 1:1 gvkey yeara using `tmp3'
keep if _merge == 3
drop _merge

**Note: Left merge on Sufi's data took care of sample selection. Moving on.

save "../out/out.dta", replace
