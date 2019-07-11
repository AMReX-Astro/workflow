#!/bin/bash
#BSUB -P [projid]
#BSUB -W 8
#BSUB -nnodes 1
#BSUB -J 128_test
#BSUB -o 128_test.%J
#BSUB -e 128_test.%J

#Use modules which match your code
module load pgi/19.4
module load cuda/10.1.105
module list

set -x


#MPI + CUDA
omp=1
export OMP_NUM_THREADS=${omp}
EXE="./Nyx3d.pgi.TPROF.MPI.CUDA.ex"
JSRUN="jsrun -n 1 -a 1 -g 1 -c 7 --bind=packed:${omp}"
INPUTS=inputs.256-128

#jsrun --smpiargs="-x PAMI_DISABLE_CUDA_HOOK=1 -disable_gpu_hooks" -n 6 -a 1 -c 7 -g 1 -r 6 -l CPU-CPU -d packed -b rs ./profile.sh ${EXE} ${INPUTS} &> out.${LSB_JOBID}.${PMIX_NAMESPACE}

${JSRUN} --smpiargs="-x PAMI_DISABLE_CUDA_HOOK=1 -disable_gpu_hooks" ${EXE} ${INPUTS} &> out.mpi.cuda.${LSB_JOBID}

#MPI + CUDA (nvprof)
omp=1
export OMP_NUM_THREADS=${omp}
EXE="./Nyx3d.pgi.TPROF.MPI.CUDA.ex"
JSRUN="jsrun -n 1 -a 1 -g 1 -c 7 --bind=packed:${omp}"
INPUTS=inputs.256-128

#jsrun --smpiargs="-x PAMI_DISABLE_CUDA_HOOK=1 -disable_gpu_hooks" -n 6 -a 1 -c 7 -g 1 -r 6 -l CPU-CPU -d packed -b rs ./profile.sh ${EXE} ${INPUTS} &> out.${LSB_JOBID}.${PMIX_NAMESPACE}

${JSRUN} --smpiargs="-x PAMI_DISABLE_CUDA_HOOK=1 -disable_gpu_hooks" ./profile.sh ${EXE} ${INPUTS} &> out.mpi.cuda.nvprof.${LSB_JOBID}

#MPI + OMP
omp=7
export OMP_NUM_THREADS=${omp}
EXE="./Nyx3d.pgi.TPROF.MPI.OMP.ex"
JSRUN="jsrun -n 1 -a 1 -g 1 -c ${omp} --bind=packed:${omp}"
INPUTS=inputs.256-128

#jsrun --smpiargs="-x PAMI_DISABLE_CUDA_HOOK=1 -disable_gpu_hooks" -n 6 -a 1 -c 7 -g 1 -r 6 -l CPU-CPU -d packed -b rs ./profile.sh ${EXE} ${INPUTS} &> out.${LSB_JOBID}.${PMIX_NAMESPACE}

${JSRUN} --smpiargs="-x PAMI_DISABLE_CUDA_HOOK=1 -disable_gpu_hooks" ${EXE} ${INPUTS} &> out.mpi.omp.${LSB_JOBID}
