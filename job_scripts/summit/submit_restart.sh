#!/bin/bash
#BSUB -P ast106
#BSUB -W 2:00
#BSUB -nnodes 11
#BSUB -alloc_flags smt1
#BSUB -J castro
#BSUB -o castro.%J
#BSUB -e castro.%J

# This script searches for checkpoint files in the submission directory
# and uses those to set Castro's amr.restart variable. It also outputs
# plotfiles and checkpoint files to this directory.  It is designed to
# be used with the chain_submit.sh script to submit a number of jobs
# at once that depend on each other.

# Assuming you're running the code on GPUs, the things you need to set are
# BSUB -nnodes, $n_mpi, $inputs_file and $outdir (and possibly the executable $CASTRO).

cd $LS_SUBCWD

# update these to reflect the versions you compiled with

module load gcc/10.2.0
module load cuda/11.2.0

CASTRO=./Castro3d.pgi.MPI.CUDA.ex
INPUTS=inputs_3d

# num nodes * 6 gpu per node
n_mpi=66
n_omp=1
n_gpu=1
n_cores=1
n_rs_per_node=6


function find_chk_file {
    # find_chk_file takes a single argument -- the wildcard pattern
    # for checkpoint files to look through
    chk=$1

    # find the latest 2 restart files.  This way if the latest didn't
    # complete we fall back to the previous one.
    temp_files=$(find . -maxdepth 1 -name "${chk}" -print | sort | tail -2)
    restartFile=""
    for f in ${temp_files}
    do
        # the Header is the last thing written -- check if it's there, otherwise,
        # fall back to the second-to-last check file written
        if [ ! -f ${f}/Header ]; then
            restartFile=""
        else
            restartFile="${f}"
        fi
    done

}

# look for 7-digit chk files
find_chk_file "*chk???????"

if [ "${restartFile}" = "" ]; then
    # look for 6-digit chk files
    find_chk_file "*chk??????"
fi

if [ "${restartFile}" = "" ]; then
    # look for 5-digit chk files
    find_chk_file "*chk?????"
fi

# restartString will be empty if no chk files are found -- i.e. new run
if [ "${restartFile}" = "" ]; then
    restartString=""
else
    restartString="amr.restart=${restartFile}"
fi


export OMP_NUM_THREADS=$n_omp

jsrun -n $n_mpi -r $n_rs_per_node -c $n_cores -a 1 -g $n_gpu $CASTRO $INPUTS ${restartString}
