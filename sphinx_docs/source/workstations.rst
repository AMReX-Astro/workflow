
******************
Linux Workstations
******************

In general GCC 10.x works well on Linux workstations.


GPU offloading
==============

We use the GNU compilers to build with nvcc and CUDA.

bender
------

Compile as::

  module load gcc/7.3

  make CUDA_VERSION=cc60 COMPILE_CUDA_PATH=/usr/local/cuda-11.3 \
    USE_CUDA=TRUE COMP=gnu -j 4

To run the CUDA code path without GPU launching, add::

  NO_DEVICE_LAUNCH=TRUE


groot
-----

We need to work around a bug in the headers in the default GCC 10.2 on groot,
so we load an older version for the GPU build.

Compile as::

  module load gcc/7.3

  make CUDA_VERSION=cc70 COMPILE_CUDA_PATH=/usr/local/cuda-11.3 \
    USE_CUDA=TRUE COMP=gnu USE_MPI=FALSE -j 4



Remote vis with Jupyter
=======================

You can connect to Jupyter on groot to do remote visualization.

On groot, do::

   jupyter lab --no-browser --ip="groot"

on your workstation do::

   ssh -N -L localhost:8888:groot:8888 groot.astro.sunysb.edu

and enter your password.  There will be no output---that command will just continue
to run in the terminal window.

Point your web browser to http://localhost:8888 .
You will be prompted to add the token that appears in the groot window.
