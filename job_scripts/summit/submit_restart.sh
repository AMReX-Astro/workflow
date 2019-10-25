#!/bin/bash
#BSUB -P ast106
#BSUB -W 2:00
#BSUB -nnodes 11
#BSUB -alloc_flags smt1
#BSUB -J castro
#BSUB -o castro.%J
#BSUB -e castro.%J

# This script searches for checkpoint files in the $outdir directory and uses those to set 
# Castro's amr.restart variable. It also outputs plotfiles and checkpoint files to this directory. 
# It is designed to be used with the chain_submit.sh script to submit a number of jobs at once that depend on 
# each other.

# Assuming you're running the code on GPUs, the things you need to set are 
# BSUB -nnodes, $n_mpi, $inputs_file and $outdir (and possibly the executable $Castro_ex).

cd $LS_SUBCWD

inputs_file=inputs_3d
outdir="."

restart=$(find . -maxdepth 1 -type d -name "${outdir}/chk???????" -print | sort | tail -1 | cut -c 3-)

if [ ! -f ${restart}/Header ]; then
  # how many *chk??????? files are there? if only one, then skip
  nl=$(find . -maxdepth 1 -type d -name "${outdir}/chk???????" -print | sort | wc -l)
  if [ $nl -gt 1 ]; then
        restart=$(find . -maxdepth 1 -type d -name "${outdir}/chk???????" -print | sort | tail -2 | head -1 | cut -c 3-)    
  else
        restart=""
  fi
fi

# if the above checks failed, then there are no valid 7-digit chk files, so
# check the 6-digit ones
if [ "${restart}" = "" ]; then
  restart=$(find . -maxdepth 1 -type d -name "${outdir}/chk??????" -print | sort | tail -1 | cut -c 3-)

  # make sure the Header was written, otherwise, check the second-to-last
  # file
  if [ ! -f ${restart}/Header ]; then
    # how many *chk?????? files are there? if only one, then skip
    nl=$(find . -maxdepth 1 -type d -name "${outdir}/chk??????" -print | sort | wc -l)
    if [ $nl -gt 1 ]; then
	    restart=$(find . -maxdepth 1 -type d -name "${outdir}/chk??????" -print | sort | tail -2 | head -1 | cut -c 3-)    
    else
	    restart=""
    fi
  fi
fi

n_mpi=66 # num nodes * 6 gpu per node
n_omp=1
n_gpu=1
n_cores=1
n_rs_per_node=6

Castro_ex=./Castro3d.pgi.MPI.CUDA.ex

jsrun -n $n_mpi -r $n_rs_per_node -c $n_cores -a 1 -g $n_gpu $Castro_ex $inputs_file amr.plot_file="${outdir}/plt" amr.check_file="${outdir}/chk" amr.restart=${restart}

