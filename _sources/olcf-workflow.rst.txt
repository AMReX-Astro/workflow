.. highlight:: bash

Managing Jobs at OLCF
=====================



Summit
------

Summit Architecture:
^^^^^^^^^^^^^^^^^^^^

Let us start by reviewing the node architecture of Summit. Our goal is to provide the necessary insight to make better
decisions in the construction of our particular AMReX-Astro job scripts, and to explain how our code interacts with Summit.
All the exposed information in this section is a condensed version of the `Summit documentation guide
<https://docs.olcf.ornl.gov/systems/summit_user_guide.html#job-launcher-jsrun>`_, and should not replace it.

In Summit, a node is composed by two sockets: each one with 21 CPU physical cores (+1 reserved for the system), 3 GPUs and 1 RAM memory bank.
The sockets are connected by a bus allowing communication among them. Each CPU physical core may define up to 4 threads.
The whole structure of the node can be depicted as follows:

.. figure:: ./figs/summit-node-description-1.png
   :width: 100%
   :align: center

   Figure extracted from ``https://docs.olcf.ornl.gov/systems/summit_user_guide.html#job-launcher-jsrun``.

A resource set is a minimal collection of CPU physical cores and GPUs, on which a certain number of MPI processes and OpenMP
threads operates through the execution of the code. Therefore, for each resource set, we need to allocate:

- A number of CPU physical cores.

- A number of physical GPUs.

- A number of MPI processes.

- The number of OpenMP threads.

where each core supports up to 4 threads; however, this option is not supported in AMReX and we will not extend our
discussion here. For now, we fix just only one thread through the whole execution of our code. The next step is to determine the maximum
number of resource sets that may fit into one node.

In Castro we construct each resource set with: 1 CPU physical core, 1 GPU, and only 1 MPI process.
The next step is to see how many resources sets fits into one node. According to the node architecture depicted in Figure 1,
we can fit up to 6 resource sets per node as in Figure 2.

.. figure:: ./figs/image56.png
   :width: 100%
   :align: center

   Figure modified and extracted from ``https://docs.olcf.ornl.gov/systems/summit_user_guide.html#job-launcher-jsrun``.

Requesting Allocation:
^^^^^^^^^^^^^^^^^^^^^^

To allocate the resource sets we need to summon the command ``bsub`` in addition to some flags:

.. list-table::
   :widths: 25 75
   :header-rows: 1

   * - Flag
     - Description

   * - ``-nnodes``
     - allocates the number of nodes we need to run our code. Is important to perform the calculation
       described in the previous section to select the correct number of nodes in our setup.


   * - ``-W``
     - allocates the walltime of the selected nodes. The format we use in Summit is [hours:]minutes, there is
       no room for seconds in Summit. The maximum walltime that we can request is 03:00 (three hours).


   * - ``-alloc_flags``
     - allocates the maximum number of threads available per CPU core. By default the option is ``smt4`` that
       allows 4 threads per core. However, since we will consider only one thread through the whole execution
       we will setup the option ``smt1``. Also ``-alloc_flags`` stands for more options, however we are only
       interested in the one discussed before.


   * - ``-J``
     - defines the name of the allocation. The value ``%J`` correspond to the allocation ID number.

   * - ``-o``
     - defines the **output name that contains the standard output stream**, after running all the jobs inside the requested
       allocation.

   * - ``-e``
     - defines the **output file name containing the standard error stream**, similar to the ``-o`` flag. If ``-e`` is not supplied, then
       the ``-o`` option is assumed by default.

   * - ``-q``
     - defines the queue on which our application will run. There are several options, however, we alternate
       between two options: the standard production queue ``batch`` and the debugging queue ``debug``. The ``debug`` queue is designed
       to allocate an small number of nodes in order to see that our code is running smoothly without bugs.

   * - ``-Is``
     - flags for interactive job followed by the shell name. The Unix bash shell option is ``/bin/bash``. This flag is very useful
       for debugging, because the standard output can be checked as the code is running. Is important to mention that any interactive
       job can only be summoned by command line and not by running a bash script.

For example, if we want to allocate one node to run an interactive job in the debug queue for 30 minutes we may setup:

