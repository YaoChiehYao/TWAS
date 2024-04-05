#!/bin/bash

# Define paths
MODEL_DB_PATH="MetaXcan/software/predi_models"
GWAS_FILE_PATH="MetaXcan/software/data_covid"
OUTPUT_FILE_PATH="MetaXcan/software/output"
SPREDIXCAN_PATH="MetaXcan/software/SPrediXcan.py"

mkdir -p "$OUTPUT_FILE_PATH/spredixcan"
mkdir -p "$OUTPUT_FILE_PATH/smultixcan"

tissues=("Lung" "Whole_Blood")

gwas_files=(
  "COVID19_HGI_A1_ALL_20201020.txt.gz"
  "COVID19_HGI_A2_ALL_leave_23andme_20201020.txt.gz"
  "COVID19_HGI_B1_ALL_20201020.txt.gz"
  "COVID19_HGI_B2_ALL_leave_23andme_20201020.txt.gz"
  "COVID19_HGI_C1_ALL_leave_23andme_20201020.txt.gz"
  "COVID19_HGI_C2_ALL_leave_23andme_20201020.txt.gz"
  "COVID19_HGI_D1_ALL_20201020.txt.gz"
)

for gwas_file in "${gwas_files[@]}"; do
    # Check if GWAS file exists
    if [ ! -f "$GWAS_FILE_PATH/$gwas_file" ]; then
        echo "GWAS file $gwas_file not found."
        continue
    fi

    # Process each tissue for the current GWAS file
    for tissue in "${tissues[@]}"; do
        echo "Running SPrediXcan for $tissue with $gwas_file..."
        
        model_db="mashr_${tissue}"
        output_filename="${gwas_file%.txt.gz}__PM__${tissue}.csv"

        $SPREDIXCAN_PATH \
        --model_db_path $MODEL_DB_PATH/eqtl/mashr/${model_db}.db \
        --covariance $MODEL_DB_PATH/eqtl/mashr/${model_db}.txt.gz \
        --gwas_file $GWAS_FILE_PATH/$gwas_file \
        --freq_column all_meta_AF \
        --snp_column SNP \
        --effect_allele_column ALT \
        --non_effect_allele_column REF \
        --beta_column all_inv_var_meta_beta \
        --pvalue_column all_inv_var_meta_p \
        --keep_non_rsid \
        --model_db_snp_key varID \
        --output_file $OUTPUT_FILE_PATH/spredixcan/$output_filename \
        --throw
        
        echo "SPrediXcan processing completed for $gwas_file and tissue $tissue."
    done
done



