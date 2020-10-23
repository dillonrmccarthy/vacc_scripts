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
	export meta_or_md=$meta_or_md
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

name="$(basename *msj .msj)"
export outcfg=$name"-out.cfg" 
export kerseq=$name"kerseq" 
export fes=$name".fes" 
export name=$name

echo "$SCHRODINGER/internal/bin/python3 $SCHRODINGER/internal/lib/python3.6/site-packages/schrodinger/application/desmond/meta.py -i $outcfg  -d $kerseq -o $fes"

