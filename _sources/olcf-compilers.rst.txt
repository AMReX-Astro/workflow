.. highlight:: bash

Compiling at OLCF
=================

Summit
------

In order to compile you will need to swap the xl module with pgi::

  module swap xl pgi

Then load CUDA::
  
  module load cuda

compile with ``COMP = pgi`` and ``USE_CUDA=TRUE``

Ensure your GNUMakefile uses ``USE_OMP=FALSE`` since AMReX's standard OpenMP strategy conflicts with GPUs.


The version pairs that work for sure currently are ``pgi/18.10 + cuda/9.1.85``, ``pgi/19.5 + cuda/10.1.168``, and ``pgi/19.5 + cuda/10.1.105``.

.. warning::

   At present, there is a known compiler bug in CUDA 9.2.148 that
   prevents compilation. Using CUDA 9.1 is a workaround.
  
.. note::

   - Use ``INTEGRATOR_DIR=VODE90`` if specifying an integrator at compile time, since ``VODE`` will not work with GPUs.
   - Use ``USE_GPU_PRAGMA=TRUE`` for any code which uses ``#pragma gpu``, this flag is set by default in MAESTROeX and CASTRO's build system when ``USE_CUDA=TRUE``.
   - OpenMP offloading to the GPU is controlled by ``USE_OMP_OFFLOAD``, which will default to ``FALSE``, AMReX-Astro doesn't use this feature.
