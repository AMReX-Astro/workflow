#!/bin/bash
#SBATCH -A AST136_crusher
#SBATCH -J testing
#SBATCH -o %x-%j.out
#SBATCH -t 00:05:00
#SBATCH -p batch
#SBATCH -N 1

# here N is the number of compute nodes

EXEC=Castro2d.hip.x86-trento.MPI.HIP.ex
INPUTS=inputs_2d.testsuite

srun -n 1 -c 2 --ntasks-per-node=1 rocprof $EXEC $INPUTS amr.plot_files_output=0 amr.checkpoint_files_output=0

