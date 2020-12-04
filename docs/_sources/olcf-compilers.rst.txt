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

  * ``pgi/19.5`` + ``cuda/10.1.105``.

  * ``pgi/19.5`` + ``cuda/10.1.168``

  * ``pgi/19.10`` + ``cuda/10.1.168``

.. warning::

   At present, there is a known compiler bug in CUDA 9.2.148 that
   prevents compilation. Using CUDA 9.1 is a workaround.

.. note::

   - Use ``USE_GPU_PRAGMA=TRUE`` for any code which uses ``#pragma
     gpu``, this flag is set by default in MAESTROeX and CASTRO's
     build system when ``USE_CUDA=TRUE``.

   - OpenMP offloading to the GPU is controlled by
     ``USE_OMP_OFFLOAD``, which will default to ``FALSE``, AMReX-Astro
     doesn't use this feature.
   
   - MAESTROeX requires C++14, so it is necessary to use a   
     later version of gcc than the version loaded on Summit 
     when the pgi module is loaded. To do this, add the 
     following to the ``GNUMakefile``::

       NVCC_CCBIN=/sw/summit/gcc/7.4.0/bin/g++
       LIBRARY_LOCATIONS += /sw/summit/gcc/7.4.0/lib64/
       LIBRARIES += -Wl,-rpath,/sw/summit/gcc/7.4.0/lib64/

