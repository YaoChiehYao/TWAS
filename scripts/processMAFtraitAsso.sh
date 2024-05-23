#!/bin/bash

directory_path="rCOGS/data/COVID19_HGI_20201020_ABF/results/"

fine_mapping_files=(
    "COVID19_HGI_A2_ALL_leave_23andme_20201020.ABF.snp.bgz"
    "COVID19_HGI_B1_ALL_20201020.ABF.snp.bgz"
    "COVID19_HGI_B2_ALL_leave_23andme_20201020.ABF.snp.bgz"
    "COVID19_HGI_C1_ALL_leave_23andme_20201020.ABF.snp.bgz"
    "COVID19_HGI_C2_ALL_leave_23andme_20201020.ABF.snp.bgz"
    "COVID19_HGI_D1_ALL_20201020.ABF.snp.bgz"
)

maf_file="rCOGS/data/referenced_maf.tsv"
trait_file="rCOGS/data/trait_association.tsv"

# Initialize output files with headers
echo -e "chr\tpos\tmaf" > "$maf_file"
echo -e "chr\tpos\tp" > "$trait_file"


# Download and process each file
for file in "${fine_mapping_files[@]}"; do
  echo "Processing $file..."
  filepath="${directory_path}${file}"
    # Process MAF and Trait file
    gunzip -c "$filepath" | awk -F'\t' 'BEGIN {OFS="\t"}
        NR > 1 && $17 == 1 {
            chr = $5;
            gsub(/^chr/, "", chr);
            if (chr == "23") chr = "X";
            pos = $6;
            maf = $9 <= 0.5 ? $9 : 1 - $9;
            p = $12;
            if (maf != "NA") {
                print chr, pos, maf >> "'$maf_file'"
            }
            if (p != "NA") {
                print chr, pos, p >> "'$trait_file'"
            }
        }'

done

echo "${maf_file} and ${trait_file} successfully processed."

