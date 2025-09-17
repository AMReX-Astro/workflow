
******************
Linux Workstations
******************

In general GCC 10.x works well on Linux workstations.



Remote vis with Jupyter
=======================

You can connect to Jupyter on ahsoka via ssh to do remote visualization.

On ahsoka:

* Install jupyter and yt (if you don't already have them)::

    pip install jupyterlab
    pip install yt

* Start up jupyter on the remote (ahsoka) machine::

    jupyter lab --no-browser --ip=127.0.0.1

  when you do this, it will output a lot to the screen, but
  look for a line that starts like::

    http://127.0.0.1:8888/lab?token=8469f3fb822e2a32c94...

  The ``8888`` there is the port.  If that is being used, Jupyter
  will pick a higher one.  Make note of the number it picked.

* On your local workstation do::

    ssh -N -L 8888:127.0.0.1:8888 ahsoka.astro.sunysb.edu

  replacing the ``8888`` with the port it selected.  Then enter your
  password.  There will be no output---that command will just continue
  to run in the terminal window.

  .. tip::

     This says that port ``8888`` on your local machine will connect (via
     SSH tunnel) to ``127.0.0.1:8888`` on the remote machine.  Here
     ``127.0.0.1`` is the *loopback address* (the IP address on the
     remote machine that resolves to itself)

  If you get an error like::

    bind [127.0.0.1]:8888: Address already in use
    channel_setup_fwd_listener_tcpip: cannot listen to port: 8888
    Could not request local forwarding.

  then that means that you are running Jupyter already on your local
  machine, and it is already using port ``8888``, so kill the local
  instance of Jupyter and try again.

* Finally, on your local machine, point your web browser to the URL
  output on ahsoka (we referenced this above as ``http://127.0.0.1:8888/lab?token=8469f3fb822e2a32c94...``

  This should open the Jupyter server on the remote machine in your
  local browser.

