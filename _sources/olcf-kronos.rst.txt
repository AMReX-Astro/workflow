Archiving Data on Kronos
========================

`Kronos <https://docs.olcf.ornl.gov/data/#kronos-nearline-archival-storage-system>`_
is the mass storage system at OLCF.  Each user has a directory of the form:

.. code:: bash

   /nl/kronos/olcf/<projectID>/users/<userID>

and data can be transferred there using standard Unix commands.

.. note::

   You need to be logged into ``dtn.olcf.ornl.gov`` to access kronos.  It is
   not visible directly from Frontier or Andes.

A submission / shell script pair that automates the transfer of data is available in
`workflow/job_scripts/hpss <https://github.com/AMReX-Astro/workflow/tree/main/job_scripts/hpss>`_ as:

* ``olcf_kronos.submit`` : the slurm submission script
* ``kronos_process.sh`` : a BASH script that finds output and automates the archiving.

You submit the job from the directory containing the plotfiles you wish to archive.
It will then:

* tar up the diagnostic files, inputs, and other metadata into a file with the
  date-stamp in the file name and copy that to kronos

* find all of the plotfiles and tar them directly to kronos.  If the tar is successful,
  it will move the plotfile into a ``plotfiles/`` subdirectory and add a ``.processed``
  file so the script knows it was archived already.

* find the checkpoint files matching a pattern (currently defaults to every 5000 steps)
  and archive those in the same fashion, moving them to a ``checkfiles/`` subdirectory
  once archived.

* loop, looking for new output files

By default, it will not transfer the last file, in case it is actively being written to.

.. tip::

   The ``olcf_kronos_once.submit`` can be used to just transfer without the loop
   waiting for new files.



