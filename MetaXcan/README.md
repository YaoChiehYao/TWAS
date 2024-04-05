## MetaXcan Pipeline used in Ming-Ju's Manuscript  
https://www.researchsquare.com/article/rs-3443080/v1

## Acknowledge
Many thanks to the MetaXcan team for providing such a fantastic tool for TWAS analysis. 

## Summary
In our TWAS study, we provide two ways to conduct the MetaXcan pipeline using Covid-19 GWAS summary data. <br>
1. Bash Script - batchMetaXcanAll.sh <br>
2. Jupyter notebook - MetaXcan.ipynb <br> 

## Environment Setup
Please ensure the **MetaXcan repo** and **"imlabtools" env** are installed through the **terminal** before starting.<br>
Or open your terminal and install using the following commands:<br>

<h3>Clone the MetaXcan repo</h3>
<pre><code>git clone https://github.com/hakyimlab/MetaXcan
</code></pre>

<h3>Change directory</h3>
<pre><code>cd MetaXcan/software
</code></pre>

<h3>Install imlabtools Conda Environment and Load</h3>
<pre><code>conda activate base
conda env create -f /path/to/this/repo/software/conda_env.yaml
conda activate imlabtools
</code></pre>

If you are using Jupyter notebook, please continue and ensure the **ipykernel** and **notebook** existed, and install the **imlabtools** environment to the ipykernel via the following commands in **terminal**:<br>

<h3>Install conda env to juypter notebook kernal</h3>
<pre><code>
!pip install notebook
!pip install ipykernel
!python -m ipykernel install --user --name=imlabtools</code></pre>


## Reference
Hakyim's Lab. (2023). MetaXcan [Software]. GitHub. https://github.com/hakyimlab/MetaXcan

