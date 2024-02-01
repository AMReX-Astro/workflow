
Archiving Data to HPSS
======================

The `NERSC HPSS Archive <https://docs.nersc.gov/filesystems/archive/>`_
is a large tape library that can store the simulations files for long
periods of time.  It is recommended to move your data to HPSS
frequently, since the scratch filesystems fill up and NERSC will purge
data periodically.


The script ``nersc.xfer.slurm`` in ``job_scripts/perlmutter/``:

:download:`nersc.xfer.slurm <../../job_scripts/perlmutter/nersc.xfer.slurm>`

can be used to archive data to
HPSS automatically. This is submitted to the xfer queue and runs the
script ``process.xrb`` in ``job_scripts/hpss/``:

:download:`process.xrb <../../job_scripts/hpss/process.xrb>`

which continually looks for output and stores it to HPSS.
By default, the destination directory on HPSS will be have the same name
as the directory your plotfiles are located in.  This can be changed by
editing the``$HPSS_DIR`` variable at the top of ``process.xrb``.

The following describes how to use the scripts:

#. Copy the ``process.xrb`` script and the slurm script ``nersc.xfer.slurm``
   into the directory with the plotfiles.

#. Submit the archive job:

   .. prompt:: bash

      sbatch nersc.xfer.slurm

   The script ``process.xrb`` is called from the xfer job and will run in
   the background and continually wait until checkpoint or plotfiles are
   created.

   .. note::

      ``process.xrb`` always leaves the most recent plotfile and checkpoint file alone, since
      data may still be written to it.

   The script will use ``htar`` to archive the plotfiles and
   checkpoints to HPSS.

   If the ``htar`` command was successful, then the plotfiles are
   copied into a ``plotfile/`` subdirectory. This is actually important,
   since you don’t want to try archiving the data a second time and
   overwriting the stored copy, especially if a purge took place. The
   same is done with checkpoint files.

Some additional notes:

* If the ``ftime`` executable is in your path (``ftime.cpp`` lives in
  ``amrex/Tools/Plotfile/``), then the script will create a file
  called ``ftime.out`` that lists the name of the plotfile and the
  corresponding simulation time.

* Right when the job is run, the script will tar up all of the
  diagnostic files, ``ftime.out``, submission script, and inputs and
  archive them on HPSS. The ``.tar`` file is given a name that contains
  the date-string to allow multiple archives to co-exist.

* When ``process.xrb`` is running, it creates a lockfile (called
  ``process.jobid``) that ensures that only one instance of the script
  is running at any one time.

  .. warning::

     Sometimes if the job is not terminated normally, the
     ``process.jobid`` file will be left behind. Later jobs should be
     able to detect this and clean up the stale lockfile, but if this
     doesn't work, you can delete the file if you know the script is not
     running.

Jobs in the xfer queue start up quickly. The best approach is to start
one as you start your main job (or make it dependent on the main
job). The sample ``process.xrb`` script will wait for output and then
archive it as it is produced.
