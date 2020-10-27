#!/bin/bash

while true; do
	clear && clear
	echo "==================================================="
	echo -n "node 01 jobs: "
	squeue -w dg-gpunode01 | grep -i "dg-gpunode01" | wc -l
	echo "==================================================="
	echo -n "node 02 jobs: "
	squeue -w dg-gpunode02 | grep -i "dg-gpunode02" | wc -l
	echo "==================================================="
	echo -n "node 03 jobs: "
	squeue -w dg-gpunode03 | grep -i "dg-gpunode03" | wc -l
	echo "==================================================="
	echo -n "node 04 jobs: "
	squeue -w dg-gpunode04 | grep -i "dg-gpunode04" | wc -l
	echo "==================================================="
	echo -n "node 05 jobs: "
	squeue -w dg-gpunode05 | grep -i "dg-gpunode05" | wc -l
	echo "==================================================="
	echo -n "node 06 jobs: "
	squeue -w dg-gpunode06 | grep -i "dg-gpunode06" | wc -l
	echo "==================================================="
	echo -n "node 07 jobs: "
	squeue -w dg-gpunode07 | grep -i "dg-gpunode07" | wc -l
	echo "==================================================="
	echo -n "node 08 jobs: "
	squeue -w dg-gpunode08 | grep -i "dg-gpunode08" | wc -l
	echo "==================================================="
	echo -n "node 09 jobs: "
	squeue -w dg-gpunode09 | grep -i "dg-gpunode09" | wc -l
	echo "==================================================="
	echo -n "node 10 jobs: "
	squeue -w dg-gpunode10 | grep -i "dg-gpunode10" | wc -l
	echo "==================================================="
	squeue -u drmccart
	echo "==================================================="
	sleep 60
done
