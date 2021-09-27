Visualization at NERSC
======================

You need to install `yt`.  The best way to do this is to setup your own conda environment,
following the steps here:

https://docs.nersc.gov/development/languages/python/nersc-python/

in particular, something like::

    module load python
    conda init
    conda create --name myenv python=3.8
    conda activate myenv

then you can install yt as::

    conda install yt

to deactivate conda, do::

    conda deactivate


