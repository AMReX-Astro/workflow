.. highlight:: bash

Compiling at NERSC
==================


Cori Haswell
------------

.. note::

   You need to set::

      export MPICH_MAX_THREAD_SAFETY=multiple


Intel
^^^^^

Intel is the default programming environment on Cori and appear to
be the preferred compilers.


GNU
^^^

You need to swap environments:

.. prompt:: bash

   module swap PrgEnv-{intel,gnu}

There are no known issues with GNU.

Hypre
^^^^^

These notes are from Edison.  Need to be confirmed on Cori Haswell.

On Edison, the Cray *Third Party Scientific Libraries* provide Hypre
in a form that works directly with the compiler wrappers used on that
machine (``CC``, ``ftn``, ...).  To use this, simply do:

.. prompt:: bash

   module load cray-tpsl

There is no need to set ``HYPRE_DIR``, but note however that the
dependency checker script (``BoxLib/Tools/C_scripts/mkdep``) will
complain about::

  /path/to/Hypre--with-openmp/include does not exist

This can be ignored an compilation will finish.  If you do wish to
silence it, you can set ``HYPRE_DIR`` to the path shown by:

.. prompt:: bash

   module show cray-tpsl

as:

.. prompt:: bash

   export HYPRE_DIR=${CRAY_TPSL_PREFIX_DIR}

This path will change dynamically to reflect which compiler programming
environment you have loaded.  (You can also see that this is the path
sent to the compilation by doing ``ftn -craype-verbose``).



Preferred configuration
^^^^^^^^^^^^^^^^^^^^^^^

There are 32 cores per node on Cori Haswell.  Generally, using 4 or 8 OpenMP
threads with 8 or 4 MPI tasks should work best.




Cori KNL
--------

Regardless of the compiler, you need to swap the compiler weappers to
use the AVX-512 instruction set supported on the Intel Phi processors
(instead of the AVX-2 on the Haswell chips).  This is done as:

.. prompt:: bash

   module swap craype-{haswell,mic-knl}

It could happen that even when the various verbosities are set to 0,
when using several nodes (more than 64) in a run compiled with Intel,
the follwing error shows::

  forrtl: severe (40): recursive I/O operation, unit -1, file unknown

Seems like the error is due to all threads printing to stdout. Adding
the following to the ``inputs`` file, prevents this error to occur::

  castro.print_fortran_warnings = 0


Intel
^^^^^

When running MAESTROeX, we seem to need::

  amrex.signal_handling = 0

otherwise we get an ``Erroneous arithmetic error``.



Cori GPU
--------

To use the Cori GPU system, you first need to load the ``cgpu`` module:

.. prompt:: bash

   module purge
   module load cgpu

This will ensure the correct OpenMPI module is loaded in the next section.

Loading ``cgpu`` will also let you check on your running jobs using ``squeue``.

Compiling with GCC + CUDA
^^^^^^^^^^^^^^^^^^^^^^^^^

We use the gcc, CUDA, and OpenMPI modules for Cori GPU, so load them in this
order:

.. prompt:: bash

   module load PrgEnv-gnu
   module load gcc
   module load cuda
   module load openmpi
   module load python3

Then to compile, we'll need to get an interactive session on a Cori GPU node.
This example gets 1 Cori GPU node with 1 GPU/node and 10 CPU cores/node for 60
minutes, reserving 30GB of RAM per node:

.. prompt:: bash

   salloc -C gpu --gres=gpu:1 -N 1 -t 60 -c 10 --mem=30GB -A [your allocation, e.g. mABCD] [--exclusive]

.. note::

  If the optional ``--exclusive`` argument is present, then your job will have
  exclusive use of the nodes you requested for the duration of the job.  The
  default behavior on Cori GPU is for jobs to share the GPU nodes, since there
  are a limited number.

Build, e.g. the Castro Sedov hydro test problem:

.. prompt:: bash

   make -j COMP=gnu TINY_PROFILE=TRUE USE_MPI=TRUE USE_OMP=FALSE USE_CUDA=TRUE



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

Build, e.g. the Castro Sedov hydro test problem

.. prompt:: bash

   make -j COMP=gnu TINY_PROFILE=TRUE USE_MPI=TRUE USE_OMP=FALSE USE_CUDA=TRUE

Hypre
^^^^^

Hypre should be obtained from GitHub, and built using the same PrgEnv that you are using for Castro::

  HYPRE_CUDA_SM=80 CXX=CC CC=cc FC=ftn ./configure --prefix=/path/to/hypre/install --with-MPI --with-cuda --enable-unified-memory

