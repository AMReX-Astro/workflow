
******************
Linux Workstations
******************

In general GCC 7.x work well on Linux workstations.  CUDA 10.0 does
not support the GCC 8.x compilers, so you may need to install an older
GCC 7.3 compiler to get the code to compile.

The PGI community edition 18.4 and 18.10 compilers also are known to
work well.


GPU offloading
==============

bender
------

Compile as::

  make CUDA_VERSION=cc60 COMPILE_CUDA_PATH=/usr/local/cuda-10.0 \
    USE_CUDA=TRUE COMP=pgi -j 4

To run the CUDA code path without GPU launching, add::

  NO_DEVICE_LAUNCH=TRUE


groot
-----

Compile as::

  module load gcc/7.3

  make CUDA_VERSION=cc60 COMPILE_CUDA_PATH=/usr/local/cuda-10.0 \
    USE_CUDA=TRUE COMP=pgi USE_MPI=FALSE -j 4


