#!/usr/bin/env zsh
say "Running the entire project, without fetch." &

#steps=(fetch build analyze)
steps=(build analyze)
for s in ${steps[@]}; do
  say "${s}"
  $s/code/master.sh
done

say "Fully done!" &
