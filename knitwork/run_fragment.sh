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

ls $KNIT/Fragment/runEnumeration.py

cd $KEY

python $KNIT/Fragment/runEnumeration.py \
	-i *_input.csv \
	-o fragment_output \
	--record_equiv_synthon \
	--r_group_expansions
