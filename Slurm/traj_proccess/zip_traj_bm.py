#!/usr/bin/python3
import os
from os import listdir, getcwd
import subprocess
import sys
import inspect as isp


#====================================================================================================
#			          for zipping files on bluemoon!
#====================================================================================================

if len(sys.argv) < 2:
	print("Please feed the name of the folder you would like to zip as the argument variable")
	exit(1)
	
class ab_fol_path:
	def __init__(self, folder):
		self._absfp = os.path.abspath(".")
		self.in_folder = (self._absfp+"/"+folder)	
		self.out_zip = (self.in_folder+".tar.xz")
		dir_check = [f for f in listdir(self._absfp) if folder in f]
		if len(dir_check) != 1:
			print("There seems to be a problem with the folder specified...Please try again")
			exit(1)
		#else:
		#	print("The folder being compressed is:",self.in_folder)
		#	print("The output file will be:",self.out_zip)
		#	sel = float(input("Is this correct? \nSelect 1 if yes, 2 if no: "))
		#	if sel != 1:
		#		exit(1)
		size = subprocess.check_output(['du','-sh', self.in_folder]).split()[0].decode('utf-8')
		if size[-1] != "G":
			if size[-1] == "T":
				print("Are you sure this is the right folder? Do not zip folders > 1 tb")
				exit(0)
				#self.size = "200G"
				#self.node = "bigmemwk"
			else:
				self.size = "10G"
				self.node = "bluemoon"
		else:
			self.size = str(int(size[:-1])+10)+"G"
			self.node = "bluemoon"
			if int(size[0:-1]) > 50:
				self.node = "bigmem"
				if int(size[0:-1]) > 200:
					self.size = "200G"

#====================================================================================================
# inputs

outvar = "%x_%j.out"
wombat = ab_fol_path(sys.argv[1])
#print(wombat.in_folder)
#print(wombat.size)
#print(wombat.node)

#====================================================================================================

sbatch = ('''#!/bin/bash
#SBATCH --partition=%s
#SBATCH --nodes=1
#SBATCH --ntasks=12
#SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-socket=12
#SBATCH --time=30:00:00
#SBATCH --mem=%s
#SBATCH --time=30:00:00
#SBATCH --job-name=zip_boi
#SBATCH --output=%s
#
# Change to the directory where you submitted this script
cd ${SLURM_SUBMIT_DIR}
#
echo "Starting sbatch script at:`date`"
echo "  running host:    ${SLURMD_NODENAME}"
echo "  assigned nodes:  ${SLURM_JOB_NODELIST}"
echo "  partition used:  ${SLURM_JOB_PARTITION}"
echo "  jobid:           ${SLURM_JOBID}"

#zip command:
tar -cf - %s | xz -9 --threads=12 -c - > %s

''' % (wombat.node, wombat.size, outvar, wombat.in_folder, wombat.out_zip))

#====================================================================================================

with open(wombat.in_folder+'/zip_sub.sh','w') as fh1:
    fh1.write(sbatch)
    fh1.close()

subprocess.run(["chmod","u+x", wombat.in_folder+"/zip_sub.sh"])
subprocess.run(["sbatch", wombat.in_folder+"/zip_sub.sh"])

exit(0)
