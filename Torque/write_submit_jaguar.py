'''Writes a jaguar submission file for all the input files in the directory'''
from os import chdir 
from os import listdir
from os import getcwd
import sys
from os import system

def process_jname(jname):

    txt = ''
    txt += '#!/bin/bash\n'
    txt += '#PBS -N %s\n' %jname
    txt += '#PBS -o %s.stdout\n' %jname
    txt += '#PBS -e %s.stderr\n' %jname
    #txt += '#PBS -q sharedq\n'
    txt += '#PBS -q ibq\n'
    txt += '#PBS -l nodes=1:ppn=12 \n'
    #txt += '#PBS -l walltime=30:00:00\n\n'
    txt += '#PBS -l walltime=30:00:00,pmem=2gb:ib:pvmem=3gb\n\n'


    txt += 'export SCHRODINGER=/users/d/r/drmccart/Applications/schrodinger2019-2\n'
    txt += 'export SCHROD_LICENSE_FILE="@schrodlm.uvm.edu"\n'
    txt += 'export SCHRODINGER_TMPDIR=/tmp\n\n'


    txt += 'echo ------------------------------------------------------\n'
    txt += 'echo -n "Job is running on node "; cat $PBS_NODEFILE\n'
    txt += 'echo ------------------------------------------------------\n'
    txt += 'echo PBS: qsub is running on $PBS_O_HOST\n'
    txt += 'echo PBS: originating queue is $PBS_O_QUEUE\n'
    txt += 'echo PBS: executing queue is $PBS_QUEUE\n'
    txt += 'echo PBS: working directory is $PBS_O_WORKDIR\n'
    txt += 'echo PBS: execution mode is $PBS_ENVIRONMENT\n'
    txt += 'echo PBS: job identifier is $PBS_JOBID\n'
    txt += 'echo PBS: job name is $PBS_JOBNAME\n'
    txt += 'echo PBS: node file is $PBS_NODEFILE\n'
    txt += 'echo PBS: current home directory is $PBS_O_HOME\n'
    txt += 'echo PBS: PATH = $PBS_O_PATH\n'
    txt += 'echo ------------------------------------------------------\n\n'

    txt += 'cd $PBS_O_WORKDIR\n'
    txt += '$SCHRODINGER/jaguar run -WAIT %s.in\n' %jname


    # Finally, write the submission file...
    f = open('submission.sub', 'w')
    f.write(txt)
    f.close()


d_list = [ getcwd() + '/' + m for m in listdir(getcwd()) ]
for j in d_list: 
	try: 
		chdir(j)
		if "submission.sub" in listdir(getcwd()):
			continue
		jname_list = [n[:-3] for n in listdir(getcwd()) if n[-3:] == '.in']
		print 'jobname list:', jname_list	
		for jn in jname_list:
			process_jname(jn)
			system("qsub submission.sub")
	except:
		continue

print 'Completed Successfully'

