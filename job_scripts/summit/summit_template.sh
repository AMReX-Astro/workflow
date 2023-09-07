#!/bin/bash
#BSUB -P ast106
#BSUB -W 2:00
#BSUB -nnodes 80
#BSUB -alloc_flags smt1
#BSUB -J luna_script
#BSUB -o luna_output.%J
#BSUB -e luna_sniffing_output.%J
#BSUB -wa URG
#BSUB -wt 2
# last 2 options are used for graceful exit

module load gcc/10.2.0
module load cuda/11.5.2
module load python

export OMP_NUM_THREADS=1

CASTRO=./Castro2d.gnu.MPI.CUDA.ex
INPUTS=inputs_luna

n_res=480                # The max allocated number of resource sets is
n_cpu_cores_per_res=1    # nnodes * n_max_res_per_node. In this case we will
n_mpi_per_res=1          # use all the allocated resource sets to run the job below,
n_gpu_per_res=1          # however we can define more enviroment variables to allocate two jobs
n_max_res_per_node=6     # simultaneous jobs, where n_res = n_res_1 + n_res2 allocates for two jobs.

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
        # the Header is the last thing written -- if it's there, update the restart file
        if [ -f ${f}/Header ]; then
            # The scratch FS sometimes gives I/O errors when trying to read
            # from recently-created files, which crashes Castro. Avoid this by
            # making sure we can read from all the data files.
            if head --quiet -c1 "${f}/Header" "${f}"/Level_*/* >/dev/null; then
                restartFile="${f}"
            fi
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

# clean up any run management files that may be left over from previous runs
rm -f dump_and_continue dump_and_stop stop_run

warning_time=$(bjobs -noheader -o action_warning_time $LSB_JOBID)
# The `-wa URG -wt <n>` options tell bsub to send SIGURG to all processes n
# minutes before the runtime limit, so we can exit gracefully.
# SIGURG is ignored by default, so it won't make Castro crash.
function sig_handler {
    touch dump_and_stop
    # disable this signal handler
    trap - URG
    echo "BATCH: $warning_time left in allocation; telling Castro to dump a checkpoint and stop"
}
trap sig_handler URG

# execute jsrun in the background then use the builtin wait so the shell can
# handle the signal
jsrun -n$n_res -c$n_cpu_cores_per_res -a$n_mpi_per_res -g$n_gpu_per_res -r$n_max_res_per_node $CASTRO $INPUTS ${restartString} &
wait
# use jswait to wait for Castro to exit and then get the exit code
jswait 1
