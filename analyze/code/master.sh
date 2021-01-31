#!/usr/bin/env zsh
step="analyze"

remote_dir="$REMOTE_HOME/workspace/fin_ii_replication/"
code_dir="$step/code/"
in_dir="$step/in/"
out_dir="$step/out/"

# Copy necessary code and inputs to remote machine
rsync $step/code/*.do "$REMOTE:${remote_dir}${code_dir}" &
rsync $step/in/*.dta "$REMOTE:${remote_dir}${in_dir}" &
wait

ssh -t $REMOTE << SCRIPT
  cd $remote_dir$code_dir
  stata run.do
SCRIPT

# Copy outputs back to local machine
rsync "$REMOTE:${remote_dir}${out_dir}*.dta" $step/out/ &
wait

say "done"
