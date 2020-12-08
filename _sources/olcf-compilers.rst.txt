.. highlight:: bash

Compiling at OLCF
=================

Summit
------

In order to compile you will need to swap the xl module with pgi::

  module swap xl pgi

Then load CUDA::

  module load cuda

You also need to make sure you have the python module loaded::

  module load python/3.7.0

Compile with ``COMP = pgi`` and ``USE_CUDA=TRUE``.  Ensure your
GNUMakefile uses ``USE_OMP=FALSE`` since AMReX's standard OpenMP
strategy conflicts with GPUs.  An example compilation line is::

  make COMP=pgi INTEGRATOR_DIR=VODE USE_CUDA=TRUE -j 4


The version pairs that work for sure currently are:

  * ``pgi/19.10`` + ``cuda/10.1.168``

.. note::

   - OpenMP offloading to the GPU is controlled by
     ``USE_OMP_OFFLOAD``, which will default to ``FALSE``, AMReX-Astro
     doesn't use this feature.

