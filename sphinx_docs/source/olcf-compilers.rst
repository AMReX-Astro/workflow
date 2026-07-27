.. highlight:: bash

Compiling at OLCF
=================

Frontier
--------

log into: ``frontier.olcf.ornl.gov``

see: https://docs.olcf.ornl.gov/systems/frontier_user_guide.html#programming-environment

.. important::

   ROCm versions prior to 6.3.1 had a register allocation bug that caused problems
   with large kernels.  They should not be used.

ROCm
^^^^

There are 2 different versions of ROCm that seem to work well now:

* ROCm 6.3.1

  Load modules:

  .. prompt:: bash

     module load cpe
     module load PrgEnv-gnu
     module load cray-mpich
     module load craype-accel-amd-gfx90a
     module load rocm/6.3.1


* ROCm 7.2.0

  Load modules:

  .. prompt:: bash

     module load cpe/26.03
     module load PrgEnv-gnu
     module load craype-accel-amd-gfx90a
     module load rocm/7.2.0

  .. note::

     Loading ``cpe/26.03`` will also load the version of ``cray-mpich`` that works with
     ROCm 7.2.0 (it needs to be 9.1.0 or later).

.. tip::

   In the past, we've needed to do:

   .. prompt:: bash

      export LD_LIBRARY_PATH=$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH

   but this does not seem necessary anymore.

Building
^^^^^^^^

build via:

.. prompt:: bash

   make USE_HIP=TRUE


HIP Function Inlining
^^^^^^^^^^^^^^^^^^^^^

By default, the ROCm compiler inlines all function calls in device code
(for better compatibility with codes that use file- or function-scoped
``__shared__`` variables).  This used to cause problems with older
versions of ROCm (< 6.3.1), but with recent versions it seems to work
fine.

If desired this can be disabled by passing flags to ``hipcc`` to allow non-inlined
function calls:

.. prompt:: bash

   make USE_HIP=TRUE EXTRACXXFLAGS='-mllvm -amdgpu-function-calls=true'

See also https://rocm.docs.amd.com/en/docs-5.3.3/reference/rocmcc/rocmcc.html#rocm-compiler-interfaces

Microphysics has an option to set these flags, which can be activated by building
as:

.. prompt:: bash

   make DISABLE_HIP_INLINE=TRUE
