#!/bin/bash
# Specify a partition
#SBATCH --partition=dggpu
## Request nodes
#SBATCH --nodes=1
## Request some processor cores
#SBATCH --ntasks=4
## Request GPUs
#SBATCH --gres=gpu:1
## Request memory 
#SBATCH --mem=80G
### Run for five minutes
##SBATCH --time=$walltime
## Output of this job, stderr and stdout are joined by default
# %x=job-name %j=jobid
#SBATCH --output=%x_%j.out
## Notify me via email -- please change the username!
##SBATCH --mail-user=drmccart@uvm.edu
##SBATCH --mail-type=ALL
# change to the directory where you submitted this script
cd ${SLURM_SUBMIT_DIR}
#
# your job execution follows:
echo "Starting sbatch script myscript.sh at:`date`"
# echo some slurm variables for fun
echo "  running host:    ${SLURMD_NODENAME}"
echo "  assigned nodes:  ${SLURM_JOB_NODELIST}"
echo "  jobid:           ${SLURM_JOBID}"
# show me my assigned GPU number(s):
echo "  GPU(s):          ${CUDA_VISIBLE_DEVICES}"

$DIR/job_saver.sh & #for on/off control see job_saver.sh script

#Molecular Dynamics...
if [[ $meta_or_md == 1 ]]; then
	if [[ $EXTENDSIMULATION == 1 ]]; then
		env SCHRODINGER_CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES $SCHRODINGER/desmond -JOBNAME $name -HOST $host -gpu -restore $cpt -in $cms -cfg mdsim.last_time=$newtime -TMPDIR $tmpdir -ATTACHED -WAIT
	else
		env SCHRODINGER_CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES $SCHRODINGER/utilities/multisim -JOBNAME $name -HOST $host -maxjob 1 -cpu 1 -m $msj -c $cfg -description 'Molecular Dynamics' $cms -mode umbrella -set stage[1].set_family.md.jlaunch_opt=["-gpu"] -o $name-out.cms -TMPDIR $tmpdir -ATTACHED -WAIT
	fi

#Metadynamics...
elif [[ $meta_or_md == 2 ]]; then
	if [[ $EXTENDSIMULATION == 1 ]]; then
		echo "I havnt figured out how to extend metadynamics jobs yet...sorry!"; exit
	else
		env SCHRODINGER_CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES  $SCHRODINGER/utilities/multisim -JOBNAME $name -HOST $host -maxjob 1 -cpu 1 -m $msj -c $cfg -description 'Metadynamics' $cms -mode umbrella -set stage[1].set_family.md.jlaunch_opt=["-gpu"] -o $name-out.cms -TMPDIR $tmpdir -ATTACHED -WAIT
	fi
else
	echo "YOU CANT DO THAT!"; exit
fi
