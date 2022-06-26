Batch Visualization on Andes
============================

It is best to work on ``andes.olcf.ornl.gov``.  You will want to setup
a new env for andes.  We'll call it ``andes_env``.

You need to load python with anaconda support there:

.. prompt:: bash

   module load python/3.7-anaconda3

then setup ``conda``:

.. prompt:: bash

   conda init bash

this will modify your `.bashrc`, adding code that is specific to andes.

Then you do:

.. prompt:: bash

   conda create -n andes_env -y ipykernel nb_conda_kernels
   conda install -n andes_env -c conda-forge yt

.. note::

   If you want to install yt from source, then you would first clone
   the yt repo:

   .. prompt:: bash

      git clone git@github.com:yt-project/yt

   Then in the top-level ``yt/`` directory, do:

   .. prompt:: bash

      pip install -e .

   If you have an existing yt installation, you can uninstall it first via:

   .. prompt:: bash

      pip uninstall yt


Finally, you can activate the environment as:

.. prompt:: bash

   source activate andes_env

Then you can run a python script that does visualization as with the
following submission script::

    #!/bin/bash
    #SBATCH -A ast106
    #SBATCH -J plots
    #SBATCH -N 1
    #SBATCH -t 2:00:00

    cd $SLURM_SUBMIT_DIR

    source activate andes_env

    srun python vol-xrb-enuc.py flame_wave_1000Hz_25cm_smallplt203204

Here ``vol-xrb-enuc.py`` is the script with the ``yt`` code to make the visualization.
This is then submitted to SLURM via ``sbatch``.

.. note::

   For very large plotfiles, it might run out of memory when doing the
   visualization.  A solution is to use the ``gpu`` nodes on Andes,
   which have more memory.  This is accomplished by adding
   ``#SBATCH -p gpu`` to the script.
