#!/bin/bash

# clone repo
git clone https://github.com/hakyimlab/MetaXcan
cd MetaXcan/software

# Env setting
conda env create -f conda_env.yaml
conda activate imlabtools

dir="data_covid"
mkdir -p "$dir"
cd "$dir"

# Covid19 GWAS Summaries download 
urls=(
"https://storage.googleapis.com/covid19-hg-public/20200915/results/20201020/COVID19_HGI_A1_ALL_20201020.txt.gz"
"https://storage.googleapis.com/covid19-hg-public/20200915/results/20201020/COVID19_HGI_A2_ALL_leave_23andme_20201020.txt.gz"
"https://storage.googleapis.com/covid19-hg-public/20200915/results/20201020/COVID19_HGI_B1_ALL_20201020.txt.gz"
"https://storage.googleapis.com/covid19-hg-public/20200915/results/20201020/COVID19_HGI_B2_ALL_leave_23andme_20201020.txt.gz"
"https://storage.googleapis.com/covid19-hg-public/20200915/results/20201020/COVID19_HGI_C1_ALL_leave_23andme_20201020.txt.gz"
"https://storage.googleapis.com/covid19-hg-public/20200915/results/20201020/COVID19_HGI_C2_ALL_leave_23andme_20201020.txt.gz"
"https://storage.googleapis.com/covid19-hg-public/20200915/results/20201020/COVID19_HGI_D1_ALL_20201020.txt.gz"
)

# Preprocess SNP to macth predi models
for url in "${urls[@]}"; do
  filename=$(basename "$url")

  if [ ! -f "$filename" ]; then
    echo "File $filename does not exist. Downloading..."
    if curl -O "$url"; then
      echo "Downloaded $filename successfully."
    else
      echo "Failed to download $filename."
      continue 
    fi
  else
    echo "File $filename already exists. Skipping download."
  fi

  temp_file="${filename%.gz}"
  final_file="${filename%.txt.gz}.txt"

  echo "Processing $filename"

  gunzip -c "$filename" | awk 'BEGIN{FS=OFS="\t"}
      NR==1{print; next} # Print the header as-is and skip to the next record
      {
        split($5, a, ":"); # Assume SNP information is in the 5th column
        $5 = "chr"a[1]"_"a[2]"_"a[3]"_"a[4]"_b38"; # Reformat and assign back to $5
        print # Print the modified line
      }' > "$temp_file" 

  if [ -s "$temp_file" ]; then
    gzip -c "$temp_file" > "$filename" 
    rm "$temp_file" 
    echo "Processing completed for $filename."
  else
    echo "Failed to process $filename. Temporary file is empty."
  fi

done

cd ..

# PrediDB MASHR-based models download
mkdir -p predi_models && cd predi_models

urls=(
https://zenodo.org/record/3518299/files/mashr_eqtl.tar
https://zenodo.org/record/3518299/files/gtex_v8_expression_mashr_snp_smultixcan_covariance.txt.gz
)

for url in "${urls[@]}"; do
  curl -LO "$url"
done

tar -xvf mashr_eqtl.tar

cd ..

# Run SPrediXcan
MODEL_DB_PATH="/home/yao.yao-/MetaXcan/software/predi_models"
GWAS_FILE_PATH="/home/yao.yao-/MetaXcan/software/data_covid"
OUTPUT_FILE_PATH="/home/yao.yao-/MetaXcan/software/output"


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
    if [ ! -f "$GWAS_FILE_PATH/$gwas_file" ]; then
        echo "GWAS file $gwas_file not found."
        continue
    fi

    for tissue in "${tissues[@]}"; do
        echo "Running SPrediXcan for $tissue with $gwas_file..."

        model_db="mashr_${tissue}"
        output_filename="${gwas_file%.txt.gz}__PM__${tissue}.csv"

        ./SPrediXcan.py \
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

# Run SMultiXcan
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
