#!/usr/bin/env zsh
step="build"
next="analyze"

remote_dir="$REMOTE_HOME/workspace/fin_ii_replication/"
code_dir="$step/code/"
in_dir="$step/in/"
out_dir="$step/out/"

# Copy necessary code and inputs to remote machine
scp *.do "$REMOTE:${remote_dir}${code_dir}" &
scp ../in/*.dta "$REMOTE:${remote_dir}${in_dir}" &
wait

ssh -t $REMOTE << SCRIPT
  cd $remote_dir$code_dir
  stata run.do
SCRIPT

# Copy outputs back to local machine
scp "$REMOTE:${remote_dir}${out_dir}*.dta" ../out/ &
wait

# Copy to next in dir (Would make symlink, but data access problems on Windows)
cp ../out/* ../../$next/in/

say "done"
