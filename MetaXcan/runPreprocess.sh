#!/bin/bash

#module load miniconda3/23.11.0
#source activate

# Clone repo if it doesn't already exist
if [ ! -d "MetaXcan" ]; then
 git clone https://github.com/hakyimlab/MetaXcan
fi
cd MetaXcan/software

# Environment setting
if [ ! -d "envs/imlabtools" ]; then  # Check if environment already exists
 conda env create -f conda_env.yaml
fi
conda activate imlabtools


cd MetaXcan/software

dir="data_covid"
mkdir -p "$dir"
cd "$dir"

urls=(
"https://storage.googleapis.com/covid19-hg-public/20200915/results/20201020/COVID19_HGI_A1_ALL_20201020.txt.gz"
"https://storage.googleapis.com/covid19-hg-public/20200915/results/20201020/COVID19_HGI_A2_ALL_leave_23andme_20201020.txt.gz"
"https://storage.googleapis.com/covid19-hg-public/20200915/results/20201020/COVID19_HGI_B1_ALL_20201020.txt.gz"
"https://storage.googleapis.com/covid19-hg-public/20200915/results/20201020/COVID19_HGI_B2_ALL_leave_23andme_20201020.txt.gz"
"https://storage.googleapis.com/covid19-hg-public/20200915/results/20201020/COVID19_HGI_C1_ALL_leave_23andme_20201020.txt.gz"
"https://storage.googleapis.com/covid19-hg-public/20200915/results/20201020/COVID19_HGI_C2_ALL_leave_23andme_20201020.txt.gz"
"https://storage.googleapis.com/covid19-hg-public/20200915/results/20201020/COVID19_HGI_D1_ALL_20201020.txt.gz"
)

for url in "${urls[@]}"; do
  filename=$(basename "$url")

  if [ -f "$filename" ]; then
    echo "File $filename already exists. Checking if processing is needed..."
    echo "Skipping processing of $filename."
    continue
  else
    echo "File $filename does not exist. Downloading..."
    if curl -O "$url"; then
      echo "Downloaded $filename successfully."
    else
      echo "Failed to download $filename."
      continue # Skip this file if download fails
    fi
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
