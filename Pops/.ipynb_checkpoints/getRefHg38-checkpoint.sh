#!/usr/bin/env bash

# Create hg38 Reference Panel
PGEN_ZST_URL="https://www.dropbox.com/s/j72j6uciq5zuzii/all_hg38.pgen.zst?dl=1"
PVAR_ZST_URL="https://www.dropbox.com/scl/fi/fn0bcm5oseyuawxfvkcpb/all_hg38_rs.pvar.zst?rlkey=przncwb78rhz4g4ukovocdxaz&dl=1"
PSAM_URL="https://www.dropbox.com/s/2e87z6nc4qexjjm/hg38_corrected.psam?dl=1"


echo "Downloading data files..."
curl -L "${PGEN_ZST_URL}" -o all_hg38.pgen.zst
curl -L "${PVAR_ZST_URL}" -o all_hg38.pvar.zst
curl -L "${PSAM_URL}" -o all_hg38.psam

echo "Decompressing data files..."
zstd -d all_hg38.pgen.zst -o all_hg38.pgen
zstd -d all_hg38.pvar.zst -o all_hg38.pvar

echo "Converting to PLINK binary format..."
./plink2 --pfile  all_hg38 \
         --make-bed \
	     --max-alleles 2 \
         --out data/all_hg38
      
echo "Plink binary conversion finish"

rm all_hg38.pgen all_hg38.pvar all_hg38.pgen.zst all_hg38.pvar.zst all_hg38.psam