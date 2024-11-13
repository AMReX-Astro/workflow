.. highlight:: bash

Compiling at OLCF
=================

Frontier
--------

log into: ``frontier.olcf.ornl.gov``

see: https://docs.olcf.ornl.gov/systems/frontier_user_guide.html#programming-environment

load modules:

.. prompt:: bash

   module load PrgEnv-gnu
   module load cray-mpich/8.1.28
   module load craype-accel-amd-gfx90a
   module load amd-mixed/6.1.3
   module unload darshan-runtime

this will load ROCm 6.1.3

.. note::

   In the past, tabulated rates seem to exhibit a strange slow down on
   Frontier, so it is best to run test with and without rate
   tabulation to see if there is a performance issue.

build via:

.. prompt:: bash

   make USE_HIP=TRUE


HIP Function Inlining
^^^^^^^^^^^^^^^^^^^^^

By default, the ROCm compiler inlines all function calls in device code
(for better compatibility with codes that use file- or function-scoped
``__shared__`` variables). This greatly increases the time it takes to
compile and link, and may be detrimental for the templated Microphysics
networks with lots of compile-time loop unrolling.

This can be disabled by passing flags to ``hipcc`` to allow non-inlined
function calls:

.. prompt:: bash

   make USE_HIP=TRUE EXTRACXXFLAGS='-mllvm -amdgpu-function-calls=true'

See also https://rocm.docs.amd.com/en/docs-5.3.3/reference/rocmcc/rocmcc.html#rocm-compiler-interfaces

.. note::

   Inline is automatically disabled via our ``Microphysics`` repository
   when it detects a HIP build.
