.. highlight:: bash

***************
Working at IACS
***************

Ookami
======

Ookami seems to have 48 compute cores grouped into 4 pools of 12
threads (there is actually a 13th core on each for OS stuff).  So an
ideal config would be running 4 MPI each with 12 threads.

Log-in to ``login.ookami.stonybrook.edu``

AMReX setup
-----------

We need to tell AMReX about the machine.  Put the following ``Make.local`` file
in ``amrex/Tools/GNUmake``:

https://raw.githubusercontent.com/AMReX-Astro/workflow/main/job_scripts/iacs/Make.local


Cray compilers
--------------

You can only access the Cray environment on a compute note:

::

  srun -p short -N 1 -n 48 --pty bash


.. note::

   The interactive slurm job times out after 1 hour.  You can run for
   infinite time on the ``fj-debug1`` and ``fj-debug2`` nodes (you can
   ssh to them).


There are 2 sets of Cray compilers, ``cce`` and ``cce-sve``.  The
former are the newer LLVM-based ocompilers, but the Fortran compiler
does not seem to support the ARM architecture.  The latter are the
older compilers.  Even though both have version numbers of the form
``10.0.X``, they have different options.

(see https://www.stonybrook.edu/commcms/ookami/faq/getting-started-guide.php)

Setup the environment

::

  module load CPE
  #module load cray-mvapich2_nogpu/2.3.4

This should load the older ``cce-sve`` compilers (``10.0.1``).

The latest AMReX has an if test in the ``cray.mak`` file that recognizes
the older Cray compiler on this ARM architecture and switches to using
the old set of compiler flags, so it should work.


You can then build via:

::

  make COMP=cray -j 24 DEPFLAGS=-M USE_MPI=FALSE


.. note::

   Compiling takes a long time.  At the moment, we do not link with
   MPI, with a ``cannot find nopattern`` error (which is why that
   module is commented out above).



GCC
---

GCC 10.2
^^^^^^^^

This needs to be done on the compute notes.

Load modules as:

::

  module load slurm
  module load /lustre/projects/global/software/a64fx/modulefiles/gcc/10.2.1-git
  module load /lustre/projects/global/software/a64fx/modulefiles/mvapich2/2.3.4

Build as

::

  make -j 24 USE_MPI=TRUE USE_OMP=TRUE

Note, this version of GCC knows about the A64FX chip, and that ``Make.local`` adds
the architecture-specific compilations flags.

To run on an interactive node, on 1 MPI * 12 OpenMP, do::

   export MV2_ENABLE_AFFINITY=0
   export OMP_NUM_THREADS=12
   mpiexec -n 1 ./Castro3d.gnu.MPI.OMP.ex inputs.3d.sph amr.max_level=2 max_step=5


