#!/bin/bash
#$ -cwd
echo "Starting Job at `date`"
sas $1
echo "Ending Job at `date`"
