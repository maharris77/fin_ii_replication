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
replace txditcq=0 if mi(txditc)
replace oibdpq=0 if mi(oibdp)

**Generate derived variables
gen total_debt = dlcq + dlttq
gen total_debt_lag = l.total_debt
gen total_assets_lag = l.atq
gen net_debt_issuance = (total_debt - total_debt_lag) / total_assets_lag
gen net_equity_issuance = (sstky - prstkcy) / total_assets_lag
gen leverage_ratio = total_debt / atq
gen net_worth_ratio = seqq / atq
gen nwc_ratio = (actq - lctq) / atq
gen cash_ratio = cheq / atq
gen EBITDA_ratio = oibdpq / atq
gen cashflow_ratio = (ibq + dpq) / total_assets_lag
gen net_income_ratio = niq / total_assets_lag
gen interest_expense_ratio = xintq / total_assets_lag
gen market_to_book_ratio = (atq - (atq - ltq + txditcq) + cshoq * prccm) / atq
gen tangible_assets_ratio = ppentq / atq
gen log_assets = log(atq)

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
