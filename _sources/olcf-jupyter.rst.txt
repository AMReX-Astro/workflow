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
