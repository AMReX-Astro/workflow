.. highlight:: bash

Managing Jobs at OLCF
=====================



Summit
------

Submission scripts
^^^^^^^^^^^^^^^^^^

On Summit, we have a few different examples of PBS batch
scripts. ``run_amrex_gpu_tutorials.summit`` is a shallow copy of the
`AMReX tutorial script
<https://github.com/AMReX-Codes/amrex/blob/development/Tutorials/GPU/run.summit>`_,
and is more verbose about what different flags and options will do.

The Castro GPU batch script example is ``summit_16nodes.sh``, more job
script examples for Castro can be found `here
<https://github.com/AMReX-Astro/Castro/tree/master/Util/scaling/sedov/summit_201905>`_.

.. literalinclude:: ../../job_scripts/summit/summit_16nodes.sh
		    :language: sh
		    :linenos:

.. note::

   You should explicitly include the "module loads" for the GCC and CUDA version you are
   using in the submission script, otherwise your job may not run.  In the example above,
   we load ``gcc/10.2.0`` and ``cuda/11.2.0``.

The Nyx example shows running MPI+CUDA, MPI+CUDA with one mpi process
nvvp output, and MPI+OMP
``run_3_tests_same_node.summit``. ``run_template.summit`` gives
example syntax for jsrun:

.. literalinclude:: ../../job_scripts/summit/run_template.summit
		    :language: sh
		    :emphasize-lines: 14-20,34-42
		    :linenos:

This can be visualized using `<https://jsrunvisualizer.olcf.ornl.gov/index.html>`_

.. |a| image:: ./figs/jsrunVisualizer-MPI+OMP.png
       :width: 100%
.. |b| image:: ./figs/jsrunVisualizer-MPI+GPU.png
       :width: 100%

.. _fig:gpu:threads:

.. table:: Comparison of jsrun process assignment for MPI + OpenMP and MPI + GPU work distribution.

	   +-----------------------------------------------------+------------------------------------------------------+
	   |                        |a|                          |                        |b|                           |
	   +-----------------------------------------------------+------------------------------------------------------+
	   | | MPI + OpenMP                                      | | MPI + GPU                                          |
	   +-----------------------------------------------------+------------------------------------------------------+

The example script directory is: `<https://github.com/AMReX-Astro/workflow/tree/master/job_scripts/summit>`_

.. note::

   We are defaulting to one hardware thread per CPU, since this is the configuration suggested by OLCF


Submitting and monitoring
^^^^^^^^^^^^^^^^^^^^^^^^^

Jobs are submitted using the ``bsub`` command::

  bsub script.sh

You can monitor the status of your jobs using ``bjobs``.

A slightly nicer view of your jobs can be viewed using ``jobstat`` as::

  jobstat -u username


Automatic restarting
^^^^^^^^^^^^^^^^^^^^

Often we run a single simulation over many queue submissions with each
starting from the latest checkpoint file.  The script
``job_scripts/summit/submit_restart.sh`` shows how to automatically
detect the last checkpoint file and restart from it.  This allows you
to submit your jobs without any manual intervention.

.. literalinclude:: ../../job_scripts/summit/submit_restart.sh
		    :language: sh

The function ``find_chk_file`` searches the submission directory for
checkpoint files.  Because AMReX appends digits as the number of steps
increase (with a minimum of 5 digits), we search for files with
7-digits, 6-digits, and then finally 5-digits, to ensure we pick up
the latest file.



Chaining jobs
^^^^^^^^^^^^^

The script ``job_scripts/summit/chain_submit.sh`` can be used to setup job dependencies,
i.e., a job chain.

First you submit a job as usual using ``bsub``, and make note of the
job-id that it prints upon submission (the same id you would see with
``bjobs`` or ``jobstat``).  Then you setup N jobs to depend on the one
you just submitted as::

   chain_submit.sh job-id N submit_script.sh

where you replace ``job-id`` with the id return from your first
submission, replace ``N`` with the number of additional jobs, and
replace ``submit_script`` with the name of the script you use to
submit the job.  This will queue up N additional jobs, each depending
on the previous.  Your submission script should use the automatic
restarting features discussed above.


Archiving to HPSS
-----------------

You can access HPSS from submit using the data transfer nodes by submitting a job
via SLURM::

  sbatch -N 1 -t 15:00 -A ast106 --cluster dtn test_hpss.sh

where ``test_hpss.sh`` is a SLURM script that contains the ``htar``
commands needed to archive your data.  This uses ``slurm`` as the job
manager.

An example is provided by the ``process.xrb`` archiving script and
associated ``summit_hpss.submit`` submission script in
``jobs_scripts/summit/``.  Together these will detect new plotfiles as
they are generated, tar them up (using ``htar``) and archive them onto
HPSS.  They will also store the inputs, probin, and other runtime
generated files.  If ``ftime`` is found in your path, it will also
create a file called ``ftime.out`` that lists the simulation time
corresponding to each plotfile.

Once the plotfiles are archived they are moved to a subdirectory under
your run directory called ``plotfiles/``.


To use this, we do the following:

#. Enter the HPSS system via ``hsi``

#. Create the output directory -- this should have the same name as the directory
   you are running in on summit

#. Exit HPSS

#. Launch the script via::

     sbatch summit_hpss.submit

   It will for the full time you asked, searching for plotfiles as
   they are created and moving them to HPSS as they are produced (it
   will always leave the very last plotfile alone, since it can't tell
   if it is still being written).


Files may be unarchived in bulk from HPSS on OLCF systems using the
``hpss_xfer.py`` script, which is available in the job_scripts
directory. It requires Python 3 to be loaded to run. The command::

    ./hpss_xfer.py plt00000 -s hpss_dir -o plotfile_dir

will fetch ``hpss_dir/plt00000.tar`` from the HPSS filesystem and
unpack it in ``plotfile_dir``. If run with no arguments in the problem
launch directory, the script will attempt to recover all plotfiles
archived by ``process.titan``. Try running :code:`./hpss_xfer.py --help`
for a description of usage and arguments.

