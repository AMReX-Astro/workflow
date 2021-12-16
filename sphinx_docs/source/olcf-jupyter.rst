.. highlight:: bash

Running Jupyter Remotely from OLCF
==================================

To run Jupyter remotely at OLCF, you can use the `OLCF JupyterHub <https://jupyter.olcf.olrl.gov>`_, as described in the `OLCF Jupyter documentation <https://docs.olcf.ornl.gov/services_and_applications/jupyter/overview.html#jupyter-at-olcf>`_. In order to use extra python libraries (e.g. ``yt``), it's best to first install these as part of a conda environment, which can then be loaded when you create your Jupyter notebook.

Creating a conda environment
----------------------------

If you wish to install extra python libraries (e.g. ``yt``), then they can be installed using a conda environment. To do this, make sure you have the correct python module loaded on Summit (e.g. ``module load python/3.7.0-anaconda3-5.3.0``), and create a new conda environment with the modules you require installed. At this point, it's also a good idea to make sure this environment has the libraries ``ipykernel`` and ``nb_conda_kernels``::

    conda create -n my_env -y ipykernel nb_conda_kernels
    conda install -n my_env -c conda-forge yt 
    conda install -n my_env jupyterlab

.. note::

   To use the conda environment for python subsequently, you do not need to do ``module load python/3.7.0-anaconda3-5.3.0``

.. note::

   yt is distributed via ``conda-forge``, you can add this channel to your conda search via::

      conda config --add channels conda-forge


Batch Visualization on Andes
============================

It is best to work on ``andes.olcf.ornl.gov``.  You will want to setup
a new env for andes.  We'll call it ``andes_env``.

You need to load python with anaconda support there::

   module load python/3.7-anaconda3

then setup ``conda``::

   conda init bash

this will modify your `.bashrc`, adding code that is specific to andes.

Then you do::

   conda create -n andes_env -y ipykernel nb_conda_kernels
   conda install -n andes_env -c conda-forge yt

Note: this will install its own version of python, so you don't need
to load the python module any more after this.

Finally, you can activate the environment as::

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

