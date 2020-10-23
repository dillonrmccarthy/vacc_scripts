#!/bin/bash 

#SCHRODINGER STUFF
export SCHRODINGER_DESMOND_LOGMONITOR=720
export SCHRODINGER18_2=/users/k/t/ktmckay/Applications/schrodinger2018-2
export SCHRODINGER18_4=/users/j/b/jbferrel/schrodinger/schrodinger2018-4
export SCHRODINGER19_1=/users/d/r/drmccart/Applications/schrodinger2019-1
export SCHRODINGER19_2=/users/d/r/drmccart/Applications/schrodinger2019-2
export LD_LIBRARY_PATH='/users/d/r/drmccart/Applications/schrodinger2019-2/desmond-v5.8/lib/Linux-x86_64':'/users/d/r/drmccart/Applications/schrodinger2019-2/mmshare-v4.6/lib/Linux-x86_64':'/users/d/r/drmccart/Applications/schrodinger2019-1/desmond-v5.7/lib/Linux-x86_64':'/users/d/r/drmccart/Applications/schrodinger2019-1/mmshare-v4.5/lib/Linux-x86_64:':$LD_LIBRARY_PATH

while true; do
	clear && clear
	jobname="$(basename *msj .msj)"
	echo -e "Job Submission Beginning for: \e[1;107;34m$jobname\e[0m Molecular Dynamics Simulation"
	echo "----------------------------------------------------"
	echo "Which Version of Schrodinger Would you like to use?:"
	echo "                 2018-2 (enter '1')"
	echo "                 2018-4 (enter '2')"
	echo "                 2019-1 (enter '3')"
	echo "                 2019-2 (enter '4')"
	echo "----------------------------------------------------"
	echo -n "Enter selection: "
	read schrod_ver
	if [[ $schrod_ver == 1 ]];then
		export SCHRODINGER=$SCHRODINGER18_2; break
	elif [[ $schrod_ver == 2 ]];then
		export SCHRODINGER=$SCHRODINGER18_4; break
	elif [[ $schrod_ver == 3 ]];then
		export SCHRODINGER=$SCHRODINGER19_1; break
	elif [[ $schrod_ver == 4 ]];then
		export SCHRODINGER=$SCHRODINGER19_2; break
	else
		echo -e "\e[107;91;1mInvalid selection, please select again\e[0m" & sleep 2; clear&&clear; continue
	fi 
done

nvidia-smi --query-gpu=gpu_name,index,utilization.gpu,utilization.memory --format=csv

echo -n "Select GPU 0 or GPU 1: "
read gpuval

host="localhost"
	
jobname="$(basename *msj .msj)"
cfg=$jobname".cfg" 
msj=$jobname".msj" 
cms=$jobname".cms" 
 
echo 
echo "Making job $jobname using: $cfg, $msj, and $cms" 
echo 
 
env SCHRODINGER_CUDA_VISIBLE_DEVICES=$gpuval $SCHRODINGER/utilities/multisim -VIEWNAME desmond_metadynamics_gui.MetadynamicsApp -JOBNAME $jobname -HOST $host -maxjob 1 -cpu 1 -m $msj -c $cfg -description 'Metadynamics' $cms -mode umbrella -set stage[1].set_family.md.jlaunch_opt=["-gpu"] -o $jobname-out.cms -ATTACHED 
