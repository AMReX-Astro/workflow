Visualization at NERSC
======================

You need to install `yt`.  The best way to do this is to setup your own conda environment,
following the steps here:

https://docs.nersc.gov/development/languages/python/nersc-python/

in particular, something like::

    module load python
    conda init
    conda create --name myenv python=3.11
    conda activate myenv

then you can install yt as::

    conda install yt

or for a more recent yt::

    conda install -c conda-forge yt

to deactivate conda, do::

    conda deactivate


A sample submission script to run a python script on 1 CPU on 1 node is:

.. code::

   #!/bin/bash

   #SBATCH -A m3018
   #SBATCH -C cpu
   #SBATCH -J vis
   #SBATCH -o vis_%j.out
   #SBATCH -t 0:01:00
   #SBATCH -N 1
   #SBATCH -c 1
   #SBATCH --ntasks-per-node=1
   #SBATCH -q regular

   export OMP_NUM_THREADS=8
   export OMP_PLACES=cores
   export OMP_PROC_BIND=spread

   module load python
   conda activate myenv

   srun python massive_star_multi.py plt19862
