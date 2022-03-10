#!/bin/sh

#PBS -q MEDIUM
#PBS -l select=1:ncpus=8:mem=256gb
#PBS -N JOB_NAME
#PBS -m e
#PBS -e ${PBS_O_WORKDIR}/error_log
#PBS -o ${PBS_O_WORKDIR}/output_log
#PBS -M YOUR_EMAIL@EMAIL.com

cd ${PBS_O_WORKDIR}

#source $HOME/apps/anaconda3/bin/activate

# for more info on settings: https://nf-co.re/chipseq/1.2.2
nextflow run nf-core/chipseq \
    -r 1.2.2 \
    -profile singularity \
    --input samplesheet_chip.csv \
    --genome GRCh38 \
#   --single_end \
    --save_reference \
    --max_cpus 8 \
    --max_memory 256.GB
