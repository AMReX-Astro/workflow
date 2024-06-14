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

   module use /soft/modulefiles
   module load PrgEnv-gnu
   module load nvhpc-mixed

Then you can compile via:

.. prompt:: bash

   make COMP=cray USE_CUDA=TRUE


Disks
=====

Project workspace is at: ``/lus/grand/projects/AstroExplosions/``


Queues
======

https://www.alcf.anl.gov/support/user-guides/polaris/queueing-and-running-jobs/job-and-queue-scheduling/index.html

For production jobs, you submit to the ``prod`` queue.

For debugging jobs, there are two options: the ``debug`` queue for only one node use jobs, and 
``debug-scaling`` for jobs that require between two nodes and 10-nodes. The former is used mainly for
tunning the optimal parameters and compare the scalability of the allocated resources.

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


Installing Python
=================

The most recommended way to install python is to create a virtual environment
on the top of the conda-based environment provided by the module conda, and install all the extra
required modules on this virtual environment. Although is very tempting
to clone the whole base environment and fully customize the installed conda packages, some
modules like ``mpi4py`` may require access to the MPICH libraries that are tailored to be
used only within the conda-base environment provided by the conda module.

To create the virtual environment:

.. prompt:: bash

   module use /soft/modulefiles
   module load conda 
   conda activate
   VENV_DIR="venvs/polaris"
   mkdir -p "${VENV_DIR}"
   python -m venv "${VENV_DIR}" --system-site-packages
   source "${VENV_DIR}/bin/activate"

To activate it in a new terminal, if the module path ``/soft/modules``
is loaded:

.. prompt:: bash

   module load conda 
   conda activate
   VENV_DIR="venvs/polaris"
   source "${VENV_DIR}/bin/activate"


Once the virtual environment is active, any extra package can be installed with
the use of ``pip``:

.. prompt:: bash

   python pip -m install <module>
