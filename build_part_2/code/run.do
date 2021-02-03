**The compustat data need some modification to merge without error:
pwd
use "../in/compq.dta", clear
* Rename fyear and make gvkey numeric
ren fyearq yeara
destring gvkey, replace

* Declare panel data
gen yq = yq(yeara, fqtr)
format yq %tq
drop if mi(gvkey) | mi(yq)
duplicates drop gvkey yq, force
xtset gvkey yq, q

**Zero-fill selected variables
replace txditc=0 if mi(txditc)
replace oibdp=0 if mi(oibdp)

**Generate derived variables
gen total_debt = dltcq + dlttq
gen total_debt_lag = l.total_debt
gen total_assets_lag = l.at
gen net_debt_issuance = (total_debt - total_debt_lag) / total_assets_lag
*TODO: gen net_equity_issuance = f(statement of cash flows)
gen leverage_ratio = total_debt / at
gen net_worth_a = seqq / at
* Lagged cashless variables
loc to_log
loc to_lag
gen cflc = oibdp / asslc
gen tanglc = ppent / asslc
gen nwlc = (asslc - lt) / asslc
gen mblc = (asslc - (at - lt - pstkl + txditc) + csho * prcc_f) / asslc
foreach v of loc to_log {
	gen l`v' = log(`v')
}
foreach v of loc to_lag {
	gen `v'l1 = l.`v'
}
* Cash (scaled by assets)
gen cash = che / at

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

**Generate variables that require Sufi's data
foreach v in line lineun linetot {
	gen ra_`v' = `v' / at
	if ("`v'" != "line") {
	    gen liq_`v' = `v' / (`v' + che)
	}
}

**Generate year dummies
levelsof yeara, local(years)
foreach y of local years {
  gen yd`y' = (yeara == `y')
}

**Make sic code just one digit
replace sic = substr(sic, 1, 1)
destring sic, replace

**Generate cash flow deciles
xtile cfcat = cflc, nq(10)

save "../out/out.dta", replace
