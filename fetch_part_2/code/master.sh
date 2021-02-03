#!/usr/bin/env zsh
step="fetch_part_2"
next="build_part_2"
rsync $step/code/run_sas.sh $WRDS:~ &
rsync $step/code/*.sas $WRDS:~ &
wait

tables=(compq)
ssh -t $WRDS << SCRIPT
for i in ${tables[@]}; do
  qsub -sync y run_sas.sh get_\${i}.sas
done
SCRIPT

# Get the Stata files from server
rsync $WRDS:~/compustat_data2/compq.dta ${next}/in/


say "done" &
