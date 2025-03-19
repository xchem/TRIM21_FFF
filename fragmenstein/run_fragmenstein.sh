#!/bin/bash

set -e

KEY=$1

if [[ -z $KEY ]] ; then
	echo "no merging hypothesis nickname provided"
	exit 1
fi

cd $KEY

which fragmenstein

time fragmenstein laboratory combine -i *_hits.sdf -t *_apo-desolv.pdb --victor Wictor

cd ..

python to_bulkdock.py $KEY

# sb.sh --job-name "2AZ_fragmenstein" $HOME2/slurm/run_bash_with_conda.sh run_fragmenstein.sh iter1_frags
