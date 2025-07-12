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


# set the prefix of the plotfiles and checkpoint files (a fnmatch(3) pattern)
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
if [[ "${SLURM_JOB_ID:-}" ]]; then
   echo "$SLURM_JOB_ID" > "$jobidfile"
else
   echo $$ > "$jobidfile"
fi

# if our process is killed, remove the lock file first
function cleanup() {
  echo "process: removing $jobidfile"
  command rm -f "$jobidfile"
  # remove the EXIT handler, since we only want to do this once
  trap - EXIT
  # don't exit, so we can finish the current operation:
  # $jobidfile is checked at the start of each loop iteration in process_files()
}
function cleanup_killed() {
  echo "process: received signal; stopping"
  cleanup
}
trap cleanup_killed HUP INT QUIT TERM XCPU
trap cleanup EXIT

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

# this function does all the actual data transfer, and is run in parallel
function process_single_file
{
  local dir=$1
  local job_slot=$2

  local done_dir
  # right-hand side is not quoted, as we want it to be treated as a pattern
  if [[ $dir == ${plt_prefix}* ]]; then
    done_dir=plotfiles
  elif [[ $dir == ${chk_prefix}* ]]; then
    done_dir=checkfiles
  fi

  if ! [[ -f "$jobidfile" ]]; then
    echo "$job_slot | process: $jobidfile has been removed, exiting"
    exit
  fi
  if [[ -d "${dir}" ]]; then

    # only work on the file if there is not a .processed file in the
    # main directory or the plotfiles/ directory
    if ! [[ -f "${dir}.processed" ]] && ! [[ -f "${done_dir}/${dir}.processed" ]]; then

      # do processing
      printf '%2d | archiving %s to Kronos\n' "$job_slot" "$dir"

      # store the file on Kronos
      if tar -cvf "${KRONOS_DIR}/${dir}.tar" "${dir}" > "${dir}.log"; then

        # mark this file as processed so we skip it next time
        date > "${dir}.processed"

        if [[ $done_dir == plotfiles ]]; then
          # output the plotfile name and simulation time to ftime.out
          # TODO: we should update this file in diag_files_${datestr}.tar
          if command -v "${FTIME_EXE}" > /dev/null; then
            "${FTIME_EXE}" "${dir}" >> ftime.out
          fi
        fi

        # store the log file along with the archive
        mv "${dir}.log" "${KRONOS_DIR}"

        # move the file into the transferred directory
        mv "${dir}" "$done_dir"

        # ..and the corresponding .processed file too.
        mv "${dir}.processed" "$done_dir"

        #if [[ $done_dir == plotfiles ]]; then
        #  # and visualize it
        #  runtimevis.py "${done_dir}/${dir}"
        #fi

      fi

      printf '%2d | done with %s\n' "$job_slot" "$dir"

    fi   # end test of whether file already processed

  fi   # end test of whether file is a directory (as it should be)
}

# these are needed for GNU parallel
export jobidfile plt_prefix chk_prefix FTIME_EXE KRONOS_DIR
export -f process_single_file

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
    {
      find . -maxdepth 1 -type d -name "${plt_prefix}"'?????' -print | sort;
      find . -maxdepth 1 -type d -name "${plt_prefix}"'??????' -print | sort;
      find . -maxdepth 1 -type d -name "${plt_prefix}"'???????' -print | sort;
    } | head -n-1 # don't process the final plotfile
  )


  # checkpoint files

  # Take all but the final chk file -- we want to ensure they're completely
  # written to disk.  Strip out any tar files that are lying around as well
  # as chkXXXXX.processed files.  We restrict the find command to a depth of
  # 1 to avoid catching any already-processed files in the checkfiles/
  # directory
  mapfile -t chklist < <(
    {
      find . -maxdepth 2 -type f -path "${chk_prefix}"'??000/Header' -printf '%h\n' | sort
      find . -maxdepth 2 -type f -path "${chk_prefix}"'???000/Header' -printf '%h\n' | sort
      find . -maxdepth 2 -type f -path "${chk_prefix}"'????000/Header' -printf '%h\n' | sort
    } | head -n-1 # don't process the final checkpoint file
  )


  # do the archiving in parallel
  # use --line-buffer so the start and finish lines are interleaved properly
  parallel --line-buffer -j 32 process_single_file '{}' '{%}' ::: "${pltlist[@]}" "${chklist[@]}"

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
if [ ! -d ${KRONOS_DIR} ]; then
  echo "trying to create directory: " "$KRONOS_DIR"
  mkdir -p "$KRONOS_DIR"
fi
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
