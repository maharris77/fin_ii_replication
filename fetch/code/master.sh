#!/usr/bin/env zsh
step="fetch"
next="build"
scp $step/code/run_sas.sh $WRDS:~ &
scp $step/code/*.sas $WRDS:~ &
wait

tables=(compa compq names)
ssh -t $WRDS << SCRIPT
for i in ${tables[@]}; do
  qsub -sync y run_sas.sh get_\${i}.sas
done
SCRIPT

# Get the Stata files.
# Clearer, but slower (no simultaneous download), to use /\{compq,compa\}.dta
#   syntax and no loop.
for i in "${tables[@]}"; do
  scp $WRDS:~/compustat_data/${i}.dta ${next}/in/ &
done
wait

say "done"
