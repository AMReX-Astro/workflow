#!/usr/bin/env python3

import sys
import os
import glob
import subprocess
import argparse

desc = \
"""
Script for transferring plotfiles over from HPSS using htar. It should be run in the launch
directory for the problem. It optionally takes a list of plotfile basenames (without the .tar) - if
no plotfiles are supplied it will look for a "plotfiles" subdirectory and copy everything in there.
The destination directory is called hpss_data by default (it will be created if it doesn't exist),
but that may be overwritten with a command line argument. The name of the source directory on HPSS
is taken to be the name of the current working directory by default, and is also overridable.
"""

filenames_help = "Names of plotfiles to transfer. Will look for a 'plotfiles' subdirectory and "\
        + "use the filenames in there if none are supplied."
output_help = "Name of the subdirectory to copy files to. Defaults to 'hpss_data'."
source_help = "Name of HPSS directory to copy from. Will use the name of the current working "\
        + "directory by default."

# Process arguments
parser = argparse.ArgumentParser(description=desc)
parser.add_argument('filenames', nargs='*', help=filenames_help)
parser.add_argument('-o', '--output_dir', default="hpss_data", help=output_help)
parser.add_argument('-s', '--source_dir', help=source_help)
args = parser.parse_args()

# Set filenames and directories
cwd = os.getcwd()

if args.source_dir:
    dirname = args.source_dir
else:
    dirname = os.path.basename(cwd.rstrip("/"))

if not args.filenames:
    plotfile_dir = os.path.join(cwd, "plotfiles")
    pfiles = glob.glob(plotfile_dir + "/*plt*")
else:
    pfiles = args.filenames
    
dest_dir = os.path.join(cwd, args.output_dir)
# Make destination directory if it doesn't exist
if not os.path.exists(dest_dir): os.mkdir(dest_dir)

# Now switch directories and unpack
os.chdir(dest_dir)
    
for pfile in pfiles:
        
    fname = os.path.basename(pfile.rstrip("/"))
    tarfile = os.path.join(dirname, fname + ".tar")
    # Execute htar -xvf for each plotfile 
    subprocess.run(["htar", "-xvf", tarfile])
