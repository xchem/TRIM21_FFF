#!/bin/bash

set -e

KEY=$1

if [[ -z $KEY ]] ; then
	echo "no merging hypothesis nickname provided"
	exit 1
fi

if [[ -z $KNIT ]]; then
	echo '$KNIT' variable not set
	exit 2
fi

ls $KNIT/Knitwork/runKnitting.py

cd $KEY

python $KNIT/Knitwork/runKnitting.py \
	--substructure_pair_file fragment_output/substructure_pairs.json \
	--pure_search \
	--working_dir knitwork_temp \
	--output_dir knitwork_pure_output \
	--run_parallel \
	--n_parallel 10 \
	--limit 100 \
	--clear_working_dir
