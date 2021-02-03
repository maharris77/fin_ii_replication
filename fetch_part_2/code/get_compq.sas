/*******************************************************************
SAS CODE TO ACCESS COMPUSTAT FUNDAMENTAL ANNUAL, 1990-2018
*******************************************************************/
/* This will create a new folder when we use the “libname'' command */
options dlcreatedir;
/* Remember to change jwb74 in these two lines of code to your WRDS username */
libname home '/home/duke/mharris7/compustat_data';
%let data_folder = /home/duke/mharris7/compustat_data2;
/* NOTE (for those interested). Each WRDS user gets a "home" folder which is
   permanant, yet small (~10gb), and a large "Scratch" folder, which cleans out
   every 10 days, yet is much larger (couple hundred gb). If you plan on using
   SAS-studio, I would save your code files in a home folder, and your data
   files in an equivalently-named "scratch folder" */
libname tmp '/scratch/duke/mharris7/compustat_data';

/* This code downloads the filtered Compustatdata to the folder “compustat_data” */
data home.compustat;
  /* This is the location of Compustatfundamental annual data */
  /* We also need to apply the same filteringswe did on the query page, see the where condition below*/
  set comp.fundq(where = ((CONSOL='C' and INDFMT='INDL' and DATAFMT='STD' and POPSRC='D') and (fyearq>=1994 & fyearq<=2007)));
  keep gvkey fyearq fqtr atq prccq cshoq ltq txditcq dlcq dlttq seqq actq lctq ppentq cheq prstkcy dvcq oibdpq xintq capxy aqcy saleq actq lctq sstky ipq dpq niq prccm;
run;


/* Same code again, using SQL */
/*proc sql;
create table home.compustat2 as select gvkey, fyear, conm, at from comp.funda
  where (CONSOL='C' and INDFMT='INDL' and DATAFMT='STD' and POPSRC='D') and
  (fyear>=1990 & fyear<=2018);
quit;*/


/* Let's convert the data to stata, so you can download */
proc export data = home.compustat
            outfile= "&data_folder./compq.dta"
            dbms=stata
            replace;
run;
