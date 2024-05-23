#!/bin/bash
#SBATCH --job-name=process_cSNPS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --cpus-per-task=1
#SBATCH --partition=short                                 
#SBATCH --mem=32G     
#SBATCH -t 10:00:00    
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=yao.yao-@northeastern.edu
#SBATCH --out=/scratch/yao.yao-/rCOGS/logs/%x_%j.log
#SBATCH --error=/scratch/yao.yao-/rCOGS/logs/%x_%j.err

# Commands
each "process cSNPs file start..."

each "download 1KG phase3 hg38 vcf file"
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/1000G.phase3.integrated.sites_only.no_MATCHED_REV.hg38.vcf

each "convert vcf to vcf.gz file"
bgzip -c  1000G.phase3.integrated.sites_only.no_MATCHED_REV.hg38.vcf > 1000G.phase3.integrated.sites_only.no_MATCHED_REV.hg38.vcf.gz

each "index vcf.gz file"
tabix -p vcf 1000G.phase3.integrated.sites_only.no_MATCHED_REV.hg38.vcf.gz

each "remove vcf file"
rm 1000G.phase3.integrated.sites_only.no_MATCHED_REV.hg38.vcf

each "generate cSNPs file"

./ensembl-vep/vep -i 1000G.phase3.integrated.sites_only.no_MATCHED_REV.hg38.vcf.gz -o cSNPs_file.tsv --cache --dir_cache /home/yao.yao-/.vep --offline --assembly GRCh38 --tab --fields "Location,Gene" --symbol --canonical --biotype --tsl --ccds --uniprot --pick

echo "cSNPs file generated"

echo "process the cSNPs file"

awk 'BEGIN{OFS="\t"; print "chr", "pos", "ensg"} 
     /^#/ {next} 
     {split($1, a, ":|-"); print a[1], a[2], $2}' cSNPs_file.tsv > processed_cSNPs_file.tsv

echo "cSNPs file successfully processed"