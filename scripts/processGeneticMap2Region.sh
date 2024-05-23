#!/bin/bash

echo 'Process Hapmap II genetic map hg38, convert chromosome numbers, and sort directly'
gunzip -c rCOGS/data/genetic_map_hg38_withX.txt.gz | awk 'BEGIN {OFS="\t"; prev_chr=""; prev_pos=0}
{
    if (NR > 1) {
        # Convert chromosome numbers to X and Y if necessary
        gsub(/^23$/, "X", $1);
        gsub(/^24$/, "Y", $1);  # Uncomment this line if "24" represents Y in your data
        # gsub(/^Y$/, "Y", $1);  # Use this if your data uses "Y" instead of "24"

        if ($1 != prev_chr) {
            if (prev_chr != "") {
                print prev_chr, prev_pos, last_pos;
            }
            prev_chr = $1;
            prev_pos = $2;
        } else {
            print prev_chr, prev_pos, $2-1;
            prev_pos = $2;
        }
    }
    last_pos = $2;
}
END {
    print prev_chr, prev_pos, last_pos;
}' | sort -k1,1 -k2,2n > rCOGS/data/regions_hg38.bed

echo 'Compress and index the sorted BED file'
bgzip -c rCOGS/data/regions_hg38.bed > rCOGS/data/regions_hg38.bed.gz
tabix -p bed rCOGS/data/regions_hg38.bed.gz

echo 'Create a formatted region file with header'
echo -e "chr\tstart\tend" > rCOGS/data/hapmap38_recomb.bed
cat rCOGS/data/regions_hg38.bed >> rCOGS/data/hapmap38_recomb.bed

rm rCOGS/data/regions_hg38.bed.gz.tbi rCOGS/data/regions_hg38.bed.gz rCOGS/data/regions_hg38.bed

echo 'Region file hapmap38_recomb.bed successfully processed'
