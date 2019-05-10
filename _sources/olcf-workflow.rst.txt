.. highlight:: bash

Managing Jobs at OLCF
=====================

On Titan, we have a PBS script ``titan.run`` and a script
``process.titan`` executed by ``titan.run`` to tar up plot,
checkpoint, and diagnostic files and store them in HPSS.

These are here: `<https://github.com/AMReX-Astro/workflow/tree/master/job_scripts/titan>`_

The ``process.titan`` script relies on ``ftime``, an AMReX plotfile
tool that prints the simulation time for a given plotfile.

You can build ``ftime`` (tested with GNU) in ``amrex/Tools/Plotfile``,
copy it into the run directory, and set ``FTIME_EXE`` appropriately in
``process.titan``. If compiled with GNU, then the ``PrgEnv-gnu``
module should be loaded when you submit the ``titan.run`` PBS script.

These scripts will automatically create a directory with the same name
as your run directory on HPSS where files will be archived.

To have a look, use the ``hsi`` command to browse HPSS.

For more information about using HPSS on Titan see `<https://www.olcf.ornl.gov/for-users/system-user-guides/titan/titan-user-guide/#workflow>`_

Error: aprun not found
======================

It is possible (on Titan) that some aspect of the environment on job
submission can lead to the job failing with the following error::

  XALT Error: unable to find aprun

Bill Renaud at OLCF advised adding the `-l` shell argument in the
script shebang line. This did not work for the `ksh` shell but does
work for `bash` as::

  #!/bin/bash -l

This allows the job to run for the PBS script submitted from either
`bash` or `zsh`.
