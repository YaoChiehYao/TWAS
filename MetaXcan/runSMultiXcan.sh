#!/bin/bash
MODEL_DB_PATH="MetaXcan/software/predi_models"
GWAS_FILE_PATH="MetaXcan/software/data_covid"
OUTPUT_FILE_PATH="MetaXcan/software/output"
META_SOFTWARE_PATH="MetaXcan/software"

gwas_files=(
  "COVID19_HGI_A1_ALL_20201020.txt.gz"
  "COVID19_HGI_A2_ALL_leave_23andme_20201020.txt.gz"
  "COVID19_HGI_B1_ALL_20201020.txt.gz"
  "COVID19_HGI_B2_ALL_leave_23andme_20201020.txt.gz"
  "COVID19_HGI_C1_ALL_leave_23andme_20201020.txt.gz"
  "COVID19_HGI_C2_ALL_leave_23andme_20201020.txt.gz"
  "COVID19_HGI_D1_ALL_20201020.txt.gz"
)

mkdir -p "$OUTPUT_FILE_PATH/smultixcan"

for gwas_file in "${gwas_files[@]}"; do
    gwas_basename=$(basename "$gwas_file" .txt.gz)

    echo "Running SMultiXcan for $gwas_basename..."

    python $META_SOFTWARE_PATH/SMulTiXcan.py \
    --models_folder "$MODEL_DB_PATH/eqtl/mashr" \
    --models_name_pattern "mashr_(.*).db" \
    --snp_covariance "$MODEL_DB_PATH/gtex_v8_expression_mashr_snp_smultixcan_covariance.txt.gz" \
    --metaxcan_folder "$OUTPUT_FILE_PATH/spredixcan" \
    --metaxcan_filter "${gwas_basename}__PM__(.*).csv" \
    --metaxcan_file_name_parse_pattern "(.*)__PM__(.*).csv" \
    --gwas_file "$GWAS_FILE_PATH/$gwas_file" \
    --snp_column SNP \
    --effect_allele_column ALT \
    --non_effect_allele_column REF \
    --beta_column all_inv_var_meta_beta \
    --se_column all_inv_var_meta_sebeta \
    --pvalue_column all_inv_var_meta_p \
    --model_db_snp_key varID \
    --cutoff_condition_number 30 \
    --verbosity 7 \
    --output "$OUTPUT_FILE_PATH/smultixcan/${gwas_basename}_smultixcan.csv" \
    --keep_non_rsid \
    --throw

    echo "SMultiXcan processing completed for $gwas_basename."
done
