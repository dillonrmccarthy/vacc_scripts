#!/usr/bin/python3
import os
from os import listdir, getcwd
import subprocess
import sys
import inspect as isp
import get_dirsize


#====================================================================================================
#  For submission on bluemoon (NOT DEEPGREEN) using sbatch.
#  Just unwraps based on selection, does not dehydrate. does not need input file 
#====================================================================================================
class Dirinfo:
    def __init__(self):
        filepath = os.getcwd()
        self.dms = [filepath+'/'+fff for fff in listdir(getcwd()) if '_dehydrated.dms' in fff]
        self.dcd = [filepath+'/'+fff for fff in listdir(getcwd()) if '_dehydrated.dcd' in fff]
        if (self.dms and self.dcd):
            self.name = self.dms[0].split('/')[-1].split('_dehydrated')[0]
        if not (self.dms or self.dcd):
            self.dms = [filepath+'/'+fff for fff in listdir(getcwd()) if '_merged.dms' in fff]
            self.dcd = [filepath+'/'+fff for fff in listdir(getcwd()) if '_merged.dcd' in fff]
            self.name = self.dms[0].split('/')[-1].split('_merged')[0]
        if len(self.dms) != 1 or len(self.dcd) !=1: print("\n__FAILED__\nNo Trajectory\n"); exit()
        size = subprocess.check_output(['du','-sh', self.dms[0]]).split()[0].decode('utf-8')
        if size[-1] != "G":
            size = "25G"
        else:
            size = str(int(size[:-1])+10)+"G"
        #self.node = "bluemoon"
	#self.time = "30:00:00"
        self.node = "short"
        self.time = "3:00:00"
        if int(size[0:-1]) > 50:
            self.node = "bigmem"
        self.size = size

    def write_tcl_script(self): #for writing the job file. WTC is output of write tcl clickmes
        unwrap_code_1 = ('''package require pbctools

        set in_dmsfile %s
        set dcd_file %s

        mol new $in_dmsfile

        set step 1
        set name_of_trj "%s"
        set unwrap_extension1 "_unwrapped.dcd"
        set unwrap_extension2 "_unwrapped.dms"
        append unwrap_traj_saved $name_of_trj $unwrap_extension1
        append unwrap_initstruc_saved $name_of_trj $unwrap_extension2

        set sele [atomselect top "all"]

        animate write dms $unwrap_initstruc_saved beg 0 end 0 skip 0 waitfor all sel $sele top ; #writes dms intial

        mol addfile $dcd_file type dcd first 0 last -1 step $step waitfor all
        pbc unwrap -sel "all" -all

        animate write dcd $unwrap_traj_saved beg 0 end -1 skip 0 waitfor all sel $sele top ; #write the final combined trajectory!
        exit
        ''' % (self.dms[0],self.dcd[0],self.name))

        _file_code = isp.cleandoc(unwrap_code_1)
        return _file_code

#====================================================================================================
#now making the actual tcl file for sbatch submission

wombat=Dirinfo() #script needs to be launched from the directory with the dehydrated trajectory
filetxt = wombat.write_tcl_script()


with open('unwrap.tcl','w') as fh:
    fh.write(filetxt)
    fh.close()


#====================================================================================================
sbatch1 =('''#!/bin/bash
#SBATCH --partition=%s
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-socket=4
#SBATCH --time=%s
#SBATCH --mem=%s
#SBATCH --job-name=traj_dehydration
''' % (wombat.node,wombat.time,wombat.size))

sbatch2 = ('''#SBATCH --output=%x_%j.out
# Change to the directory where you submitted this script
cd ${SLURM_SUBMIT_DIR}
#
# For fun, echo some useful and interesting information
echo "Starting sbatch script myscript.sh at:`date`"
echo "  running host:    ${SLURMD_NODENAME}"
echo "  assigned nodes:  ${SLURM_JOB_NODELIST}"
echo "  partition used:  ${SLURM_JOB_PARTITION}"
echo "  jobid:           ${SLURM_JOBID}"

export VMD=/users/d/r/drmccart/Applications/vmd-1.9.3
$VMD/vmd -dispdev text -e unwrap.tcl
''')

fullsh = "\n".join([isp.cleandoc(sbatch1), isp.cleandoc(sbatch2)])

with open('submit_wrap.sh','w') as fh2:
    fh2.write(fullsh)
    fh2.close()

subprocess.run(["chmod","u+x", "submit_wrap.sh"])
subprocess.run(["sbatch", "submit_wrap.sh"])

exit(0)
#====================================================================================================