.. prompt:: bash

   bsub -nnodes 1 -q debug -W 0:30 -P ast106 -alloc_flags smt1 -J example -o stdout_to_show.%J -e stderr_to_show.%J -Is /bin/bash

.. note::

   An interactive job can only be allocated by the use of the command line. No script can be defined for interactive jobs.


Submitting a Job:
^^^^^^^^^^^^^^^^^

Once our allocation is granted, is important to load the same modules used in the compilation process of the executable and
export the variable ``OMP_NUM_THREADS`` to setup the number of threads per MPI process.

In Castro, we have used the following modules:

.. code-block::

   module load gcc/10.2.0
   module load cuda/11.5.2
   module load python

and fixed only one thread per MPI process by:

.. code-block::

   export OMP_NUM_THREADS=1

The next step is to submit our job. The command `jsrun`, provided with the *total number of resource sets*, the
*number of CPU physical cores per resource set*, *the number of GPUs per resource set*, *the number of MPI processes allocated per resource set*,
works as follows:

.. prompt:: bash

   jsrun -n[number of resource sets] -c[number of CPU physical cores] -g[number of GPUs] -a[number of MPI processes] -r[number of max resources per node] ./[executable] [executable inputs]

In Castro we will use:

.. prompt:: bash

   jsrun -n [number of resource sets] -a1 -c1 -g1 -r6 ./$CASTRO $INPUTS

where the ``CASTRO`` and ``INPUTS`` environment variables are placeholders to the executable and input file names respectively.

Now, in order to use all the resources we have allocated to run our jobs, the number of resource sets should match the number of AMReX boxes (grids)
of the corresponding level with the biggest number of them. Let us consider an extract piece from a Castro problem standard output:

.. code-block::

   INITIAL GRIDS
   Level 0   2 grids  32768 cells  100 % of domain
             smallest grid: 128 x 128  biggest grid: 128 x 128
   Level 1   8 grids  131072 cells  100 % of domain
             smallest grid: 128 x 128  biggest grid: 128 x 128
   Level 2   8 grids  524288 cells  100 % of domain
             smallest grid: 256 x 256  biggest grid: 256 x 256
   Level 3   32 grids  2097152 cells  100 % of domain
             smallest grid: 256 x 256  biggest grid: 256 x 256
   Level 4   128 grids  7864320 cells  93.75 % of domain
             smallest grid: 256 x 128  biggest grid: 256 x 256
   Level 5   480 grids  30408704 cells  90.625 % of domain
             smallest grid: 256 x 128  biggest grid: 256 x 256

In this example, Level 5 contains the biggest number of AMReX boxes: 480. From here, we may assert that a good allocation for this problem are
480 resource sets, equivalent to 80 nodes by setting 6 resources per node. However, note that that Level 0 uses only 2 AMReX boxes, this implies that
from the 480 resources available, 398 resources will remain idle until the two working processes sweep the entire Level 0.

.. note::

   Therefore, is important, if possible, to keep the number of boxes
   on each level balanced to maximize the use of the allocated resources.

Writting a Job Script:
^^^^^^^^^^^^^^^^^^^^^^

In order to make our life easier, instead of submitting an allocation
command line, loading the modules, setting the threads/MPI process,
and writing another command line to submit our jobs, we can make an
script to pack all these command into one executable ``.sh`` file,
that can be submitted via ``bsub`` just once.

We start our job script, summoning the shell with the statement
``!/bin/bash``. Then we add the ``bsub`` allocations flags, starting
with ``#BSUB`` as follows:

.. code-block:: bash

   #!/bin/bash
   #BSUB -P ast106
   #BSUB -W 2:00
   #BSUB -nnodes 80
   #BSUB -alloc_flags smt1
   #BSUB -J luna_script
   #BSUB -o luna_output.%J
   #BSUB -e luna_sniffing_output.%J

In addition we add the modules statements, fixing only one thread per MPI process:

.. code-block::

   module load gcc/10.2.0
   module load cuda/11.5.2
   module load python

   export OMP_NUM_THREADS=1

and define the environment variables:

