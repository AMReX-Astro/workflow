.. highlight:: bash

Compiling at OLCF
=================

Summit
------

In order to compile you will need to swap the xl module with gcc (you need to use atleast gcc/7.4.0 due to C++17 support):

.. prompt:: bash

   module load gcc/10.2.0

.. note::

   You will need to load the same module you use for compiling in your
   submissions script, otherwise the code won't find the shared
   libraries at runtime.

Then load CUDA:

.. prompt:: bash

  module load cuda/11.5.2

.. note::

   Presently you will see a warning when you load a CUDA 11 module, but the packages
   should work fine.

You also need to make sure you have the python module loaded:

.. prompt:: bash

  module load python

Compile with ``USE_CUDA=TRUE`` (and ``COMP=gnu`` which is usually the default).
Is important to setup ``USE_OMP=FALSE``, since the ``TRUE`` option is currently disallowed by Castro.
An example compilation line is:

.. prompt:: bash

  make COMP=gnu USE_MPI=TRUE USE_CUDA=TRUE -j 4

The recommended/tested version pairs are:

  * ``gcc/10.2.0`` + ``cuda/11.5.2``

.. note::

   - OpenMP offloading to the GPU is controlled by
     ``USE_OMP_OFFLOAD``, which will default to ``FALSE``, AMReX-Astro
     doesn't use this feature.


Crusher
-------

log into ``crusher.olcf.ornl.gov``

We want to build with ROCm/HIP.  Currently, we only work with ROCm 5.x,
which you load as:

.. prompt:: bash

   module load PrgEnv-amd craype-accel-amd-gfx90a cray-mpich/8.1.16 rocm/5.1.0

.. note::

   There are specific MPICH versions that work with each ROCm release,
   as described in: `Determining the Compatibility of Cray MPICH and ROCm <https://docs.olcf.ornl.gov/systems/crusher_quick_start_guide.html#determining-the-compatibility-of-cray-mpich-and-rocm>`_.

We can then build with:

.. prompt:: bash

   make COMP=gnu USE_HIP=TRUE


.. note::

   Async I/O can sometimes have issues on crusher, so it is best to
   leave it off.


.. note::

   Sometimes the job will start (according to ``squeue``) but appear to
   hang.  This is because there are often bad nodes, and you need to
   exclude the bad nodes.  Currently use::

   #SBATCH --exclude=crusher[025-027,036,038-040,060,081,127,136,141,101-105]


Frontier
--------

log into: ``frontier.olcf.ornl.gov``

see: https://docs.olcf.ornl.gov/systems/frontier_user_guide.html#programming-environment

load modules:

.. prompt:: bash

   module load PrgEnv-gnu craype-accel-amd-gfx90a cray-mpich rocm amd-mixed

at the moment, that loads ROCm 5.3.0

.. note::

   ROCm 5.4.3 does not seem to work with Castro--there are memory access issues
   in the burner

.. note::

   Tabulate rates seem to exhibit a strange slow down on Frontier, so it is best
   to run without rate tabulation.

build via:

.. prompt:: bash

   make COMP=gnu USE_HIP=TRUE


.. note::

   Compiling with ``DEBUG=TRUE`` takes a _very_ long time and may not work.

