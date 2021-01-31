use "../in/out.dta", clear

*Sufi's code uses ";" delimiter; follow suit.
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
