.. highlight:: bash

Managing Jobs at OLCF
=====================


Frontier
--------

Machine details
^^^^^^^^^^^^^^^

Queue policies are here:
https://docs.olcf.ornl.gov/systems/frontier_user_guide.html#scheduling-policy


Filesystem is called ``orion``, and is Lustre:
https://docs.olcf.ornl.gov/systems/frontier_user_guide.html#data-and-storage


.. warning::

   The Orion / Lustre filesystem has been broken since Jan 2025 making I/O performance
   very unstable.  To work around this problem we currently advise having each MPI
   process write its own file.  This is enabled automatically in the submission script
   below.  Restarting is also an issue, with 50% of restarts hanging due to filesystem
   issues.  The script below will kill the job after 5 minutes if it detects that the
   restart has failed.

.. note::

   We also explicitly set the filesystem striping using the LFS tools to help I/O
   performance.


Submitting jobs
^^^^^^^^^^^^^^^

Frontier uses SLURM.

Here's a script that runs on GPUs and has the I/O fixes described above.

.. literalinclude:: ../../job_scripts/frontier/frontier.slurm
   :language: bash

The job is submitted as:

.. prompt:: bash

   sbatch frontier.slurm

where ``frontier.slurm`` is the name of the submission script.


Also see the WarpX docs: https://warpx.readthedocs.io/en/latest/install/hpc/frontier.html


GPU-aware MPI
^^^^^^^^^^^^^

Some codes run better with GPU-aware MPI.  To enable this add the following to your
submission script:

.. code:: bash

   export MPICH_GPU_SUPPORT_ENABLED=1
   export FI_MR_CACHE_MONITOR=memhooks

and set the runtime parameter:

.. code::

   amrex.use_gpu_aware_mpi=1

Job Status
^^^^^^^^^^

You can check on the status of your jobs via:

.. prompt:: bash

   squeue --me

and get an estimated start time via:

.. prompt:: bash

   squeue --me --start


Job Chaining
^^^^^^^^^^^^

The script `chainslurm.sh <https://github.com/AMReX-Astro/workflow/blob/main/job_scripts/slurm/chainslurm.sh>`_ can be used to start
a job chain, with each job depending on the previous.  For example, to start up
10 jobs:

.. prompt:: bash

   chainslurm -1 10 frontier.slurm

If you want to add the chain to an existing queued job, change the ``-1`` to the job-id
of the existing job.


Debugging
^^^^^^^^^

Debugging is done with ``rocgdb``.  Here's a workflow that works:

Setup the environment:

.. prompt:: bash

   module load PrgEnv-gnu
   module load cray-mpich/8.1.27
   module load craype-accel-amd-gfx90a
   module load amd-mixed/5.6.0

Build the executable.  Usually it's best to disable MPI if possible
and maybe turn on ``TEST=TRUE``:

.. prompt:: bash

   make USE_HIP=TRUE TEST=TRUE USE_MPI=FALSE -j 4

Startup an interactive session:

.. prompt:: bash

   salloc -A ast106 -J mz -t 0:30:00 -p batch -N 1

This will automatically log you onto the compute now.

.. note::

   It's a good idea to do:

   .. prompt:: bash

      module restore

   and then reload *the same* modules used for compiling in the interactive shell.

Now set the following environment variables:

.. prompt:: bash

   export HIP_ENABLE_DEFERRED_LOADING=0
   export AMD_SERIALIZE_KERNEL=3
   export AMD_SERIALIZE_COPY=3

.. note::

   You can also set

   .. prompt:: bash

      export AMD_LOG_LEVEL=3

   to get *a lot* of information about the GPU calls.

Run the debugger:

.. prompt:: bash

   rocgdb ./Castro2d.hip.x86-trento.HIP.ex

Set the following inside of the debugger:

.. prompt::
   :prompts: (gdb)

   set pagination off
   b abort

The run:

.. prompt::
   :prompts: (gdb)

   run inputs

If it doesn't crash with the trace, then try:

.. prompt::
   :prompts: (gdb)

   interrupt
   bt

It might say that the memory location is not precise, to enable precise
memory, in the debugger, do:

.. prompt::
   :prompts: (gdb)

   set amdgpu precise-memory on
   show amdgpu precise-memory

and rerun.



Troubleshooting
^^^^^^^^^^^^^^^

Workaround to prevent hangs for collectives:

::

 export FI_MR_CACHE_MONITOR=memhooks


Some AMReX reports are that it hangs if the initial Arena size is too
big, and we should do

::

  amrex.the_arena_init_size=0

The arena size would then grow as needed with time.
