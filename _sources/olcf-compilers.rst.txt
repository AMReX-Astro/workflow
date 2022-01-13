.. highlight:: bash

Compiling at OLCF
=================

Summit
------

In order to compile you will need to swap the xl module with gcc (you need to use atleast gcc/7.4.0 due to C++17 support)::

  module load gcc/7.4.0

.. note::

   You will need to load the same module you use for compiling in your
   submissions script, otherwise the code won't find the shared
   libraries at runtime.

Then load CUDA::

  module load cuda/11.2.0

.. note::

   Presently you will see a warning when you load a CUDA 11 module, but the packages
   should work fine.

You also need to make sure you have the python module loaded::

  module load python/3.7.0

Compile with ``USE_CUDA=TRUE`` (and ``COMP=gnu`` which is usually the default).
Do not compile with ``USE_OMP=TRUE`` since this is currently disallowed by Castro.
An example compilation line is::

  make COMP=gnu USE_MPI=TRUE USE_CUDA=TRUE -j 4

The recommended/tested version pairs are:

  * ``gcc/7.4.0`` + ``cuda/11.2.0``

.. note::

   - OpenMP offloading to the GPU is controlled by
     ``USE_OMP_OFFLOAD``, which will default to ``FALSE``, AMReX-Astro
     doesn't use this feature.


Crusher
-------

log into::

   crusher.olcf.ornl.gov

load the modules::

   module load PrgEnv-gnu craype-accel-amd-gfx90a rocm

build with::

   USE_HIP=TRUE



