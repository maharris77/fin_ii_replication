#!/usr/bin/env zsh
step="build"
next="analyze"

remote_dir="$REMOTE_HOME/workspace/fin_ii_replication/"
code_dir="$step/code/"
in_dir="$step/in/"
out_dir="$step/out/"

# Sync necessary code and inputs to remote machine
# First, store command: inserts a file-changed indicator into rsync log.
indic="File changed!"
my_rsync="rsync -a --log-file=\$(mktemp /tmp/rsync.log.${step}.XXXXXX) --log-file-format=\"${indic} %f %i\""
# Remove old temp files created by this script
rm /tmp/rsync.log.${step}.*
# Sync code and data files, marking whether they changed
eval $my_rsync "$step/code/*.do" "$REMOTE:${remote_dir}${code_dir}" &
eval $my_rsync "$step/in/*.dta" "$REMOTE:${remote_dir}${in_dir}" &
wait
# Only run remote commands to produce output if some input has changed
if fgrep "${indic}" /tmp/rsync.log.${step}.* > /dev/null; then
    echo "rsync did something! Running commands..."
    ssh -t $REMOTE << SCRIPT
      cd $remote_dir$code_dir
      stata run.do
SCRIPT
else
  echo "rsync: All files were current. Skipping commands..."
fi

# Sync outputs back to local machine
rsync -a "$REMOTE:${remote_dir}${out_dir}*.dta" $step/out/ &
wait

# Sync to next in dir (Would make symlink, but data access problems on Windows)
rsync -a $step/out/* $next/in/

say "done" &
