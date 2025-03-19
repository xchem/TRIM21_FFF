#!/bin/bash

set -e

KEY=$1
TARGET=$2
DIR=`dirname $(pwd)`

if [[ -z $KEY ]] ; then
	echo "no merging hypothesis nickname provided"
	exit 1
fi

if [[ -z $KNIT ]]; then
	echo '$KNIT' variable not set
	exit 2
fi

if [[ -z $KNIT ]]; then
	echo '$KNIT' variable not set
	exit 2
fi

ls $KNIT/Knitwork/runKnitting.py

cd $KEY

python $KNIT/Knitwork/runKnitting.py \
	--substructure_pair_file fragment_output/substructure_pairs.json \
	--descriptor prop_pharmfp \
	--working_dir knitwork_temp \
	--output_dir knitwork_impure_output \
	--run_parallel \
	--n_parallel 20 \
	--limit 100 \
	--prolif_prioritization \
	--max_prioritize 100 \
	--target $(basename $DIR) \
	--substructure_dir fragment_output \
	-fd $(dirname $DIR)
