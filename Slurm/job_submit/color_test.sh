#!/bin/bash

echo " "
echo -n "Would you like to exclude a specific node or nodes? (ie dg-gpunode03?) (y/N): "
read spec_node
RESET='\e[0m'
BL_IT='\033[3;36m'
BL_IT_WBG='\033[3;47;36m'
BL_IT_B='\033[1;31;36m'

if [[ "$spec_node" != "y" ]]; then
	export specific_node=1	
	echo -e "${BL_IT}Example for a single node, enter ${BL_IT_B}[01]${RESET}${BL_IT}. For multiple nodes, enter ${BL_IT_B}[00,02,04-06]${RESET}"
	echo " "
	echo -n -e "${BL_IT}Please enter selection now: ${RESET}"
	read nodenum
	export node="dg-gpunode$nodenum"
	node="dg-gpunode$nodenum"
fi
echo "excluding nodes with command --exclude=$node"
echo " " 
