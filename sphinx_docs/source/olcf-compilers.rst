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

Load modules:

.. prompt:: bash

   module load cpe
   module load PrgEnv-gnu
   module load cray-mpich
   module load craype-accel-amd-gfx90a
   module load rocm/6.3.1

Then you need to modify the library include path to include ``CRAY_LD_LIBRARY_PATH``
since the module wrappers do not do this:

.. prompt:: bash

   export LD_LIBRARY_PATH=$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH

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
