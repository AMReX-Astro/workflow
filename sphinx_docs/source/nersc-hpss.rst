
Archiving Data to HPSS
======================

.. note::

   Access to the xfer queue is done by loading the ``esslurm`` queue:

   .. prompt:: bash

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
``wdconvect/`` run, then do:

.. prompt:: bash

   hsi
   mkdir wdconvect_run

.. note::

   If the ``hsi`` command prompts you for your password, you will need
   to talk to the NERSC help desk to ask for password-less access to
   HPSS.

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
(``ftime.cpp`` lives in ``amrex/Tools/Plotfile/``), then
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
