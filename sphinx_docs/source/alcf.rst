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


Queues
======

https://www.alcf.anl.gov/support/user-guides/polaris/queueing-and-running-jobs/job-and-queue-scheduling/index.html

Submitting
==========

Clone the ``GettingStarted`` repo:

.. prompt:: bash

   git clone git@github.com:argonne-lcf/GettingStarted.git

you'll want to use the examples in
``GettingStarted/Examples/Polaris/affinity_gpu``.

In particular, you will need the script
``set_affinity_gpu_polaris.sh`` copied into your run directory.
