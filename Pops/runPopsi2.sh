#!/usr/bin/env bash


mkdir -p results

echo "Run Pops for COVID19 GWAS summary statistic file..."

python pops.py \
 --gene_annot_path data/human_lung/utils/gene_annot_jun10.txt \
 --feature_mat_prefix data/human_lung/features_munged/lung_pops \
 --num_feature_chunks 2 \
 --magma_prefix data/human_lung/magma_scores/lung-COVID19 \
 --control_features_path data/human_lung/utils/features_jul17_control.txt \
 --out_prefix results/lung-COVID19


 python pops.py \
 --gene_annot_path data/human_pbmc/utils/gene_annot_jun10.txt \
 --feature_mat_prefix data/human_pbmc/features_munged/pbmc_pops \
 --num_feature_chunks 2 \
 --magma_prefix data/human_pbmc/magma_scores/pbmc-COVID19 \
 --control_features_path data/human_pbmc/utils/features_jul17_control.txt \
 --out_prefix results/pbmc-COVID19


 echo "Pops COVID19 pipeline completed" 
