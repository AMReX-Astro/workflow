.. highlight:: bash

***************
Working at ALCF
***************

Polaris has 560 nodes each with 4 NVIDIA A100 GPUs.

The PBS scheduler is used.

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
   # load gcc/11.2.0 version since CUDA doesn't support gcc 12 yet
   module load gcc/11.2.0
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

For production jobs, you submit to the ``prod`` queue.

.. note::

   The smallest node count that seems to be allowed in production is 10 nodes.


Submitting
==========

Clone the ``GettingStarted`` repo:

.. prompt:: bash

   git clone git@github.com:argonne-lcf/GettingStarted.git

you'll want to use the examples in
``GettingStarted/Examples/Polaris/affinity_gpu``.

In particular, you will need the script
``set_affinity_gpu_polaris.sh`` copied into your run directory.

Here's a submission script that will run on 2 nodes with 4 GPUs / node:

.. literalinclude:: ../../job_scripts/polaris/polaris_simple.submit
   :caption: ``polaris.submit``

To submit the job, do:

.. prompt:: bash

   qsub polaris.submit

To check the status:

.. prompt:: bash

   qstat -u username


Automatic Restarting
====================

A version of the submission script that automatically restarts from
the last checkpoint is:

.. literalinclude:: ../../job_scripts/polaris/polaris.submit
   :caption: ``polaris.submit``


Job Chaining
============

A script that can be used to chain jobs with PBS is:

.. literalinclude:: ../../job_scripts/polaris/chainqsub.sh
   :caption: ``chainqsub.sh``

