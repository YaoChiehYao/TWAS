#!/usr/bin/env bash

mkdir -p results/ppi 

################################################
lung_output="results/smultixcan/metaxcan_lung_results.tsv"
blood_output="results/smultixcan/metaxcan_whole_blood_results.tsv"

header=$(head -n 1 results/smultixcan/COVID19_HGI_A1_ALL_20201020_smultixcan.csv)
echo "$header" > "$lung_output"
echo "$header" > "$blood_output"

temp_file_lung=$(mktemp)
temp_file_blood=$(mktemp)

for file in results/smultixcan/COVID19_HGI_A1_ALL_20201020_smultixcan.csv \
            results/smultixcan/COVID19_HGI_A2_ALL_leave_23andme_20201020_smultixcan.csv \
            results/smultixcan/COVID19_HGI_B1_ALL_20201020_smultixcan.csv \
            results/smultixcan/COVID19_HGI_B2_ALL_leave_23andme_20201020_smultixcan.csv \
            results/smultixcan/COVID19_HGI_C1_ALL_leave_23andme_20201020_smultixcan.csv \
            results/smultixcan/COVID19_HGI_C2_ALL_leave_23andme_20201020_smultixcan.csv \
            results/smultixcan/COVID19_HGI_D1_ALL_20201020_smultixcan.csv
do
    awk -F'\t' 'NR==1 || ($3 < 0.05 && $6 < 0.05 && $7 == "Lung") || ($3 < 0.05 && $6 < 0.05 && $7 == "Whole_Blood") || ($3 < 0.05 && $8 < 0.05 && $9 == "Lung") || ($3 < 0.05 && $8 < 0.05 && $9 == "Whole_Blood")' "$file" | \
    awk -F'\t' 'NR==1 {next} {if ($7 == "Lung" || $9 == "Lung") print > "'$temp_file_lung'"; else if ($7 == "Whole_Blood" || $9 == "Whole_Blood") print > "'$temp_file_blood'"}'
done

awk -F'\t' '!seen[$1","$2]++' "$temp_file_lung" | sort -u >> "$lung_output"
awk -F'\t' '!seen[$1","$2]++' "$temp_file_blood" | sort -u >> "$blood_output"

rm "$temp_file_lung" "$temp_file_blood"

echo "Metaxcan filtered by tissue-associated and aggregated p-value."

################################################
pbmc_preds_path="results/pops/pbmc-COVID19.preds"
lung_preds_path="results/pops/lung-COVID19.preds"

output_path_pbmc="results/pops/pops_pbmc_results.tsv"
output_path_lung="results/pops/pops_lung_results.tsv"

filtered_file_pbmc=$(mktemp)
filtered_file_lung=$(mktemp)
sorted_file_pbmc=$(mktemp)
sorted_file_lung=$(mktemp)

calculate_95th_percentile() {
    local file=$1
    total_lines=$(wc -l < "$file")
    top_5_percent_index=$((total_lines / 20))
    awk -F'\t' 'NR > 1 {print $2}' "$file" | sort -nr | awk -v idx="$top_5_percent_index" 'NR == idx'
}

pops_score_95th_pbmc=$(calculate_95th_percentile "$pbmc_preds_path")
echo "Filtered by 95th percentile of PoPS score threshold for PBMC is $pops_score_95th_pbmc"

awk -F'\t' -v pops_thresh="$pops_score_95th_pbmc" 'NR==1 || ($2 >= pops_thresh && $1 != "")' "$pbmc_preds_path" > "$filtered_file_pbmc"
awk -F'\t' '!seen[$1]++' "$filtered_file_pbmc" > "$sorted_file_pbmc"
(head -n 1 "$sorted_file_pbmc" && tail -n +2 "$sorted_file_pbmc" | sort -k2,2nr) > "$output_path_pbmc"

pops_score_95th_lung=$(calculate_95th_percentile "$lung_preds_path")
echo "Filtered by 95th percentile PoPS score threshold for Lung is $pops_score_95th_lung"

awk -F'\t' -v pops_thresh="$pops_score_95th_lung" 'NR==1 || ($2 >= pops_thresh && $1 != "")' "$lung_preds_path" > "$filtered_file_lung"
awk -F'\t' '!seen[$1]++' "$filtered_file_lung" > "$sorted_file_lung"
(head -n 1 "$sorted_file_lung" && tail -n +2 "$sorted_file_lung" | sort -k2,2nr) > "$output_path_lung"

rm "$filtered_file_pbmc" "$filtered_file_lung" "$sorted_file_pbmc" "$sorted_file_lung"

echo "Gene prioritization filtered successfully."