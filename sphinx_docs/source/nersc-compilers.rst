.. highlight:: bash

Compiling at NERSC
==================


Perlmutter
----------

Log into Perlmutter via

.. prompt:: bash

   ssh perlmutter-p1.nersc.gov


Compiling with GCC + CUDA
^^^^^^^^^^^^^^^^^^^^^^^^^

Load gcc and CUDA

.. prompt:: bash

   module load PrgEnv-gnu
   module load cudatoolkit
   module load python


.. note::

   We require python >= 3.7 for the compilation process

Build, e.g. the Castro Sedov hydro test problem

.. prompt:: bash

   make -j COMP=gnu TINY_PROFILE=TRUE USE_MPI=TRUE USE_OMP=FALSE USE_CUDA=TRUE -j 4

Hypre
^^^^^

Hypre should be obtained from GitHub, and built using the same PrgEnv that you are using for Castro:

.. prompt:: bash

   HYPRE_CUDA_SM=80 CXX=CC CC=cc FC=ftn ./configure --prefix=/path/to/hypre/install --with-MPI --with-cuda --enable-unified-memory

