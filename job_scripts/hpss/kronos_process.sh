#!/bin/bash
# error out if we try to use an unset variable
set -u
# error out immediately if any command exits with a non-zero code
set -e

#----------------------------------------------------------------------------
# user modifiable variables:

# jobidfile is a lock file that is used to make sure that only one instance
# of this script is working on the current directory
jobidfile=process.jobid


# set the prefix of the plotfiles and checkpoint files (passed to find(1) -name)
plt_prefix='*plt'
chk_prefix='*chk'

# directory to archive to on Kronos -- set this to the working directory
work_dir=$(pwd)

# destination subdirectory under your Kronos user directory -- change this if desired
dest_dir=$(basename "$work_dir")

# path to the ftime executable -- used for making a simple ftime.out file
# listing the name of the plotfile and its simulation time
FTIME_EXE=ftime.gnu.ex

#----------------------------------------------------------------------------
# helper variables

# full path to the destination directory
KRONOS_DIR=/nl/kronos/olcf/ast106/users/$USER/$dest_dir

#----------------------------------------------------------------------------
# initialization stuff

# check to make sure that the lock file does not already exist.
if [ -f "$jobidfile" ]; then
  # check if job is still running
  existing_job=$(<"$jobidfile")
  if [ "$(sacct -X -P -n -o State -j "$existing_job")" != RUNNING ]; then
    echo "process: removing stale lock file for job $existing_job"
    rm "$jobidfile"
  else
    echo 2>&1 "process job $existing_job is still running"
    exit 2
  fi
fi

# create the lock file
echo "$SLURM_JOB_ID" > "$jobidfile"

# if our process is killed, remove the lock file first
function cleanup() {
  echo "process: received signal; removing $jobidfile"
  command rm -f "$jobidfile"
  # remove the EXIT handler, since we only want to do this once
  trap - EXIT
  # don't exit, so we can finish the current operation:
  # $jobidfile is checked at the start of each loop iteration in process_files()
}
trap cleanup EXIT HUP INT QUIT TERM XCPU

# Number of seconds to sleep before checking again.
N=60

