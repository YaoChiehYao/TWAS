#!/usr/bin/env bash

# Check out the project
git clone git@github.com:EngreitzLab/ABC-GWAS-Paper.git

cd ABC-GWAS-Paper/ABC-Max/

# Install conda environment
conda env create --file abc-max.yml
conda activate abc-max

mkdir -p data

# Download COVID19 fine-map and save in data directory 
wget -O file.zip "https://storage.googleapis.com/covid19-hg-in-silico-followup/V4/GCTA_COJO/COVID19_HGI_20201020.IndependentVariants.GenePrioritisation.zip"
unzip file.zip -d data/ 
rm file.zip

# Download ABC example data and save in data directory
wget --cut-dirs 4 -r ftp://ftp.broadinstitute.org/outgoing/lincRNA/Nasser2020/data/ \
mv ftp.broadinstitute.org data/

# Process variantList, credibleSets and GeneLists from finemapping results   
cd data

# Merge all Pops genes to credibleSets List
awk 'NR==1' $(ls *PoPS.Genes.txt | head -n 1) > COVID19_HGI_ALL_20201020.b37.PoPS.Genes.txt
awk 'FNR>1' *PoPS.Genes.txt | sort -t$'\t' -k1,1V >> COVID19_HGI_ALL_20201020.b37.PoPS.Genes.txt

# Merge all independent variants to variantList
awk 'NR==1' $(ls *independent.txt | head -n 1) > COVID19_HGI_ALL_20201020.b37.independent.txt
awk 'FNR>1' *independent.txt | sort -t$'\t' -k1,1V >> COVID19_HGI_ALL_20201020.b37.independent.txt

cd ..

mv ../../COVID19_Gene_Scraper.py .

# Webscraper GeneList from CDC Human Genes
python COVID19_Gene_Scraper.py

# Overlap config files
mv ../../ABC-Max.config-traits.tsv ../../ABC-Max.COVID19.json config/

# Run ABC-MAX pipeline
snakemake --snakefile snakemake/ABC-Max.snakefile \
  --configfile config/ABC-Max.COVID19.json \
  --config logDir=log/ outDir=out/ \
  --cores 1 \
  --rerun-incomplete