.. code-block::

   CASTRO=./Castro2d.gnu.MPI.CUDA.ex
   INPUTS=inputs_luna

   n_res=480                # The max allocated number of resource sets is
   n_cpu_cores_per_res=1    # nnodes * n_max_res_per_node. In this case we will
   n_mpi_per_res=1          # use all the allocated resource sets to run the job
   n_gpu_per_res=1          # below.
   n_max_res_per_node=6

Once the allocation ends, the job is downgraded/killed, leaving us as we started. As we pointed out, the maximum allocation
time in Summit is 03:00 (three hours), but, we may need sometimes weeks, months, or maybe years to complete
our runs. Now is when the automatic restarting section of the script comes to our salvation.

From here we can add an optional (or mandatory) setting to our script. As the code executes,
after a certain number of timesteps, the code creates checkpoint files of the form ``chkxxxxxxx``, ``chkxxxxxx``
or ``chkxxxxx``. This checkpoint files can be read by our executable and run from the simulation time where
the checkpoint was created. This is implemented as follows:

.. code-block::

   function find_chk_file {
      # find_chk_file takes a single argument -- the wildcard pattern
      # for checkpoint files to look through
      chk=$1

      # find the latest 2 restart files.  This way if the latest didn't
      # complete we fall back to the previous one.
      temp_files=$(find . -maxdepth 1 -name "${chk}" -print | sort | tail -2)
      restartFile=""
      for f in ${temp_files}
      do
         # the Header is the last thing written -- if it's there, update the restart file
         if [ -f ${f}/Header ]; then
            restartFile="${f}"
         fi
      done
   }

   # look for 7-digit chk files
   find_chk_file "*chk???????"

   if [ "${restartFile}" = "" ]; then
      # look for 6-digit chk files
      find_chk_file "*chk??????"
   fi

   if [ "${restartFile}" = "" ]; then
      # look for 5-digit chk files
      find_chk_file "*chk?????"
   fi

   # restartString will be empty if no chk files are found -- i.e. new run
   if [ "${restartFile}" = "" ]; then
      restartString=""
   else
      restartString="amr.restart=${restartFile}"
   fi

The function ``find_chk_file`` searches the submission directory for
checkpoint files.  Because AMReX appends digits as the number of steps
increase (with a minimum of 5 digits), we search for files with
7-digits, 6-digits, and then finally 5-digits, to ensure we pick up
the latest file.

We can also ask the job manager to send a warning signal some amount
of time before the allocation expires by passing ``-wa 'signal'`` and
``-wt '[hour:]minute'`` to ``bsub``.  We can then have bash create a
``dump_and_stop`` file when it receives the signal, which will tell
Castro to output a checkpoint file and exit cleanly after it finishes
the current timestep.  An important detail that I couldn't find
documented anywhere is that the job manager sends the signal to all
the processes in the job, not just the submission script, and we have
to use a signal that is ignored by default so Castro doesn't
immediately crash upon receiving it.  SIGCHLD, SIGURG, and SIGWINCH
are the only signals that fit this requirement and of these, SIGURG is
the least likely to be triggered by other events.

.. code-block:: bash

   #BSUB -wa URG
   #BSUB -wt 2

   ...

   function sig_handler {
      touch dump_and_stop
      # disable this signal handler
      trap - URG
      echo "BATCH: allocation ending soon; telling Castro to dump a checkpoint and stop"
   }
   trap sig_handler URG

We use the ``jsrun`` command to launch Castro on the compute nodes. In
order for bash to handle the warning signal before Castro exits, we
must put ``jsrun`` in the background and use the shell builtin
``wait``:

.. code-block:: bash

   jsrun -n$n_res -c$n_cpu_cores_per_res -a$n_mpi_per_res -g$n_gpu_per_res -r$n_max_res_per_node $CASTRO $INPUTS ${restartString} &
   wait
   # use jswait to wait for Castro (job step 1/1) to finish and get the exit code
   jswait 1

Finally, once the script is completed and saved as ``luna_script.sh``, we can submit it by:

.. prompt:: bash

   bsub luna_script.sh


Monitoring a Job:
^^^^^^^^^^^^^^^^^

You can monitor the status of your jobs using ``bjobs``. Also, a slightly nicer view of your jobs can be viewed using ``jobstat`` as:

