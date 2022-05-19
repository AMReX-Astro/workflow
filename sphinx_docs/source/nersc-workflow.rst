.. highlight:: bash

Managing Jobs at NERSC
======================

Cori Haswell
------------

Cori Haswell is configured with 32 cores per node, split between
twi Intel Haswell 16-core processors.

Jobs should be run in your ``$SCRATCH`` directory. By default,
SLURM will change directory into the submission directory.

A sample job submission script for pure MPI,
``cori_haswell.MPI.slurm`` is in the `cori-haswell
<https://github.com/AMReX-Astro/workflow/blob/master/job_scripts/cori-haswell/>`_
directory (``workflow/job_scripts/cori-haswell/``) and includes logic
to automatically add the correct restart options to the run to
continue a simulation from the last checkpoint file in the submission
directory.

Jobs are submitted as:

.. prompt:: bash

   sbatch script.slurm

To chain jobs, such that one queues up after the previous job
finished, use the ``chainslurm.sh`` script in that same directory:

.. prompt:: bash

   chainslurm.sh jobid number script

where ``jobid`` is the existing job you want to start you chain from,
``number`` is the number of new jobs to chain from this starting job,
and ``script`` is the job submission script to use (the same one you
used originally most likely).

.. note::

   The script can also create the initial job to start the chain.
   If ``jobid`` is set to ``-1``, then the script will first submit a
   job with no dependencies and then chain the remaining ``number``-1
   jobs to depend on the previous.

You can view the job dependency using:

.. prompt:: bash

   squeue -l -j job-id

where ``job-id`` is the number of the job.  A job can be canceled
using ``scancel``, and the status can be checked using ``squeue -u
username`` or ``squeue --me``.

An estimate of the start time can be found via:

.. prompt:: bash

   sqs -u username



Perlmutter
----------

Perlmutter has 1536 GPU nodes, each with 4 NVIDIA A100 GPUs -- therefore it is best to use
4 MPI tasks per node.

.. note::

   you need to load the same modules used to compile the executable in
   your submission script, otherwise, it will fail at runtime because
   it can't find the CUDA libraries.

Below is an example that runs on 16 nodes with 4 GPUs per node, and also
includes the restart logic to allow for job chaining.

.. literalinclude:: ../../job_scripts/perlmutter/perlmutter.submit
   :language: sh

