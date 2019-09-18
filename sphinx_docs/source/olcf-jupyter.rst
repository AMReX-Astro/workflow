.. highlight:: bash

Running Jupyter Remotely from OLCF
==================================

Here we shall outline how to run jupyter notebooks remotely on Summit. These instructions are for jupyter lab, but should work for jupyter notebooks as well by exchanging ``lab`` for ``notebook``. 

1. If you wish to install extra python libraries (e.g. ``yt``), then they can be installed using a conda environment. To do this, make sure you have the correct python module loaded on Summit (e.g. ``module load python/3.7.0-anaconda3-5.3.0``), and create a new conda environment with the modules you require installed. At this point, it's also a good idea to make sure this environment has the libraries ``ipykernel`` and ``nb_conda_kernels``::

    conda create -n my_env -y ipykernel nb_conda_kernels
    conda install -n my_env -c conda_forge yt 

2. Next, we need to make sure that the environment will be available when we launch our jupyter session::

    conda activate my_env
    ipython kernel install --user --name=my_env
    conda deactivate my_env 

3. Now we should be ready to launch our jupyter session. From Summit, launch a ``no-browser`` session::

    [username@login1.summit ~]$ jupyter lab --no-browser --ip="login1"

(note if you're on a different node, be sure to change the ``--ip=`` bit to reflect that).

4. We can now connect to this from our local workstation::

    ssh -N -L localhost:8888:login1:8888 username@summit.olcf.ornl.gov

This will prompt you for your Summit password. If all goes well, it should not print any messages once you hit enter. 

5. Finally, open up ``localhost:8888`` in your browser. This will prompt you for the token of the jupyter session. You can find this by looking back to when you first launched the jupyter session on Summit. Amongst the output, you should see something like::

    The Jupyter Notebook is running at:
    http://login1:8888/?token=kjadhsf8yw9oayfhdfya98wyfhs98hafshuihyf8ohauiuah

Copy and paste the bit after ``token=``. 
