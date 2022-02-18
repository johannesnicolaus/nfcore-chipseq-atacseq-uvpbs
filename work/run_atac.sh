#!/bin/sh

#PBS -q MEDIUM
#PBS -l select=1:ncpus=8:mem=256gb
#PBS -N JOB_NAME
#PBS -m e
#PBS -e ${PBS_O_WORKDIR}/error_log
#PBS -o ${PBS_O_WORKDIR}/output_log
#PBS -M YOUR_EMAIL@EMAIL.com

cd ${PBS_O_WORKDIR}

source $HOME/apps/anaconda3/bin/activate

# for more info on settings: https://nf-co.re/atacseq/1.2.1
nextflow run nf-core/atacseq \
    -r 1.2.1 \
    -profile singularity \
    --input samplesheet_atac.csv \
    --genome GRCh38 \
#   --single_end \
    --save_reference \
    --max_cpus 8 \
    --max_memory 256.GB
