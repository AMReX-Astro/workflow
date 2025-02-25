#!/bin/bash
#SBATCH -A AST106
#SBATCH -J subch
#SBATCH -o %x-%j.out
#SBATCH -t 02:00:00
#SBATCH -p batch
# here N is the number of compute nodes
#SBATCH -N 4
#SBATCH --ntasks-per-node=8
#SBATCH --cpus-per-task=7
#SBATCH --gpus-per-task=1
#SBATCH --gpu-bind=closest

EXEC=./Castro2d.hip.x86-trento.MPI.HIP.SMPLSDC.ex
INPUTS=inputs_2d.N14.coarse

module load cpe
module load PrgEnv-gnu
module load cray-mpich
module load craype-accel-amd-gfx90a
module load rocm/6.3.1

export LD_LIBRARY_PATH=$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH

# set the file system striping

echo $SLURM_SUBMIT_DIR

module load lfs-wrapper
lfs setstripe -c 32 -S 10M $SLURM_SUBMIT_DIR

module list

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

export OMP_NUM_THREADS=1
export NMPI_PER_NODE=8
export TOTAL_NMPI=$(( ${SLURM_JOB_NUM_NODES} * ${NMPI_PER_NODE} ))

# frontier's file system is troublesome, so modify the way
# we have AMReX does I/O

FILE_IO_PARAMS="
amr.plot_nfiles = -1
amr.checkpoint_nfiles = -1
amrex.async_out_nfiles = ${TOTAL_NMPI}
"

echo appending parameters: ${FILE_IO_PARAMS}

srun -n${TOTAL_NMPI} -N${SLURM_JOB_NUM_NODES} --ntasks-per-node=8 --gpus-per-task=1 ./$EXEC $INPUTS ${restartString} ${FILE_IO_PARAMS}

