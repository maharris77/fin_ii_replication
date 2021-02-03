use "../in/out.dta", clear
set more off

*Sufi's code uses ";" as delimiter; follow suit.
#delim ;


*TABLE 2: SUMMARY STATISTICS;
eststo clear;
estpost tabstat
net_debt_issuance
net_equity_issuance
leverage_ratio

net_worth_ratio
nwc_ratio
cash_ratio
EBITDA_ratio
cashflow_ratio
net_income_ratio
interest_expense_ratio

market_to_book_ratio
tangible_assets_ratio
log_assets
, s(mean med sd n) col(stat);
eststo s1;

esttab s1 using ../tmp/table_2.tex, replace
  cells((mean(fmt(%9.3f)) p50(fmt(%9.3f)) sd(fmt(%9.3f)))) collabels("Mean" "Median" "SD")
  title("Summary Statistics") booktabs nonumbers;
/*
*TABLE 3;
eststo clear;

eststo: xi: dprobit lineofcredit  yd* i.sic cflcl1 tanglcl1 lasslcl1 nwlcl1 mblcl1
q_salesvar cfvar spind exch lfirmage, cluster(gvkey);

eststo: xi: dprobit lineofcredit_rs     yd* i.sic cflcl1 tanglcl1 lasslcl1 nwlcl1 mblcl1
q_salesvar cfvar spind exch lfirmage if randomsample==1, cluster(gvkey);

eststo: xi: regress liq_linetot   yd* i.sic cflcl1 tanglcl1 lasslcl1 nwlcl1 mblcl1
q_salesvar cfvar spind exch lfirmage if randomsample==1, cluster(gvkey) robust;

eststo: xi: regress liq_linetot   yd* i.sic cflcl1 tanglcl1 lasslcl1 nwlcl1 mblcl1
q_salesvar cfvar spind exch lfirmage if randomsample==1 & lineofcredit_rs==1,
cluster(gvkey) robust;

eststo: xi: regress liq_lineun    yd* i.sic cflcl1 tanglcl1 lasslcl1 nwlcl1 mblcl1
q_salesvar cfvar spind exch lfirmage if randomsample==1, cluster(gvkey) robust;

eststo: xi: regress liq_lineun    yd* i.sic cflcl1 tanglcl1 lasslcl1 nwlcl1 mblcl1
q_salesvar cfvar spind exch lfirmage if randomsample==1 & lineofcredit_rs==1,
cluster(gvkey) robust;


esttab using ../tmp/table_3.tex, replace r2 label booktabs drop(_Isic_* yd*)
  title(Bank lines of credit and firm characteristics\label{tab3})
  mtitles(Full Random Random "\shortstack{With line\\of credit}" Random "\shortstack{With line\\of credit}")
  mgroups("\shortstack{Firm has line of credit\{0,1\}\\Probit (marginal effects)}"
          "\shortstack{Total line/(total\\line + cash) OLS}"
          "\shortstack{Unused line/(unused\\line + cash) OLS}"
          , pattern(1 0 1 0 1 0) span prefix(\multicolumn{2}{c}{) suffix(}));
*/

exit, STATA clear;
