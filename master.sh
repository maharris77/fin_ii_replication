#!/usr/bin/env zsh
say "Running the entire project."

steps=(fetch build analyze)
for s in ${steps[@]}; do
  say "Starting the ${s} step."
  cd ${s}/code
  ./master.sh
  cd ../..
done

say "Fully done!"
