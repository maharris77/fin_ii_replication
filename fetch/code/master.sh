#!/usr/bin/env zsh
step="fetch"
next="build"
rsync $step/code/run_sas.sh $WRDS:~ &
rsync $step/code/*.sas $WRDS:~ &
wait

tables=(compa compq names)
ssh -t $WRDS << SCRIPT
for i in ${tables[@]}; do
  qsub -sync y run_sas.sh get_\${i}.sas
done
SCRIPT

# Get the Stata files from server
rsync $WRDS:~/compustat_data/\{compq,compa,names\}.dta ${next}/in/

# Get the SPMIM variable that was removed from Compustat (ca. July 2020)
# (But don't redownload if it's already in place)
url="https://www.dropbox.com/s/ksrfg4i6shj6g61/SPMIM_data.dta?dl=1"
wget -nc -O ${next}/in/SPMIM_data.dta $url


say "done" &
