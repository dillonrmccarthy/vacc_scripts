#!/usr/bin/python3
import os
from os import listdir, getcwd
import subprocess
import sys
import inspect as isp


#====================================================================================================
# The Script can auto dehydrate and combine the outputs of multiple desmond trajectories into a dcd and dms. Does not wrap/unwrap. For submission on bluemoon (NOT DEEPGREEN) using sbatch.
#====================================================================================================
class Dirinfo:
    def __init__(self,incms): #basically initializes the list of all jobs and continued jobs
        incms = [incms]
        #incms = [f for f in listdir(getcwd()) if f[-7:] == '-in.cms']
        self._clickme_first = [("./"+incms[0][:-7]+'_trj/clickme.dtr')]
        cont_folders = [ff for ff in listdir(getcwd()) if '_cont_' in ff]
        if len(cont_folders) > 0: #make sure there are continuation folders in the first place
            self._flag = True
            cont_vals = sorted([int((element.split("_")[-1])) for element in cont_folders])
            sorted_cf = [(incms[0][:-7]+'_cont_'+str(val)) for val in cont_vals]
            self._clickmes = []
            for path in sorted_cf:
                self._clickmes.append("./"+path+"/"+path+"_trj/clickme.dtr")
        else:
            self._flag = False
        self._dirpath = os.getcwd()+'/'

    def write_tcl_clickmes(self): #clickmes is a pre-processed tcl list which has the correct elements
        if self._flag:
            tcl_tmp = ['{']
            mid_tmp = ' '.join(map(str,self._clickmes))
            tcl_tmp.append(mid_tmp)
            tcl_tmp.append('}')
            tcl_list = ''.join(map(str,tcl_tmp))
            return self._clickme_first[0], tcl_list
        else:
            return self._clickme_first[0]

    def write_tcl_script(self,wtc): #for writing the job file. WTC is output of write tcl clickmes
        dehydrate_code_1 = ('''package require pbctools

        set step 1
        set name_of_trj [file rootname [glob *.ene]]
        set dehy_extension1 "_dehydrated.dcd"
        set dehy_extension2 "_dehydrated.dms"
        append dehy_traj_saved $name_of_trj $dehy_extension1
        append dehy_initstruc_saved $name_of_trj $dehy_extension2

        set in_cmsfile [glob *-in.cms]''')

        if self._flag: #if there are continuation folders, write one version of the tcl script
            dehydrate_code_2 = ('''
            set init_traj %s
            mol new $in_cmsfile
            set sel [atomselect top "not resname SPC"]
            animate write dms $dehy_initstruc_saved beg 0 end 0 skip 0 waitfor all sel $sel top ; #writes dms intial

            mol addfile $init_traj type dtr first 1 last -1 step $step waitfor all ; #add first traj ignoring the first frame (as is indentical to in-cms)

            set dtr_list %s ; #set to output of tcl lists, load the rest of .dtr's normally
            foreach dtr_in $dtr_list {
                mol addfile $dtr_in type dtr first 0 last -1 step $step waitfor all }

            animate write dcd $dehy_traj_saved beg 1 end -1 skip 0 waitfor all sel $sel top ; #write the final combined trajectory!
            exit
            ''' % (wtc[0], wtc[1]))

        elif not self._flag: #if there are not, write the other version of the tcl script.
            dehydrate_code_2 = ('''
            set init_traj %s
            mol new $in_cmsfile

            set sel [atomselect top "not resname SPC"]
            animate write dms $dehy_initstruc_saved beg 0 end 0 skip 0 waitfor all sel $sel top ; #writes dms intial

            mol addfile $init_traj type dtr first 1 last -1 step $step waitfor all ; #add first traj ignoring the first frame (as is indentical to in-cms)
            animate write dcd $dehy_traj_saved beg 1 end -1 skip 0 waitfor all sel $sel top ; #write the final combined trajectory!
            exit
            ''' % wtc)

        else:
            exit(1)
        _file_code = [isp.cleandoc(dehydrate_code_1), '', isp.cleandoc(dehydrate_code_2)]
        return '\n'.join(_file_code)

#====================================================================================================
#now making the actual tcl file for sbatch submission
wombat=Dirinfo(sys.argv[1]) #this should be the ORIGINAL in-cms file
dtrs = wombat.write_tcl_clickmes()
filetxt = wombat.write_tcl_script(dtrs)

with open('dehy_and_comb.tcl','w') as fh:
    fh.write(filetxt)
    fh.close()

#====================================================================================================
sbatch_command =('''#!/bin/bash
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --ntasks=2
#SBATCH --cpus-per-task=1
#SBATCH --time=3:00
#SBATCH --mem=1G
#SBATCH --job-name=traj_dehydration
#SBATCH --output=%x_%j.out
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
$VMD/vmd -dispdev text -e dehy_and_comb.tcl
''')

with open('submit.sh','w') as fh2:
    fh2.write(sbatch_command)
    fh2.close()

subprocess.run(["chmod","u+x", "submit.sh"])
subprocess.run(["sbatch", "submit.sh"])

exit(0)
#====================================================================================================
