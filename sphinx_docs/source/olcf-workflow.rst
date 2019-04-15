.. highlight:: bash

Managing Jobs at OLCF
=====================


Error: aprun not found
======================

It is possible (on Titan) that some aspect of the environment on job
submission can lead to the job failing with the following error::

  XALT Error: unable to find aprun

Bill Renaud at OLCF advised adding the `-l` shell argument in the
script shebang line. This did not work for the `ksh` shell but does
work for `bash` as::

  #!/bin/bash -l

This allows the job to run for the PBS script submitted from either
`bash` or `zsh`.
