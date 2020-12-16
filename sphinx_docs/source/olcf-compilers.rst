.. highlight:: bash

Compiling at OLCF
=================

Summit
------

In order to compile you will need to swap the xl module with gcc (the default gcc/6.4.0 is fine, or anything newer)::

  module load gcc

Then load CUDA::

  module load cuda

You also need to make sure you have the python module loaded::

  module load python/3.7.0

Compile with ``USE_CUDA=TRUE`` (and ``COMP=gnu`` which is usually the default).
Do not compile with ``USE_OMP=TRUE`` since this is currently disallowed by Castro.
An example compilation line is::

  make COMP=gnu USE_MPI=TRUE USE_CUDA=TRUE -j 4

The recommended/tested version pairs are:

  * ``gcc/6.4.0`` + ``cuda/10.1.243``
  * ``gcc/7.4.0`` + ``cuda/10.1.243``

.. note::

   - OpenMP offloading to the GPU is controlled by
     ``USE_OMP_OFFLOAD``, which will default to ``FALSE``, AMReX-Astro
     doesn't use this feature.

