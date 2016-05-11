#!/bin/bash

#SBATCH -A iPlant-Collabs
#SBATCH -t 02:00:0
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -J idba
#SBATCH -p development
#SBATCH --mail-type BEGIN,END,FAIL
#SBATCH --mail-user kyclark@email.arizona.edu

set -u

WRAPPERDIR=$( cd "$( dirname "$0" )" && pwd )

./run-idba.pl -d $SCRATCH/data/assembly/velvet-fa -o $SCRATCH/velvet-out --debug --idba $WRAPPERDIR/bin/idba