# do a single pass then exit if the user passes "once" on the command line
keep_running=y
if [[ $# -gt 0 ]] && [[ $1 == once ]]; then
  keep_running=n
fi


#----------------------------------------------------------------------------
# make storage directories

# once we process a file, we will move the plotfiles into the plotfiles/
# directory.  This then hides them from the script, so if the system
# later purges the files in the pltXXXXX directory and the .processed
# file, we don't overwrite our archived data with a tarred empty
# directory structure.  We do the same with the checkpoint files (using
# checkfiles/)

if [ ! -d plotfiles ]; then
  mkdir plotfiles
fi

if [ ! -d checkfiles ]; then
  mkdir checkfiles
fi


#----------------------------------------------------------------------------
# the processing function

# Process Files.  Once a plotfile is successfully processed, we will output
# a file pltXXXXX.processed (checkpoint files are only archived, with a
# chkXXXXX.processed file appearing once the archiving is successful).
# Subsequent invocations of this routine will skip over any plotfiles or
# checkpoint files that have a corresponding .processed file.


function process_files
{
  if [ ! -f "$jobidfile" ]; then
    echo "process: $jobidfile has been removed, exiting"
    exit
  fi

  # plotfiles

  # Take all but the final plt file -- we want to ensure they're completely
  # written to disk.  Strip out any tar files that are lying around as well
  # as pltXXXXX.processed files.  We restrict the find command to a depth of
  # 1 to avoid catching any already-processed files in the plotfiles/
  # directory
  mapfile -t pltlist < <(
    find . -maxdepth 1 -type d -name "${plt_prefix}"'?????' -print | sort
    find . -maxdepth 1 -type d -name "${plt_prefix}"'??????' -print | sort
    find . -maxdepth 1 -type d -name "${plt_prefix}"'???????' -print | sort
  )

  if (( ${#pltlist[@]} > 1 )); then
    # Don't process the final plt file
    unset 'pltlist[-1]'

    for dir in "${pltlist[@]}"
    do
      if ! [[ -f "$jobidfile" ]]; then
        echo "process: $jobidfile has been removed, exiting"
        exit
      fi
      if [[ -d "${dir}" ]]; then

        # only work on the file if there is not a .processed file in the
        # main directory or the plotfiles/ directory
        if ! [[ -f "${dir}.processed" ]] && ! [[ -f "plotfiles/${dir}.processed" ]]; then

          # do processing
          echo "archiving ${dir} to Kronos"

          # store the file on Kronos
          if tar -cvf "${KRONOS_DIR}/${dir}.tar" "${dir}" > "${dir}.log"; then

            # mark this file as processed so we skip it next time
            date > "${dir}.processed"

            # output the plotfile name and simulation time to ftime.out
            # TODO: we should update this file in diag_files_${datestr}.tar
            if command -v "${FTIME_EXE}" > /dev/null; then
              "${FTIME_EXE}" "${dir}" >> ftime.out
            fi

            # store the log file along with the archive
            mv "${dir}.log" "${KRONOS_DIR}"

            # move the plotfile into the plotfiles directory
            mv "${dir}" plotfiles/

            # ..and the corresponding .processed file too.
            mv "${dir}.processed" plotfiles/

            # and visualize it
            #runtimevis.py "plotfiles/${dir}"

          fi

        fi   # end test of whether plotfile already processed

      fi   # end test of whether plotfile is a directory (as it should be)

    done
  fi


  # checkpoint files

  # Take all but the final chk file -- we want to ensure they're completely
  # written to disk.  Strip out any tar files that are lying around as well
  # as chkXXXXX.processed files.  We restrict the find command to a depth of
  # 1 to avoid catching any already-processed files in the checkfiles/
  # directory
  mapfile -t chklist < <(
    find . -maxdepth 2 -type f -path "${chk_prefix}"'?[05]000/Header' -printf '%h\n' | sort
    find . -maxdepth 2 -type f -path "${chk_prefix}"'??[05]000/Header' -printf '%h\n' | sort
    find . -maxdepth 2 -type f -path "${chk_prefix}"'???[05]000/Header' -printf '%h\n' | sort
  )

  if (( ${#chklist[@]} > 1 )); then
    # Don't process the final chk file
    unset 'chklist[-1]'

    for dir in "${chklist[@]}"
    do
      if ! [[ -f "$jobidfile" ]]; then
        echo "process: $jobidfile has been removed, exiting"
        exit
      fi
      if [[ -d "${dir}" ]]; then

        if ! [[ -f "${dir}.processed" ]] && ! [[ -f "checkfiles/${dir}.processed" ]]; then

          echo "archiving ${dir} to Kronos"

          # store the file on Kronos
          if tar -cvf "${KRONOS_DIR}/${dir}.tar" "${dir}" > "${dir}.log"; then

            # mark this file as processed so we skip it next time
            date > "${dir}.processed"

            # store the log file along with the archive
            mv "${dir}.log" "${KRONOS_DIR}"

            # move the checkpoint file into the checkfiles directory
            mv "${dir}" checkfiles/

            # ..and the corresponding .processed file too.
            mv "${dir}.processed" checkfiles/

          fi

        fi

      fi
    done
  fi

}


#----------------------------------------------------------------------------
# the main function

# archive any diagnostic files first -- give them a unique name, appending
# the date string, to make sure that we don't overwrite anything
datestr=$(date +"%Y%m%d_%H%M_%S")
mapfile -t all_files < <(
  find . -maxdepth 1 -name '*.hse.*' -print    # model files
  find . -maxdepth 1 -name 'ftime.out' -print  # ftime files
  find . -maxdepth 1 -name '*_diag.out' -print # diag files
  find . -maxdepth 1 -name 'inputs*' -print    # inputs files
  find . -maxdepth 1 -name 'probin*' -print    # probin files
  find . -maxdepth 1 -name '*.slurm' -print    # job scripts
  find . -maxdepth 1 -name '*.submit' -print   # job scripts
  find . -maxdepth 1 -name 'process*' -print   # process scripts
)

# create the destination directory if it doesn't already exist
mkdir -p "$KRONOS_DIR"

tar -cvf "${KRONOS_DIR}/diag_files_${datestr}.tar" "${all_files[@]}"


# Loop, waiting for plt and chk directories to appear.

while true
do
  process_files
  if [[ $keep_running == n ]]; then
    break
  fi
  # allow signals to be handled while sleeping
  sleep $N &
  wait
done
