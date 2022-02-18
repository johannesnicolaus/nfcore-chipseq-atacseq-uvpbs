# nfcore-chipseq-atacseq-uvpbs
nf-core ATAC-seq and ChIP-seq pipeline template for IPR UV-PBS

Written by Johannes Nicolaus Wibisana for the Laboratory for Cell Systems IPR

This template repository can be used for the analysis of bulk ATAC-seq and ChIP-seq data, including steps from QC, trimming, alignment using BWA, peak calling using MACS2, up to differential peaks analysis.

More info of the pipeline is available on: <br>
- ChIP-seq: https://nf-co.re/chipseq/1.2.2
- ATAC-seq: https://nf-co.re/atacseq/1.2.1


# Prerequisites
Nextflow must be installed, preferably using conda:
```shell
$ conda install nextflow
```

To install miniconda:
https://docs.conda.io/en/latest/miniconda.html

To download this repository to your local directory:
```shell
$ git clone https://github.com/johannesnicolaus/nfcore-chipseq-atacseq-uvpbs.git
```

# Usage

## Preparing your data for analysis
- Place all the `fastq.gz` files inside the `raw_data` directory.

### ATAC-seq
Please refer to https://nf-co.re/atacseq/1.2.1/usage for more details.

- Edit `samplesheet_atac.csv` within the `work` directory to include the following information at each column:
   1. `group`: The experimental condition (e.g. control, treatment)
   2. `replicate`: Integer representing replicate number (e.g. 1, 2, 3)
   3. `fastq_1`: Read 1 (R1) containing gzipped fastq file
   4. `fastq_2`: Read 2 (R2) containing gzipped fastq file, leave blank if single-end read only

### ChIP-seq
Please refer to https://nf-co.re/atacseq/1.2.1/usage for more details. All files must be specified by its absolute path.

ChIP-seq requires an input sample. For ChIP-seq experiments without input samples, while it is not recommended you can use the ATAC-seq pipeline, setting the parameters: `--mito_name false --skip_merge_replicates` (Credit to hpatel @ the nf-core slack #chipseq channel).

- Edit `samplesheet_chip.csv` within the `work` directory to include the following information at each column:
   1. `group`: The experimental condition (e.g. control, treatment)
   2. `replicate`: Integer representing replicate number (e.g. 1, 2, 3)
   3. `fastq_1`: Read 1 (R1) containing fastq file
   4. `fastq_2`: Read 2 (R2) containing fastq file, leave blank if single-end read only
   5. `antibody`: Antibody name for consensus peak merging and differential analysis, leave blank for input
   6. `control`: Input data, should have the same identifier with `group`

## Running the pipeline
To run the pipeline, navigate to the `work` directory and execute the following:

ATAC-seq pipeline:
```shell
$ qsub run_atac.sh
```

ChIP-seq pipeline:
```shell
$ qsub run_atac.sh
```

To check progress:
```shell
$ qstat
```

# Description of parameters

## UV-PBS server parameters used in script

- `#PBS -q MEDIUM` <br>
Specifies the queue where the job is run: <br>
  - LARGE: 64 threads max
  - MEDIUM: 8 threads max
  - SMALL: 1 thread max

- `#PBS -l select=1:ncpus=8:mem=256gb` <br>
Specifies the number of node (1), the number of CPUs (8) which is restricted by the type of queue used and the memory allocated for the job (256gb)

- `#PBS -N JOB_NAME`<br>
Specifies the name of the job.

- `#PBS -m e` <br>
Sends email when job is terminated.

- `#PBS -e ${PBS_O_WORKDIR}` `#PBS -o ${PBS_O_WORKDIR}`<br>
Sets the error and output log directory as the same directory as the `run.sh` script.

- `#PBS -M YOUR_EMAIL@EMAIL.com` <br>
Email for which the job status is sent to.

## Default parameters in the template script
As most parameters are the same for both ChIP-seq and ATAC-seq, this section is combined for both.

For detailed usage and parameters, please visit:
ATAC-seq: https://nf-co.re/atacseq/1.2.1/parameters
ChIP-seq: https://nf-co.re/chipseq/1.2.2/parameters


- `-r x.x.x`<br>
Specifies the version of the nf-core pipeline to ensure reproducibility, it is set to the newest (as of to 2022/2/17): `1.2.1` for ATAC-seq and `1.2.2` for ChIP-seq.

- `-profile singularity`<br>
Specifies where the software required for the pipeline are downloaded from. As UV-PBS supports singularity, we will be using singularity.

- `--input samplesheet_xxxx.csv`<br>
Specifies the sample sheet containing sample info. Templates are as follows:
   - ATAC-seq: `samplesheet_atac.csv`
   - ChIP-seq: `samplesheet_chip.csv`

- `--genome GRCh38`<br>
Uses the default GRCh38 from AWS igenomes. Use GRCm38 for mouse. The genome keys are available here:
https://support.illumina.com/sequencing/sequencing_software/igenome.html

-  `--single_end`<br>
Delete or comment (using `#`) this line if the data is paired-end.

- `--save_reference`<br>
Option to save the indexed BWA reference files within the results directory.

- `--max_cpus 8`<br>
Uses max CPU of 8, this depends on the queue where the job is run.

- `--max_memory 256.GB`<br>
Uses max memory of 256 GB, this also depends on the parameters set on the `#PBS` headers.

### Other additional optional parameters
- `--narrow_peak`<br>
Run MACS2 in narrow peak mode, this can be useful for transcription factor ChIP-seq analysis.

## Results
Results will be available in the `results` directory, in which the quality check results are within the multiqc directory and the quantified transcripts are within the `bwa/mergedLibrary/macs/broadPeak` and the `bwa/mergedReplicate/macs/broadPeak` directory. Files for visualization include bigwig files which is within the `bwa/mergedLibrary/bigwig` and the `bwa/mergedReplicate/bigwig` directories as well as the IGV seesion inside the `igv` directory.

Additionally, indexed reference file will be available in the `results` directory.

Detailed information on the output is available on:
- ATAC-seq: https://nf-co.re/atacseq/1.2.1/output
- ChIP-seq: https://nf-co.re/chipseq/1.2.2/output

# Notes
## Specifying previously built index file
Use the parameter `--bwa_index` and specify the STAR reference directory (should be in results directory after the first run).

## To resume job 
If somehow the job was aborted due to errors or any other problem, it is possible to continue from the last succesful checkpoint by addint the following parameter: <br>
`-resume`

## Specifying cache for singularity images
To prevent nf-core from downloading singularity containers on every run, add the following line to `~/.bash_profile`:

```shell
 export NXF_SINGULARITY_CACHEDIR="/user1/tanpaku/okada/YOUR_USERNAME/SINGULARITY_DIRECTORY"   
```

Where `SINGULARITY_DIRECTORY` is the directory where the images are stored.

For further questions contact Nico at: <br>
nico@protein.osaka-u.ac.jp <br>
johannes.nicolaus@gmail.com
