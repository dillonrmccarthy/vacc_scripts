#!/bin/bash
#SCHRODINGER STUFF
export SCHRODINGER_DESMOND_LOGMONITOR=720
export SCHRODINGER18_2=/users/k/t/ktmckay/Applications/schrodinger2018-2
export SCHRODINGER18_4=/users/j/b/jbferrel/schrodinger/schrodinger2018-4
export SCHRODINGER19_1=/users/d/r/drmccart/Applications/schrodinger2019-1
export SCHRODINGER19_2=/users/d/r/drmccart/Applications/schrodinger2019-2
export LD_LIBRARY_PATH='/users/d/r/drmccart/Applications/schrodinger2019-2/desmond-v5.8/lib/Linux-x86_64':'/users/d/r/drmccart/Applications/schrodinger2019-2/mmshare-v4.6/lib/Linux-x86_64':'/users/d/r/drmccart/Applications/schrodinger2019-1/desmond-v5.7/lib/Linux-x86_64':'/users/d/r/drmccart/Applications/schrodinger2019-1/mmshare-v4.5/lib/Linux-x86_64:':$LD_LIBRARY_PATH

#if [[ $HOSTNAME == "dg-user1.cluster" ]] | [[ $hn == "dg-user2.cluster" ]];then
if [ $HOSTNAME = "dg-user1.cluster" ];then
	:
elif [ $HOSTNAME = "dg-user2.cluster" ];then
	:
else
	echo "submit from DeepGreen cluster!"
fi

while true; do
	clear && clear
	jobname="$(basename *msj .msj)"
	echo -e "Job Submission Beginning for: \e[1;107;34m$jobname\e[0m Molecular Dynamics Simulation"
	echo "----------------------------------------------------"
	echo "Which Version of Schrodinger Would you like to use?:"
	echo "                 2018-2 (enter '1')<--Don't use"
	echo "                 2018-4 (enter '2')<--Don't use"
	echo "                 2019-1 (enter '3')<--Don't use"
	echo "                 2019-2 (enter '4')"
	echo "----------------------------------------------------"
	echo -n "Enter selection: "
	read schrod_ver
	export meta_or_md=$meta_or_md
	if [[ $schrod_ver == 1 ]];then
		exit
		#export SCHRODINGER=$SCHRODINGER18_2; break
	elif [[ $schrod_ver == 2 ]];then
		exit
		#export SCHRODINGER=$SCHRODINGER18_4; break
	elif [[ $schrod_ver == 3 ]];then
		exit
		#export SCHRODINGER=$SCHRODINGER19_1; break
	elif [[ $schrod_ver == 4 ]];then
		#export SCHRODINGER=$SCHRODINGER19_2; break
		export SCHRODINGER=$SCHRODINGER19_2; : # the ":" just means continue pretty much
	else
		echo -e "\e[107;91;1mInvalid selection, please select again\e[0m" & sleep 2; clear&&clear; continue
	fi 
	echo -n "Would you like to run a MD simulation? (enter 1) or Metadynamics (enter 2)?: "
	read meta_or_md
	if [[ "$meta_or_md" == "1" ]] || [[ "$meta_or_md" == "2" ]]; then
		break #remove this later. use break instead of ":" if you want to break the entire while loop"
		: #this is equivalent to continue and do nothing. if "continue is used, then it will loop back"  
	else
		echo "must select!"; continue
	fi
done
echo -e "Using Schrodinger Path: \e[1;107;34m$SCHRODINGER\e[0m"
while true; do
	echo -n "Save job at walltime? Walltime must be greater than 15 minutes. (Y/n): "
	read select_jobsaver
	if [[ $select_jobsaver == "n" ]];then
		echo "Warning, please make sure your simulation is within the limits of the walltime (48 hours max), otherwise you may lose data."; export select_jobsaver=$select_jobsaver; break
	else
		echo -n "Select walltime in hours (leave null for default value of 48): "
		read hours
		if [[ $hours == '' ]];then
			echo "Using default walltime value (48 hours)"
			hours=48
		elif [[ $(bc <<< "$hours<=0.25") > 0 ]];then
			echo "Walltime must be greater than 15 minutes."
			continue
		fi
		export walltime="$hours:00:00"
		jobsaver=$(echo "($hours-0.25)"| bc -l)
		export jobsaver=$jobsaver
		echo "stop job at $jobsaver hours"
		break
	 fi
