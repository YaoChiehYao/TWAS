#!/usr/bin/env bash

OUTPUT_DIR="/Users/JerryYaw/Documents/GWAS_Compute_Methods/pops-master/output"

mkdir -p result

python pops.py \
 --gene_annot_path example/data/utils/gene_annot_jun10.txt \
 --feature_mat_prefix example/data/features_munged/pops_features \
 --num_feature_chunks 2 \
 --magma_prefix $OUTPUT_DIR/ensembleID/COVID19_HGI_A1_ALL_20201020ENS \
 --out_prefix result/COVID19_HGI_A1_ALL_20201020ENS
