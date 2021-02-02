use "../in/out.dta", clear

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
xi: dprobit lineofcredit  yd* i.sic cflcl1 tanglcl1 lasslcl1 nwlcl1 mblcl1
q_salesvar cfvar spind exch lfirmage, cluster(gvkey);

xi: dprobit lineofcredit_rs     yd* i.sic cflcl1 tanglcl1 lasslcl1 nwlcl1 mblcl1
q_salesvar cfvar spind exch lfirmage if randomsample==1, cluster(gvkey);

xi: regress liq_linetot   yd* i.sic cflcl1 tanglcl1 lasslcl1 nwlcl1 mblcl1
q_salesvar cfvar spind exch lfirmage if randomsample==1, cluster(gvkey) robust;

xi: regress liq_linetot   yd* i.sic cflcl1 tanglcl1 lasslcl1 nwlcl1 mblcl1
q_salesvar cfvar spind exch lfirmage if randomsample==1 & lineofcredit_rs==1,
cluster(gvkey) robust;

xi: regress liq_lineun    yd* i.sic cflcl1 tanglcl1 lasslcl1 nwlcl1 mblcl1
q_salesvar cfvar spind exch lfirmage if randomsample==1, cluster(gvkey) robust;

xi: regress liq_lineun    yd* i.sic cflcl1 tanglcl1 lasslcl1 nwlcl1 mblcl1
q_salesvar cfvar spind exch lfirmage if randomsample==1 & lineofcredit_rs==1,
cluster(gvkey) robust;
