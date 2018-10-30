
******************
Linux Workstations
******************

In general GCC 7.x or 8.x work well on Linux workstations.  The PGI
community edition 18.4 compilers also are known to work well.


GPU offloading
==============

Compile as::

  make CUDA_VERSION=cc60 COMPILE_CUDA_PATH=/usr/local/cuda-9.2 \
    USE_CUDA=TRUE COMP=PGI -j 4

To run the CUDA code path without GPU launching, do::

  make -j4 COMP=PGI USE_CUDA=TRUE USE_MPI=FALSE DEBUG=TRUE \
    NO_DEVICE_LAUNCH=TRUE CUDA_VERSION=cc

