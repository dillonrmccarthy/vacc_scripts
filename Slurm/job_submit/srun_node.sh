#!/bin/bash

echo -n "Would you like to specify a specific node ie dg-gpunode03? (y/N): "
read spec_node
#echo -n "Do you have a specific reserved node? (y/N): "
#read res_node

if [ "$spec_node" == "y" ]; then
	echo -n "Is this apart of a previously made reservation? (y/N): "
	read res_node
	if [ "$res_node" == "y" ]; then
		export select=0	
		echo -n "What is the name of the reservation?: "
		read reservation
	else
		export select=1	
		echo -n "Specify which node you would like to log into (01,02,...10): "
		read nodenum
		export node="dg-gpunode$nodenum"
		node="dg-gpunode$nodenum"
	fi
fi
echo -n "How many gpus would you like? (max 8):"
read gpus
echo -n "How many proccessors per node?:"
read procspernode
echo -n "How much memory? (In GB): "
read memory

if [ $select == 0 ]; then
	#echo "srun --reservation=$reservation -N 1 --gres=gpu:$gpus --ntasks-per-node=$procspernode --mem=$memory"G" -c 1 --pty bash"
	srun --reservation=$reservation -N 1 --gres=gpu:$gpus --ntasks-per-node=$procspernode --mem=$memory"G" -c 1 --pty bash
elif [ $select == 1 ]; then
	srun -w $node -N 1 --gres=gpu:$gpus --ntasks-per-node=$procspernode --mem=$memory"G" -c 1 --pty bash
else
	srun -N 1 --gres=gpu:$gpus --ntasks-per-node=$procspernode --mem=$memory"G" -c 1 --pty bash
fi
