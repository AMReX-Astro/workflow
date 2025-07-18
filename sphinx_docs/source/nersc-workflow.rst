.. highlight:: bash

Managing Jobs at NERSC
======================


Perlmutter
----------

GPU jobs
^^^^^^^^

Perlmutter has 1536 GPU nodes, each with 4 NVIDIA A100
GPUs---therefore it is best to use 4 MPI tasks per node.

.. important::

   you need to load the same modules used to compile the executable in
   your submission script, otherwise, it will fail at runtime because
   it can't find the CUDA libraries.

Below is an example that runs on 16 nodes with 4 GPUs per node.  It also
does the following:

* Includes logic for automatically restarting from the last checkpoint file
  (useful for job-chaining).  This is done via the ``find_chk_file`` function.

* Installs a signal handler to create a ``dump_and_stop`` file shortly before
  the queue window ends.  This ensures that we get a checkpoint at the very
  end of the queue window.

* Can post to slack using the :download:`slack_job_start.py
  <../../job_scripts/perlmutter/slack_job_start.py>` script---this
  requires a webhook to be installed (in a file ``~/.slack.webhook``).

.. literalinclude:: ../../job_scripts/perlmutter/perlmutter.submit
   :language: sh

.. note::

   With large reaction networks, you may get GPU out-of-memory errors during
   the first burner call.  If this happens, you can add

   ::

      amrex.the_arena_init_size=0

   after ``${restartString}`` in the srun call
   so AMReX doesn't reserve 3/4 of the GPU memory for the device arena.

.. note::

   If the job times out before writing out a checkpoint (leaving a
   ``dump_and_stop`` file behind), you can give it more time between the
   warning signal and the end of the allocation by adjusting the
   ``#SBATCH --signal=B:URG@<n>`` line at the top of the script.

   Also, by default, AMReX will output a plotfile at the same time as a checkpoint file,
   which means you'll get one from the ``dump_and_stop``, which may not be at the same
   time intervals as your ``amr.plot_per``.  To suppress this, set:

   ::

      amr.write_plotfile_with_checkpoint = 0

CPU jobs
^^^^^^^^

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


Submitting and checking status
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. note::

   Jobs should be run in your ``$SCRATCH`` directory and not
   your home directory.

   By default, SLURM will change directory into the submission
   directory.


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


Filesystems
^^^^^^^^^^^

In addition to ``$SCRATCH``, there is a project-wide directory
on the common filesystem, CFS.  This allows us to share files with everyone
in the project.  For instance, for project ``m3018``, we would do:

.. prompt:: bash

   cd $CFS/m3018

There is a 20 TB quota here, which can be checked via:

.. prompt:: bash

   showquota m3018


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

where ``job-id`` is the number of the job. 




