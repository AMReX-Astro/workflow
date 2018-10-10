Working at NERSC
================

Edison
------


Intel
^^^^^

Intel is the default programming environment on edison and appear to
be the preferred compilers.  The Intel 18.0.2 compilers seem to work
well at NERSC.  These are not currently the default, so you will need
to do a ``module swap`` to load them.  Note: 18.0.1 do not seem to work.


Cray
^^^^

No current information.


GNU
^^^

You need to swap environments::

  module swap PrgEnv-{intel,gnu}

There are no known issues with GNU.


Hypre
^^^^^

On Edison, the Cray _Third Party Scientific Libraries_ provide ``hypre``
in a form that works directly with the compiler wrappers used on that
machine (``CC``, ``ftn``, ...).  To use this, simply do::

  module load cray-tpsl

There is no need to set ``HYPRE_DIR``, but note however that the
dependency checker script (``BoxLib/Tools/C_scripts/mkdep``) will
complain about::

  /path/to/Hypre--with-openmp/include does not exist

This can be ignored an compilation will finish.  If you do wish to
silence it, you can set ``HYPRE_DIR`` to the path shown by::

  module show cray-tpsl

as::

  export HYPRE_DIR=${CRAY_TPSL_PREFIX_DIR}

This path will change dynamically to reflect which compiler programming
environment you have loaded.  (You can also see that this is the path
sent to the compilation by doing ``ftn -craype-verbose``).



Preferred configuration
^^^^^^^^^^^^^^^^^^^^^^^

There are 24 cores per node on Edison.  Generally, using 4 or 6 OpenMP
threads with 6 or 4 MPI tasks works best.






Cori Haswell
------------



Cori KNL
--------

Regardless of the compiler, you need to swap the compiler weappers to
use the AVX-512 instruction set supported on the Intel Phi processors
(instead of the AVX-2 on the Haswell chips).  This is done as::

  module swap craype-{haswell,mic-knl}

It could happen that even when the various verbosities are set to 0,
when using several nodes (more than 64) in a run compiled with Intel,
the follwing error shows::

  forrtl: severe (40): recursive I/O operation, unit -1, file unknown

Seems like the error is due to all threads printing to stdout. Adding
the following to the ``inputs`` file, prevents this error to occur::

  castro.print_fortran_warnings = 0


Intel
^^^^^

When running MAESTROeX, we seem to need::

  amrex.signal_handling = 0

otherwise we get an ``Erroneous arithmetic error``.

