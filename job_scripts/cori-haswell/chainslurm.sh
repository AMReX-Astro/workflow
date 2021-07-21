#!/bin/sh -f

if [ ! "$1" ]; then
  echo "usage: chainslurm.sh jobid number script"
  exit -1
fi

if [ ! "$2" ]; then
  echo "usage: chainslurm.sh jobid number script"
  exit -1
fi

if [ ! "$3" ]; then
  echo "usage: chainslurm.sh jobid number script"
  exit -1
fi


oldjob=$1
numjobs=$2
script=$3

if [ $numjobs -gt "20" ]; then
    echo "too many jobs requested"
    exit -1
fi

echo chaining $numjobs jobs starting with $oldjob


for count in `seq 1 1 $numjobs`
do
  echo starting job $count to depend on $oldjob
  aout=`sbatch --parsable -d afterany:${oldjob} ${script}`
  echo "   " jobid: $aout
  echo " "
  oldjob=$aout
  sleep 3
done
