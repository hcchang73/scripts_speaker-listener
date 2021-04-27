#!/bin/bash
#SBATCH -J 'matlab_job'
#SBATCH -o slurm-%j.out
#SBATCH -p all
#SBATCH -t 3:00:00
#SBATCH -c 3
#SBATCH --array=2-4
#SBATCH --mem-per-cpu=500M
#SBATCH --mail-type=END
#SBATCH --mail-user=hcchang73@gmail.com

module load matlab

expdir="/mnt/sink/scratch/claire/speaker-listener/"

# fs=`ls $expdir/$exp/fmri/timeseries/tr/roi/mor/zscore_listenerAll_*.mat`

perm=$SLURM_ARRAY_TASK_ID
declare -i perm


matlab -nodisplay -r "simulation_pallier($perm)"












