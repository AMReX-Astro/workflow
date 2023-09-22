#!/bin/sh -f

if [ ! "$1" ]; then
  echo "usage: chainbsub.sh jobid number"
  exit -1
fi

if [ ! "$2" ]; then
  echo "usage: chainbsub.sh jobid number"
  exit -1
fi

oldjob=$1
numjobs=$2

script=summit_gpu.submit

if [ "$3" ]; then
  script=$3
fi

echo chaining $numjobs jobs starting with $oldjob


for count in `seq 1 1 $numjobs`
do
  echo starting job $count to depend on $oldjob
  aout=`bsub -w "done(${oldjob})" $script`
  id=`echo $aout | head -n1 | cut -d'<' -f2 | cut -d'>' -f1`
  echo "   " jobid: $id
  echo " "
  oldjob=$id
  sleep 1
done
