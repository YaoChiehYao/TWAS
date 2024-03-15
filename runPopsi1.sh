#!/usr/bin/env bash

PATH_TO_RAWDATA="/Users/JerryYaw/Documents/GWAS_Compute_Methods/pops-master/raw_data"
urls=(
"https://storage.googleapis.com/covid19-hg-public/20200915/results/20201020/COVID19_HGI_A1_ALL_20201020.txt.gz"
)
 
SNPLOC_FILE="/Users/JerryYaw/Documents/GWAS_Compute_Methods/pops-master/raw_data/snp_locations.txt"
GENELOC_FILE="/Users/JerryYaw/Documents/GWAS_Compute_Methods/pops-master/magma_v1.10_mac/NCBI38/filtered_NCBI38.gene.loc"
 
mkdir -p /Users/JerryYaw/Documents/GWAS_Compute_Methods/pops-master/magma_v1.10_mac/ANNOT
 
PATH_TO_MAGMA_ANNOT="/Users/JerryYaw/Documents/GWAS_Compute_Methods/pops-master/magma_v1.10_mac/ANNOT"

cd raw_data

for url in "${urls[@]}"; do
    filename=$(basename "$url")
    if [ ! -f "$filename" ]; then
        echo "Downloading $filename..."
        curl -O "$url"
    else
        echo "$filename already exists. Skipping download."
    fi
done

if [ -f "COVID19_HGI_A1_ALL_20201020.txt.gz" ]; then
    echo "Extracting SNP locations..."
    gunzip -c COVID19_HGI_A1_ALL_20201020.txt.gz | awk 'BEGIN{OFS="\t"}{if(NR>1) print $13,$1,$2}' > "$SNPLOC_FILE"
else
    echo "Error: Downloaded file does not exist."
    exit 1
fi

cd ..

# Create Magma Annotation
./magma_v1.10_mac/magma \
 --annotate \
 --snp-loc $SNPLOC_FILE \
 --gene-loc $GENELOC_FILE \
 --out $PATH_TO_MAGMA_ANNOT/MAGMA_ANNOT
 
Create Reference Panel
PGEN_ZST_URL="https://www.dropbox.com/s/j72j6uciq5zuzii/all_hg38.pgen.zst?dl=1"
PVAR_ZST_URL="https://www.dropbox.com/scl/fi/fn0bcm5oseyuawxfvkcpb/all_hg38_rs.pvar.zst?rlkey=przncwb78rhz4g4ukovocdxaz&dl=1"
PSAM_URL="https://www.dropbox.com/s/2e87z6nc4qexjjm/hg38_corrected.psam?dl=1"

mkdir -p reference_panel
PATH_TO_REFERENCE_PANEL_PLINK="/Users/JerryYaw/Documents/GWAS_Compute_Methods/pops-master/reference_panel"

OUTPUT_PREFIX="reference_panel" 
 
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
         --out $PATH_TO_REFERENCE_PANEL_PLINK/$OUTPUT_PREFIX
echo "Plink binary conversion finish"

rm all_hg38.pgen all_hg38.pvar all_hg38.pgen.zst all_hg38.pvar.zst all_hg38.psam


OUTPUT_DIR="/Users/JerryYaw/Documents/GWAS_Compute_Methods/pops-master/output"
MAGMA_BINARY="/Users/JerryYaw/Documents/GWAS_Compute_Methods/pops-master/magma_v1.10_mac/magma"

mkdir -p $OUTPUT_DIR

echo "Calculate magma score for each GWAS summary statistic file..."

# Loop over .txt.gz files in PATH_TO_RAWDATA
for file in "$PATH_TO_RAWDATA"/*.txt.gz; do
    FILENAME=$(basename "$file")
    FILENAME_TXT="${FILENAME%.gz}"
    OUTPUT_FILE="${PATH_TO_RAWDATA}/${FILENAME_TXT}"

    if [ ! -f "$OUTPUT_FILE" ]; then
        echo "Unzipping $FILENAME..."
        gunzip -c "$file" > "$OUTPUT_FILE"
    else
        echo "$OUTPUT_FILE already exists."
    fi

    # Run MAGMA gene-property analysis for the preprocessed GWAS summary statistics file
    echo "Running MAGMA for $FILENAME_TXT..."
    $MAGMA_BINARY \
        --bfile $PATH_TO_REFERENCE_PANEL_PLINK/reference_panel \
        --gene-annot $PATH_TO_MAGMA_ANNOT/MAGMA_ANNOT.genes.annot \
        --pval "${PATH_TO_RAWDATA}/${FILENAME_TXT}" use='13,9' ncol=11 \
        --gene-model snp-wise=mean \
        --out "${OUTPUT_DIR%.*}"

    # Optional: Remove the uncompressed and preprocessed summary statistics file to save space
    # rm "$OUTPUT_FILE"
done
echo "Magma score calculation completed" 
