.. highlight:: bash

Compiling at OLCF
=================

Titan
-----

The default version of python on Titan is not recent enough
to support the python scripts in our build system.  At the
terminal do::

  module load python

to fix this.


Summit
------

In order to compile you will need to swap the xl module with pgi::

  module swap xl pgi

Then load CUDA::
  
  module load cuda/9.1.85

compile with ``COMP = pgi`` and ``USE_CUDA=TRUE``

The versions that work for sure currently are ``pgi/18.10`` and ``cuda/9.1.85``.

.. warning::

   At present, there is a known compiler bug in CUDA 9.2.148 that
   prevents compilation. Using CUDA 9.1 is a workaround.
  
.. note::

   ``INTEGRATOR_DIR`` should be set to ``VODE90``, since ``VODE`` will not work with GPUs

