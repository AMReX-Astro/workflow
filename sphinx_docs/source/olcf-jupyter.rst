.. highlight:: bash

Running Jupyter Remotely from OLCF
==================================

Here we shall outline how to run jupyter notebooks remotely on Summit. These instructions are for jupyter lab, but should work for jupyter notebooks as well by exchanging ``lab`` for ``notebook``. 

Launching on the compute node
-----------------------------

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

    Copy/paste this URL into your browser when you connect for the first time,
    to login with a token:
    http://login1:8888/?token=kjadhsf8yw9oayfhdfya98wyfhs98hafshuihyf8ohauiuah

Copy and paste the bit after ``token=``. When in your jupyter session, make sure to create a notebook with your ``my_env`` kernel (rather than the default Python 3 kernel). 


Launching from an interactive job
---------------------------------

It's probably not a good idea to do any heavy visualization on the login nodes, so instead we're going to run the notebook in an interactive job. This assumes that you've already followed the first 2 steps of the previous section to create the conda environment.

1. First submit your interactive job, e.g. this will launch a job on 1 node for 30 minutes::

    bsub -W 0:30 -nnodes 1 -P ast106 -Is /bin/bash


2. For some reason, if you just try to launch a jupyter session on the compute node, it will give you an error like::

    PermissionError: [Errno 13] Permission denied: '/run/user/12746'

We can get around this by setting ``export XDG_RUNTIME_DIR=""``. 

3. Now we're going to launch the jupyter session as before::

    jupyter-lab --no-browser --ip="batch1" > jupyter.log 2>&1 &

(make sure the ``--ip=`` refers to the compute node you're on).

4. Create an ssh tunnel that first connects to the login node, then from there connects to the compute node::

    ssh -t -t username@summit.olcf.ornl.gov -L localhost:8888:localhost:8888 ssh login1 -L 8888:batch1:8888

(for the second ``ssh login1``, make sure that this corresponds to the login node from which you launched the interactive job). 

5. Now navigate to ``localhost:8888`` in your browser. You can find the token by looking in the ``jupyter.log`` file into which we redirected the jupyter session output in step 3. 

Note: it may be that you run into some issues launching a notebook with your ``my_env`` kernel. If this happens, try uninstalling and reinstalling ``pyzmq``: ``conda uninstall pyzmq``, ``conda install pyzmq``. If it uninstalls any other modules when you do this, make sure to reinstall them as well. 