.. prompt:: bash

   jobstat -u username


Script Template:
^^^^^^^^^^^^^^^^

Packing all the information before, lead us to the following script template

.. literalinclude:: ../../job_scripts/summit/summit_template.sh
   :language: sh
   :linenos:


Chaining jobs
^^^^^^^^^^^^^

The script ``job_scripts/summit/chain_submit.sh`` can be used to setup job dependencies,
i.e., a job chain.

First you submit a job as usual using ``bsub``, and make note of the
job-id that it prints upon submission (the same id you would see with
``bjobs`` or ``jobstat``).  Then you setup N jobs to depend on the one
you just submitted as:

.. prompt:: bash

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
via SLURM:

.. prompt:: bash

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

#. Launch the script via:

   .. prompt:: bash

      sbatch summit_hpss.submit

   It will for the full time you asked, searching for plotfiles as
   they are created and moving them to HPSS as they are produced (it
   will always leave the very last plotfile alone, since it can't tell
   if it is still being written).


Files may be unarchived in bulk from HPSS on OLCF systems using the
``hpss_xfer.py`` script, which is available in the job_scripts
directory. It requires Python 3 to be loaded to run. The command:

.. prompt:: bash

   ./hpss_xfer.py plt00000 -s hpss_dir -o plotfile_dir

will fetch ``hpss_dir/plt00000.tar`` from the HPSS filesystem and
unpack it in ``plotfile_dir``. If run with no arguments in the problem
launch directory, the script will attempt to recover all plotfiles
archived by ``process.titan``. Try running :code:`./hpss_xfer.py --help`
for a description of usage and arguments.



Frontier
--------

Machine details
^^^^^^^^^^^^^^^

Queue policies are here:
https://docs.olcf.ornl.gov/systems/frontier_user_guide.html#scheduling-policy


Filesystem is called ``orion``, and is Lustre:
https://docs.olcf.ornl.gov/systems/frontier_user_guide.html#data-and-storage


Submitting jobs
^^^^^^^^^^^^^^^

Frontier uses SLURM.

Here's a script that runs with 2 nodes using all 8 GPUs per node:

.. code:: bash

   #!/bin/bash
   #SBATCH -A AST106
   #SBATCH -J testing
   #SBATCH -o %x-%j.out
   #SBATCH -t 00:05:00
   #SBATCH -p batch
   # here N is the number of compute nodes
   #SBATCH -N 2
   #SBATCH --ntasks-per-node=8
   #SBATCH --cpus-per-task=7
   #SBATCH --gpus-per-task=1
   #SBATCH --gpu-bind=closest

   EXEC=Castro3d.hip.x86-trento.MPI.HIP.ex
   INPUTS=inputs.3d.sph

   module load PrgEnv-gnu craype-accel-amd-gfx90a cray-mpich rocm/5.3.0
   module load amd-mixed/5.3.0

   export OMP_NUM_THREADS=1
   export NMPI_PER_NODE=8
   export TOTAL_NMPI=$(( ${SLURM_JOB_NUM_NODES} * ${NMPI_PER_NODE} ))

   srun -n${TOTAL_NMPI} -N${SLURM_JOB_NUM_NODES} --ntasks-per-node=8 --gpus-per-task=1 ./$EXEC $INPUTS


.. note::

   As of June 2023, it is necessary to explicitly use ``-n`` and ``-N`` on the ``srun`` line.

The job is submitted as:

.. prompt:: bash

   sbatch frontier.slurm

where ``frontier.slurm`` is the name of the submission script.

A sample job script that includes the automatic restart functions can be found here:
https://github.com/AMReX-Astro/workflow/blob/main/job_scripts/frontier/frontier.slurm


Also see the WarpX docs: https://warpx.readthedocs.io/en/latest/install/hpc/frontier.html


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





Troubleshooting
^^^^^^^^^^^^^^^

Workaround to prevent hangs for collectives:

::

 export FI_MR_CACHE_MONITOR=memhooks


Some AMReX reports are that it hangs if the initial Arena size is too big, and we should do

::

  amrex.the_arena_init_size=0

The arena size would then grow as needed with time.  There is a suggestion that if the size is
larger than
