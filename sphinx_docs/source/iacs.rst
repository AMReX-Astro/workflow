.. highlight:: bash

***************
Working at IACS
***************

Ookami
======

Ookami seems to have 48 compute cores grouped into 4 pools of 12
threads (there is actually a 13th core on each for OS stuff).  So an
ideal config would be running 4 MPI each with 12 threads.



Cray compilers
==============

You can only access the Cray environment on a compute note:
```
  srun -p short -N 1 -n 48 --pty bash

```

There are 2 sets of Cray compilers, ``cce`` and ``cce-sve``.  The
former are the newer LLVM-based ocompilers, but the Fortran compiler
does not seem to support the ARM architecture.  The latter are the
older compilers.  Even though both have version numbers of the form
``10.0.X``, they have different options.

(see https://www.stonybrook.edu/commcms/ookami/faq/getting-started-guide.php)

Setup the environment
```
module load CPE
module load cray-mvapich2_nogpu/2.3.4
```

This should load the older ``cce-sve`` compilers (``10.0.1``).

AMReX needs to have the options changed slightly.  Edit
``amrex/Tools/GNUmake/comps/cray.mak`` and comment out the
``-std=$(CXXSTD)`` flag and the ``-ffast-math`` flag -- it is not recognized.

 You can then build via:
```
make COMP=cray -j 24 DEPFLAGS=-M
```

Note: compiling takes a long time.

