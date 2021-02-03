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
gen market_to_book_ratio = (atq - (atq - ltq + txditcq) + cshoq * prccq) / atq
gen tangible_assets_ratio = ppentq / atq
gen log_assets = log(atq)


**Enforce data requirements
loc require_vars at saleq ppentq total_debt seqq cheq actq lctq oibdpq ibq ///
								 dpq niq xintq market_to_book_ratio
loc condition
foreach v of loc require_vars {
	loc condition `condition' !mi(`v') & !mi(l.`v') &
}
loc condition `condition' 1
di "`condition'"
keep if `condition'

**Time period restriction
keep if inrange(yeara, 1996, 2005)

**Enforce 4 consecutive quarters for firm at some point
* First, count obs in a rolling window
rangestat (count) yq, interval(yq -3 0) by(gvkey)
* Drop any firm with max count under 4.
bys gvkey (yq_count): gen to_drop = (yq_count[_N] < 4)
drop if to_drop


*TODO: Winsorize financial variables
loc fin_vars
//winsor2 `fin_vars', cuts(5 95) replace

save "../out/out.dta", replace
