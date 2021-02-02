use "../in/out.dta", clear
set more off

*Sufi's code uses ";" as delimiter; follow suit.
#delim ;


*TABLE 1: SUMMARY STATISTICS;
tabstat
lineofcredit
bd
cflcl1
tanglcl1
nwlcl1
asslcl1
mblcl1

q_salesvar
cfvar

spind
exch
firmage
, s(mean p50 sd n) col(stat) f(%7.3f) ;

tabstat
lineofcredit_rs
ra_linetot
ra_lineun
ra_line
liq_linetot
liq_lineun
def
bd
cflcl1
tanglcl1
nwlcl1
asslcl1
mblcl1

q_salesvar
cfvar

spind
exch
firmage
if randomsample==1, s(mean p50 sd n) col(stat) f(%7.3f) ;


*TABLE 3;
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
  mtitles(Full Random Random "With line of credit" Random "With line of credit")
  ;


*FIGURE 1;
table cfcat, c(mean lineofcredit mean cash);
preserve;
collapse lineofcredit cash, by(cfcat);
twoway scatter cash cfcat, connect(1) msymbol(X) yaxis(1)
  ytitle("Cash/assets") xtitle("Deciles of EBITDA/(assets-cash)") ||
  scatter lineofcredit cfcat, connect(1) msymbol(d) yaxis(2)
  ytitle("Fraction with line of credit", axis(2))
  legend(order(1 "Average cash/assets (left axis)" 2 "Fraction with line of credit (right axis)"));
* NOTE: Graph export will not work in batch mode. If on *nix system, run xstata.;
graph export ../tmp/figure_1.eps, replace;
window manage close graph;
restore;

exit, STATA clear;
