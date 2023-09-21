.. highlight:: bash

Managing Jobs at NERSC
======================


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

Below is an example that runs on CPU-only nodes. Here ``ntasks-per-node``
refers to number of MPI processes (used for distributed parallelism) per node,
and ``cpus-per-task`` refers to number of hyper threads used per task
(used for shared-memory parallelism). Since Perlmutter CPU node has
2 sockets * 64 cores/socket * 2 threads/core = 256 threads, set ``cpus-per-task``
to ``256/(ntasks-per-node)``. However, it is actually best to assign
each OpenMP thread per physical core, so it is best to set ``OMP_NUM_THREADS`` to
``cpus-per-task/2``. See more detailed instructions within the script.

.. literalinclude:: ../../job_scripts/perlmutter-cpu/perlmutter_cpu.slurm
   :language: sh

.. note::

   Jobs should be run in your ``$SCRATCH`` directory. By default,
   SLURM will change directory into the submission directory.

   Alternately, you can run in the common file system, ``$CFS/m3018``,
   which everyone in the project has access to.

Jobs are submitted as:

.. prompt:: bash

   sbatch script.slurm

You can check the status of your jobs via:

.. prompt:: bash

   squeue --me

and an estimate of the start time can be found via:

.. prompt:: bash

   squeue --me --start

to cancel a job, you would use ``scancel``.


Chaining
^^^^^^^^

To chain jobs, such that one queues up after the previous job
finished, use the `chainslurm.sh <https://github.com/AMReX-Astro/workflow/blob/main/job_scripts/slurm/chainslurm.sh>`_  script in that same directory:

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




