## Pops Pipeline used in Ming-Ju's Manuscript  
https://www.researchsquare.com/article/rs-3443080/v1

## Acknowledge
Many thanks to the Finucane Lab and Pops team for providing this gene prioritization method used in our post GWAS study.

## Summary
In our post GWAS study, we use Covid-19 GWAS summary data to predict the prioritization of covid19 related genes in human lung and human pbmc features. This is the code reproduction base on jupyter notebook,"pops.ipynb". All the used data, resource and reference are described below: <br>

## Environment Setup
Please download the **pops pipeline data**, **magma software** and **gene features** to the current pops folder.<br>
And arrange the feature folders according to the Tips below<br>

<h3>Download PoPS Pipeline Data</h3>
<pre><code>Please choose the gene prioritization results to download and save as data in pops.
<a href="https://www.finucanelab.org/data">Finucane Lab Data</a>
</code></pre>

<h3>Download Magma software</h3>
<pre><code>Please find the compiler and operation system that suits you, and unzip to the pops folder!
<a href="https://cncr.nl/research/magma/">CNCR CTG Lab Magma</a>
</code></pre>

<h3>Download Gene Features</h3>
<pre><code>We use human_lung and human_pbmc for COVID19 pops pipeline 
<a href="https://github.com/FinucaneLab/gene_features/tree/master/features">Finucane Lab Features</a>
</code></pre>

<div style="background-color: #ADD8E6; color: black; border-left: 5px solid black; padding: 10px;">
    <b>Tip:</b> Please refer to the pops example's data folder and arrange human_lung and human_pbmc similarly. This means you can create human_lung and humna_pmbc folders under the data folder and copy four folders (features_munged,features_raw,magma_scores, and utils) from the example data for each, replacing the files in features_raw with the download features(keep GTEx.txt). 
</div>

## hg38 reference panel
The PoPS Pipeline Data includes a reference panel of 1000G.EUR European genome data. If you want to use hg38 instead, please download the Plink 2.0 software and move its executable file "plink2.0" to the pops folder so the following script can run.
<h3>Download Plink</h3>
Please choose the operation system and version that suits you, and unzip it to the pops folder!
<pre><code>
<a href="https://www.cog-genomics.org/plink/2.0/">Christopher Chang Plink</a>
</code></pre>

<div style="background-color: pink; color: black; border-left: 5px solid black; padding: 10px;">
    <b>Tip:</b> The common system path in Mac is "/usr/local/bin/" or "~/bin/" After placing the executed file, you can use plink or plink --version to check if the installation succeeded.
</div>

## Add codes to solve a common problem before running 
The "ValueError: shapes (18383,743) and (1867) not aligned: 743 (dim 1) != 1867 (dim 0)" issue is caused by the duplicated name in the generated matrix table. A **solution provided by Vinodsri** in the GitHub issue is adding codes renaming the feature clusters in the **munge_feature_directory.py** script.

<h3>Insert the code chunk in the position and import os</h3>
<pre><code>
import os
    
for f in all_feature_files:
    f_df = pd.read_csv(f, sep="\t", index_col=0).astype(np.float64)
    f_df = gene_annot_df.merge(
        f_df, how="left", left_index=True, right_index=True)
    <span style="color: brown;"># Add the following three line codes accordingly to munge_feature_directory.py</span>
    base_filename = os.path.basename(f)
    fname = base_filename.replace(r".txt.gz", "_")
    f_df.columns = f_df.columns.str.replace(r"Cluster", fname)
    <span style="color: brown;"># -----------------------------  by vinodhsri  ------------------------------</span>
    if nan_policy == "raise":
        assert not f_df.isnull().values.any(), "Missing genes in feature matrix."
</code></pre>


## Reference
FinucaneLab. (2022). pops [Software]. GitHub. https://github.com/FinucaneLab/pops
