#!/usr/bin/env bash

# Create hg38 Reference Panel
PGEN_ZST_URL="https://www.dropbox.com/s/j72j6uciq5zuzii/all_hg38.pgen.zst?dl=1"
PVAR_ZST_URL="https://www.dropbox.com/scl/fi/fn0bcm5oseyuawxfvkcpb/all_hg38_rs.pvar.zst?rlkey=przncwb78rhz4g4ukovocdxaz&dl=1"
PSAM_URL="https://www.dropbox.com/s/2e87z6nc4qexjjm/hg38_corrected.psam?dl=1"


echo "Downloading data files..."
curl -L "${PGEN_ZST_URL}" -o pops/data/all_hg38.pgen.zst || { echo "Download failed"; exit 1; }
curl -L "${PVAR_ZST_URL}" -o pops/data/all_hg38.pvar.zst || { echo "Download failed"; exit 1; }
curl -L "${PSAM_URL}" -o pops/data/all_hg38.psam || { echo "Download failed"; exit 1; }

echo "Decompressing data files..."
zstd -d pops/data/all_hg38.pgen.zst -o pops/data/all_hg38.pgen || { echo "Decompression failed"; exit 1; }
zstd -d pops/data/all_hg38.pvar.zst -o pops/data/all_hg38.pvar || { echo "Decompression failed"; exit 1; }

echo "Converting to PLINK binary format..."
./pops/plink2 --pfile pops/data/all_hg38 \
         --make-bed \
         --max-alleles 2 \
         --out pops/data/all_hg38 || { echo "PLINK conversion failed"; exit 1; }

      
echo "Plink binary conversion finish"


rm pops/data/all_hg38.pgen pops/data/all_hg38.pvar pops/data/all_hg38.pgen.zst pops/data/all_hg38.pvar.zst pops/data/all_hg38.psam


echo "Calculating allele frequencies..."
./pops/plink2 --bfile pops/data/all_hg38 \
         --freq \
         --out pops/data/all_hg38_freq

echo "All hg38 file preparation done"