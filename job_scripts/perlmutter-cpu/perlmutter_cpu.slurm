#!/bin/bash
#SBATCH --job-name=perlmutter_script
#SBATCH --account=m3018
#SBATCH --nodes=16
#SBATCH --ntasks-per-node=16
#SBATCH --cpus-per-task=16
#SBATCH --qos=regular
#SBATCH --time=02:00:00
#SBATCH --constraint=cpu

#***********************INSTRUCTIONS*******************************************************
#In order to couple each MPI process with OpenMP threads we have designed the following
#strategy:
#
# 1. First we fix one node in the --qos debug queue and fix a 2**n number of
#    --ntasks-per-node, starting with n=0.
#
# 2. Next, we compute the number --cpus-per-task=256/-ntask-per-node. This is
#    the number of virtual cores available to each MPI process on each node.
#    Each physical core is composed by two virtual cores in a (64+64) where each
#    NUMA domain will contain 64 physical cores.
#
# 3. Based on the available number of virtual cores, we obtain the compute of physical
#    cores and bind each OpenMP thread to each available physical core, using:
#    export OMP_NUM_THREADS. Also, a lower number may also be selected (in case of
#    memory shortage); however in principle we want to squeeze all the available resources
#    first.
#
# 4. Run the script and check the wall-clock-timestep. In perlmutter I use
#    grep Coarse <slurm_output>
#
# 5. Repeat the steps 1-4 until the perfect MPI/OpenMP balance is reached for the
#    choice of n.
#
# 6. Compare different amr.max_grid_size until the optimal value is reached. Usually is located
#    near half the Level 0 half_size. Furthermore, test several amr.blocking_factor sizes.
#
# 7. Finally, increase the number of nodes from 1, 2, 4, 8 and compare the
#    wall-clock time change. If the problem scales correctly, the wall-clock time will
#    go down by a factor of ~ 2, as we increase the nodes. However such scaling will break after
#    one particular bigger node choice. This is the perfect number of nodes we have to select.
#
#8. Run a chain of jobs using this script and ./chainslurm.sh

export OMP_NUM_THREADS=8
export OMP_PLACES=cores
export OMP_PROC_BIND=spread

#export MPICH_MAX_THREAD_SAFETY=multiple
export CASTRO_EXEC=./Castro2d.gnu.x86-milan.MPI.OMP.ex
export INPUTS_FILE=./inputs_nova_t7

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
if [ "${restartFile}" != "" ]; then
    restartString="amr.restart=${restartFile}"
else
    restartString=""
fi

srun -n $((SLURM_NTASKS_PER_NODE * SLURM_NNODES)) -c ${SLURM_CPUS_PER_TASK} --cpu-bind=cores  ${CASTRO_EXEC} ${INPUTS_FILE} ${restartString}
