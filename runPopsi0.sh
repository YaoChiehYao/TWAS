#!/usr/bin/env bash

python munge_feature_directory.py \
 --gene_annot_path example/data/utils/gene_annot_jun10.txt \
 --feature_dir example/data/features_raw/ \
 --save_prefix example/data/features_munged/pops_features \
 --max_cols 500


