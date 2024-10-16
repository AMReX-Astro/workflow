#!/bin/bash
set -f  # disable filename globbing
set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") <script>"
}

if [[ $# -gt 0 ]]; then
  case "$1" in
    -h|--help)
      usage "$0"
      exit 0
      ;;
  esac
fi

if [[ $# -ne 1 ]]; then
  usage "$0"
  exit 255
fi

script=$1
if [[ ! -e $script ]]; then
  echo "Input script does not exist: $script"
  exit 1
fi

{
  # put the header into its own variable
  read -r header
  # sort the rest of the lines by job ID and put them into $job_lines, without
  # trailing newlines
  readarray -t job_lines < <(sort -n -)
} < <(squeue --me -o "%8i %2t  %30j %5D %.8l %.8M %6q %10f %16R %E")

job_count=${#job_lines[@]}

if [[ $job_count -gt 0 ]]; then
  #echo "Found $job_count jobs"
  echo 'Select the starting job or enter the job ID (0 to start a new chain):'
  echo
  # add padding equal to the width of the select option numbers
  # (${#job_count} gets the length of the string "$job_count")
  printf '%*s  %s\n' ${#job_count} '' "$header"
  PS3='> '
  # override the terminal width so select displays all options in one column
  COLUMNS=1
  select line in "${job_lines[@]}"; do
    # If the user entered a valid option number, the full contents of that line
    # will be placed in $line. Otherwise, $line will be empty and the entered
    # text will be in $REPLY.
    if [[ -n $line ]]; then
      oldjob=$(cut -d' ' -f1 <<<"$line")
      echo "Starting from job $oldjob"
      break
    else
      oldjob=$REPLY
      break
    fi
  done
  if [[ -z ${oldjob+x} ]]; then
    # oldjob is unset, so the user entered ctrl-d in the select prompt
    exit 0
  fi
else
  echo 'No jobs in queue; starting a new chain...'
  oldjob=0
fi

if [[ "$oldjob" -gt 0 ]]; then
  IFS='|' read -r old_name old_dir < <(sacct -n -X -P --format jobname,workdir -j "$oldjob")

  # check that the submission directories match
  old_dir=$(readlink -f "$old_dir")
  new_dir=$(readlink -f "$PWD")
  if [[ "$old_dir" != "$new_dir" ]]; then
    old_pretty=$old_dir
    new_pretty=$new_dir
    if [[ -n ${SCRATCH+x} ]]; then
      old_pretty="${old_pretty/$SCRATCH/\$SCRATCH}"
      new_pretty="${new_pretty/$SCRATCH/\$SCRATCH}"
    fi
    old_pretty="${old_pretty/$HOME/\~}"
    new_pretty="${new_pretty/$HOME/\~}"
    echo "Error: selected job was submitted from ${old_pretty}, but you are currently in ${new_pretty}"
    exit 2
  fi

  # parse $script for job name and ask for confirmation if they differ
  new_name=$(sed -En 's/^#SBATCH -J (.*)$/\1/p' "$script")
  if [[ "$old_name" != "$new_name" ]]; then
    echo "Warning: selected job name and new job name differ:"
    echo "-$old_name"
    echo "+$new_name"
    read -r -p 'Continue [yN]? ' ok
    case $ok in
      y|yes|Y) ;;
      *) exit 2 ;;
    esac
  fi

  # check that there isn't another job that depends on the selected one
  if depend_line=$(grep 'after\w*:'"$oldjob" <(printf '%s\n' "${job_lines[@]}")); then
    dep_job=${depend_line%% *}
    dep_info=${depend_line##* }
    dep_info=${dep_info%(*)}
    echo "Error: selected job is in the middle of a chain: job $dep_job has dependency $dep_info"
    exit 2
  fi

  read -r -p 'How many additional jobs to chain? ' numjobs

  echo "chaining $numjobs jobs starting with $oldjob"
else
  read -r -p 'How many jobs to chain? ' numjobs

  echo "chaining $numjobs jobs"
fi

for count in $(seq 1 1 "$numjobs"); do
  if [[ $oldjob -gt 0 ]]; then
    echo "starting job $count to depend on $oldjob"
    id=$(sbatch --parsable -d "afterany:${oldjob}" "${script}" | cut -d';' -f1)
  else
    echo "starting job $count with no dependency"
    id=$(sbatch --parsable "${script}" | cut -d';' -f1)
  fi
  echo "    jobid: $id"
  echo " "
  oldjob=$id
  sleep 3
done
