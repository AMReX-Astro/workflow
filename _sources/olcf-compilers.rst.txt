.. highlight:: bash

Compiling at OLCF
=================

Titan
-----

The default version of python on titan is not recent enough
to support the python scripts in our build system.  At the
terminal do::

  module load python

to fix this.


Summit
------

In order to compilei you will need to swap the xl module with pgi::

  module swap xl pgi

Then load CUDA::
  
  module load cuda

compile with ``COMP = pgi`` and ``USE_CUDA=TRUE``

The versions that work for sure currently, pgi/18.10 and cuda/9.2.148

  
Note that ``INTEGRATOR_DIR`` should be set to ``VODE90``, since ``VODE`` will not work with GPUs


