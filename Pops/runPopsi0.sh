#!/usr/bin/env bash

echo "Process feature files to feature matrix file..."

# Create feature matrix, please make sure human_lung and human_pbmc file are ready
python munge_feature_directory.py \
 --gene_annot_path data/human_lung/utils/gene_annot_jun10.txt \
 --feature_dir data/human_lung/features_raw/ \
 --save_prefix data/human_lung/features_munged/lung_pops \
 --max_cols 400


 python munge_feature_directory.py \
 --gene_annot_path data/human_lung/utils/gene_annot_jun10.txt \
 --feature_dir data/human_pbmc/features_raw/ \
 --save_prefix data/human_pbmc/features_munged/pbmc_pops \
 --max_cols 300

echo "Feature matrix process completed"