done
export host='localhost'
echo -n "Do you have a reservation? (y/N): "
read reservation_value
if [[ $reservation_value == "y" ]];then
	echo -n "Please enter the reservation here: "
	read reservation_name
	export reservation_name=$reservation_name; fi
while true; do
	if [[ $(ls ./*cpt 2> /dev/null | wc -l) -ge 2 ]];then
		echo  " "
		echo -e "\e[107;91;1mCheckpoint file found!"
		echo "More than one checkpoint file found!"
		echo "You are most likely not in the master directory!"
		echo -en "If this is true, would you like to move up one directory? (y/N)\e[0m : "
		read move_directory
		if [[ "$move_directory" == "y" ]] || [[ "$move_directory" == "Y" ]];then
			cd ../.
		else
			echo "Please move to the correct directory before submitting this script!"
			exit 
		fi
	else
		break
	fi 
done
name="$(basename *msj .msj)"
export cfg=$name".cfg" 
export msj=$name".msj" 
export cms=$name".cms" 
export name=$name
export tmpdir="/gpfs3/scratch/"$USER"/temp"
if [[ $(ls ./*cpt 2> /dev/null | wc -l) -eq 1 ]];then
	echo  " "
	echo -e "\e[107;91;1mCheckpoint file found!"
	echo -en "Would you like to extend/continue the simulation? (Y/n)\e[0m : "
	read extendsel
	if [[ $extendsel == "n" ]]; then
		echo "Trying to resubmit job. Not Allowed Here."
		exit
	fi
	contvariableadd=0
	while true; do
		if [ -d ./*_cont_"$contvariableadd" ]; then
			let contvariableadd+=1
		else
			mkdir $name"_cont_"$contvariableadd #make directory
			previouscont=$(($contvariableadd-1))
			if [[ $previouscont -lt 0 ]]; then
				t_prev_sim_end=$(cat *log | grep -i "writing checkpoint" | tail -1 | grep -Eo '[+-]?[0-9]+([.][0-9]+)?' | head -1)
				prev_sim_end=$(printf %0.f $t_prev_sim_end)
				cp *cpt *-in.cms $name".cfg" $name"_cont_"$contvariableadd/.
				cd $name"_cont_"$contvariableadd
				export cpt=$name".cpt"
				
			elif [[ $previouscont -ge 0 ]]; then
				cd *_cont_$previouscont
				t_prev_sim_end=$(cat *log | grep -i "writing checkpoint" | tail -1 | grep -Eo '[+-]?[0-9]+([.][0-9]+)?' | head -1)
				prev_sim_end=$(printf %0.f $t_prev_sim_end)
				cp *_cont_"$previouscont".cpt *-in.cms $name".cfg" ../$name"_cont_"$contvariableadd/.
				cd ../$name"_cont_"$contvariableadd
				export cpt=$name"_cont_"$previouscont".cpt"
			fi 
			break 
		fi
	done
	while true; do
		echo "The previous .cpt file was written at $prev_sim_end picoseconds"
		echo -n "Enter new final time for job in nanoseconds: "
		read newtime_ns
		temp_newtime=$(echo "($newtime_ns*1000)" | bc -q)       
		newtime=$(printf %0.f $temp_newtime)
		if [[ $newtime -le $prev_sim_end ]];then
			echo "Please select a time greater than the end of the previous simulation ($prev_sim_end ps)"
		elif [[ $newtime -ge $prev_sim_end ]];then
			break
		else
			continue
		fi
	done
	export cms=$name"-in.cms"
	export name=$name"_cont_"$contvariableadd
	export newtime=$newtime			
	export EXTENDSIMULATION=1
fi

export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [[ $reservation_value == "y" ]];then
	#echo "sbatch --job-name=$name --time=$walltime --reservation=$reservation_name $DIR"/slurm_md.sh""
	sbatch --job-name=$name --reservation=$reservation_name $DIR"/slurm_md.sh"
else
	#echo "sbatch --job-name=$name --time=$walltime $DIR"/slurm_md.sh""
	sbatch -w dg-gpunode07 --job-name=$name $DIR"/slurm_md.sh"
	#sbatch --job-name=$name $DIR"/slurm_md.sh"
fi
