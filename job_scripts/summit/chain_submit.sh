#!/bin/sh -f

if [ ! "$1" ]; then
  echo "usage: chain_submit.sh jobid number script"
  exit -1
fi

if [ ! "$2" ]; then
  echo "usage: chain_submit.sh jobid number script"
  exit -1
fi

if [ ! "$3" ]; then
  echo "usage: chain_submit.sh jobid number script"
  exit -1
fi

echo chaining $2 jobs starting with $1

oldjob=$1
script=$3

for count in `seq 1 1 $2`
do
  echo starting job $count to depend on $oldjob
  aout=$(bsub -w ${oldjob} ${script})
  echo $aout
  jobid=$(echo ${aout} | head -c 11 | tail -c 6)
  echo "   jobid = ${jobid}"
  echo " "
  oldjob=$jobid
  sleep 3
done
