#!/bin/bash
#SBATCH --qos=xfer
#SBATCH -J xrb-hpss-xfer
#SBATCH -t 12:00:00
#SBATCH --licenses=SCRATCH

# do our archiving
cd "$SLURM_SUBMIT_DIR" || exit

# use srun so any control signals get sent to the child too
srun ./process.xrb
