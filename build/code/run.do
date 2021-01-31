**The compustat data need some modification to merge without error:
pwd
use "../in/compa.dta", clear
* Rename fyear and make gvkey numeric (why did Sufi do that?)
ren fyear yeara
destring gvkey, replace


* Declare panel data
xtset gvkey yeara, y

**Generate derived variables
gen bd = (dlc + dltt) / at
* Lagged cashless variables
loc to_lag "cflc tanglc nwlc asslc mblc"
gen asslc = at - che
gen cflc = oibdp / asslc
gen tanglc = ppent / asslc
gen nwlc = (asslc - lt) / asslc
gen mblc = (asslc - (at - lt) + csho * prcc_f) / asslc
foreach v of loc to_lag {
	gen `v'll = l.`v'
	drop `v'
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
xtset gvkey yq
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

* Save the result as temp file
loc tmp2 "../tmp/compustat_built.dta"
save `tmp2', replace

**Build the merged panel dataset
use "../in/sufi_rfs_linesofcredit20070221data.dta", clear
merge 1:1 gvkey yeara using `tmp2'
keep if _merge == 3
drop _merge

**Note: Left merge on Sufi's data took care of sample selection. Moving on.

save "../out/out.dta", replace
