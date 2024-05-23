#!/usr/bin/env bash


mkdir -p results/pops

echo "Run Pops for COVID19 GWAS summary statistic file..."

python pops/pops.py \
 --gene_annot_path pops/data/human_lung/utils/gene_annot_jun10.txt \
 --feature_mat_prefix pops/data/human_lung/features_munged/lung_pops \
 --num_feature_chunks 2 \
 --magma_prefix pops/data/human_lung/magma_scores/lung-COVID19 \
 --control_features_path pops/data/human_lung/utils/features_jul17_control.txt \
 --out_prefix results/pops/lung-COVID19


 python pops/pops.py \
 --gene_annot_path pops/data/human_pbmc/utils/gene_annot_jun10.txt \
 --feature_mat_prefix pops/data/human_pbmc/features_munged/pbmc_pops \
 --num_feature_chunks 2 \
 --magma_prefix pops/data/human_pbmc/magma_scores/pbmc-COVID19 \
 --control_features_path pops/data/human_pbmc/utils/features_jul17_control.txt \
 --out_prefix results/pops/pbmc-COVID19


 echo "Pops COVID19 pipeline completed" 
