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

srun -n 8 -c 8 --ntasks-per-node=8 --gpus-per-task=1 --gpu-bind=closest ./$EXEC $INPUTS amr.plot_files_output=0 amr.checkpoint_files_output=0

