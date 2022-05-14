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

Jobs are submitted as::

  sbatch script.slurm

To chain jobs, such that one queues up after the previous job
finished, use the ``chainslurm.sh`` script in that same directory::

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

You can view the job dependency using::

  squeue -l -j job-id

where ``job-id`` is the number of the job.  A job can be canceled
using ``scancel``, and the status can be checked using ``squeue -u
username``.

An estimate of the start time can be found via::

  sqs -u username


Cori GPU
--------

Use a SLURM script to set 1 MPI rank per GPU. In this example, we're using 2 nodes, each with 8 GPUs.

Sample SLURM script ``cori.MPI.CUDA.gpu.2nodes.slurm``, for this and other Cori
GPU SLURM scripts, see
`our Cori GPU SLURM scripts on GitHub <https://github.com/AMReX-Astro/workflow/blob/main/job_scripts/cori-gpu>`_

.. literalinclude:: ../../job_scripts/cori-gpu/cori.MPI.CUDA.gpu.2nodes.slurm
                    :language: sh
                    :linenos:

.. note::

  Replace ``[your email address]`` and ``[your allocation]`` with your info
  (omitting the brackets).

.. note::

  It is important to submit the Cori GPU SLURM script from a Cori login node.
  If you submit the script from your Cori GPU interactive session, the memory
  constraints you passed to ``salloc`` will conflict with the GPU options
  specified in the SLURM script.

So we'll next submit the SLURM script from a Cori login node, with the above
modules loaded::

  sbatch [--exclusive] cori.MPI.CUDA.gpu.2nodes.slurm

(The optional ``--exclusive`` argument has the same meaning as for ``salloc`` above.)

We can monitor the job by checking ``squeue -u [user]`` as usual with the
``cgpu`` module loaded.


Perlmutter
----------


Below is an example that launches the Sedov test compiled above with 4 GPUs per node on 4 nodes.

.. literalinclude:: ../../job_scripts/perlmutter/sedov_4_nodes_example.sh
                    :language: sh
                    :linenos:


Archiving Data to HPSS
======================

.. note::

   Access to the xfer queue is done by loading the ``esslurm`` queue::

     module load esslurm

   Then you can use ``sbatch`` and ``squeue`` to submit and monitor
   jobs in the ``xfer`` queue.  Details are provided at:
   https://docs.nersc.gov/jobs/examples/#xfer-queue


The script ``nersc.xfer.slurm`` in
``workflow/job_scripts/cori-haswell/`` can be used to archive data to
HPSS automatically. This is submitted to the xfer queue and runs the
script ``process.xrb`` which continually looks for output and stores
it to HPSS.

To use the scripts, first create a directory in HPSS that has the same
name as the directory on lustre you are running in (just the directory
name, not the full path). E.g. if you are running in a directory call
``wdconvect/`` run, then do::

  hsi
  mkdir wdconvect_run

(Note: if the ``hsi`` command prompts you for your password, you will need to talk to the NERSC
help desk to ask for password-less access to HPSS).

The script ``process.xrb`` is called from the xfer job and will run in
the background and continually wait until checkpoint or plotfiles are
created (actually, it always leaves the most recent one alone, since
data may still be written to it, so it waits until there are more than
1 in the directory).  Then the script will use ``htar`` to archive the
plotfiles and checkpoints to HPSS. If the ``htar`` command was
successful, then the plotfiles are copied into a ``plotfile/``
subdirectory. This is actually important, since you don’t want to try
archiving the data a second time and overwriting the stored copy,
especially if a purge took place. The same is done with checkpoint
files.  

Additionally, if the ``ftime`` executable is in your path
(``ftime.f90`` lives in ``AMReX/Tools/Postprocessing/F_src/``), then
the script will create a file called ``ftime.out`` that lists the name
of the plotfile and the corresponding simulation time.

Finally, right when the job is submitted, the script will tar up all
of the diagnostic files, ``ftime.out``, submission script, inputs and
probin, and archive them on HPSS. The .tar file is given a name that
contains the date-string to allow multiple archives to co-exist.  When
``process.xrb`` is running, it creates a lockfile (called
``process.pid``) that ensures that only one instance of the script is
running at any one time. Sometimes if the machine crashes, the
``process.pid`` file will be left behind, in which case, the script
aborts. Just delete that if you know the script is not running.

Jobs in the xfer queue start up quickly. The best approach is to start
one as you start your main job (or make it dependent on the main
job). The sample ``process.xrb`` script will wait for output and then
archive it as it is produced.
