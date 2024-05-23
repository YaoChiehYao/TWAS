#!/usr/bin/env bash

echo "Process feature files to feature matrix file..."

# Create feature matrix, please make sure human_lung and human_pbmc file are ready
python pops/munge_feature_directory.py \
 --gene_annot_path pops/data/human_lung/utils/gene_annot_jun10.txt \
 --feature_dir pops/data/human_lung/features_raw/ \
 --save_prefix pops/data/human_lung/features_munged/lung_pops \
 --max_cols 400


 python pops/munge_feature_directory.py \
 --gene_annot_path pops/data/human_lung/utils/gene_annot_jun10.txt \
 --feature_dir pops/data/human_pbmc/features_raw/ \
 --save_prefix pops/data/human_pbmc/features_munged/pbmc_pops \
 --max_cols 300

echo "Feature matrix process completed"
