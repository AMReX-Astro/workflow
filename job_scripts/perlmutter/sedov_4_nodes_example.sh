#!/bin/bash

#SBATCH -A m3018_g
#SBATCH -C gpu
#SBATCH -J Castro
#SBATCH -o sedov_%j.out
#SBATCH -t 10
#SBATCH -N 4
#SBATCH --ntasks-per-node=4
#SBATCH --gpus-per-task=1
#SBATCH --gpu-bind=map_gpu:0,1,2,3

srun -n 16 ./Castro3d.gnu.TPROF.MPI.CUDA.ex inputs.3d.sph.testsuite amr.n_cell=256 256 256 amr.plot_files_output=0 amr.checkpoint_files_output=0 amr.max_grid_size=128 max_step=100
