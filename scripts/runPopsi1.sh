#!/usr/bin/env bash


echo "Calculate magma score for each GWAS summary statistic file..."

# Run magma score, please make sure magma alread installed
./pops/magma_v1.10_mac/magma \
 --bfile pops/data/all_hg38 \
 --gene-annot pops/data/magma_0kb.genes.annot \
 --pval pops/data/data_covid/COVID19_GWAS_summary_stats.txt use='13,9' ncol=11 \
 --gene-model snp-wise=mean \
 --out pops/data/human_lung/magma_scores/lung-COVID19

./pops/magma_v1.10_mac/magma \
 --bfile pops/data/all_hg38 \
 --gene-annot pops/data/magma_0kb.genes.annot \
 --pval pops/data/data_covid/COVID19_GWAS_summary_stats.txt use='13,9' ncol=11 \
 --gene-model snp-wise=mean \
 --out pops/data/human_pbmc/magma_scores/pbmc-COVID19

echo "Magma score calculation completed" 
