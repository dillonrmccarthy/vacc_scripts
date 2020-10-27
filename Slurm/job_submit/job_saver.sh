#!/bin/bash
sleep 10
ssh $SLURMD_NODENAME & sleep 10
if [[ $select_jobsaver == "n" ]];then
	exit
else
	sleep $jobsaver"h"
	$SCHRODINGER/jobcontrol -stop -f $name
fi
