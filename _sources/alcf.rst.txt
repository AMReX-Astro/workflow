.. highlight:: bash

***************
Working at ALCF
***************

Polaris has 560 nodes each with 4 NVIDIA A100 GPUs.

Logging In
==========

ssh into::

   polaris.alcf.ornl.gov

To have a custom ``.bashrc``, create a ``~/.bash.expert`` file and add anything
there.  This is read at the end of ``/etc/bash.bashrc``



Compiling
=========

Load the modules:

.. prompt:: bash

   module swap PrgEnv-nvhpc PrgEnv-gnu
   module load nvhpc-mixed

Then you can compile via:

.. prompt:: bash

   make COMP=gnu USE_CUDA=TRUE


Disks
=====

Project workspace is at: ``/lus/grand/projects/AstroExplosions/``

