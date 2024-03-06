#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=64
#SBATCH -A compsc
#SBATCH -p pt
#SBATCH -o "slurm.out" 
#SBATCH -e "slurm.err" 
[[ -r /apps/3rdparty/hpcrnd/envmodules/profile.d/shell-modules.sh ]] && . /apps/3rdparty/hpcrnd/envmodules/profile.d/shell-modules.sh
[[ -r /apps/3rdparty/hpcrnd/envmodules/profile.d/hpc-modules.sh ]] && . /apps/3rdparty/hpcrnd/envmodules/profile.d/hpc-modules.sh


. /glb/apps/hpc/EasyBuild/Public/Lmod/etc/profile.d/z01_lmod-hpcti.sh



# -- Model Input and output files --
#MODELTOCOMPUTE="pcpSingle_v1_out.mph"
#MODELTOCOMPUTE="filesweep.mph"
#MODELRESULT="fs_out.mph"

#MODELTOCOMPUTE="c2.mph"
#MODELRESULT="c2_result.mph"

#MODELTOCOMPUTE="c2mod_std1.mph"
#MODELRESULT="c2mod_std1_result.mph"

#MODELTOCOMPUTE="c2mod_std2.mph"
#MODELRESULT="c2mod_std2_result.mph"

#MODELTOCOMPUTE="c2_result_std2test.mph"
#MODELRESULT="c2_std2extensionResult.mph"

#MODELTOCOMPUTE="clisubmit.mph"
#MODELRESULT="cli_submit_result2.mph"

#MODELTOCOMPUTE="study2.mph"
#MODELRESULT="study2_result.mph"

#MODELTOCOMPUTE="twopit_std1.mph"
#MODELRESULT="twopit_std1_result.mph"
#MODELTOCOMPUTE="twopit_std2.mph"
#MODELRESULT="twopit_std2_result.mph"

#MODELTOCOMPUTE="std1.mph"
#MODELRESULT="std1_result.mph"

MODELTOCOMPUTE="std2.mph"
MODELRESULT="std2_result.mph"

#MODELTOCOMPUTE="std2_9dm5.mph"
#MODELRESULT="std2_9dm5_result.mph"


INPUTFILE="${MODELTOCOMPUTE}"
OUTPUTFILE="${MODELRESULT}"
BATCHLOG="${MODELTOCOMPUTE}.log"

export LM_LMCOMSOL_LICENSE_FILE=3072@pejjbt-s-8007.asia-pac.shell.com
#/apps/3rdparty-ep/COMSOL/COMSOL60_lnx/comsol60/multiphysics/bin/comsol batch -nn 1 -nnhost 1 -np 64 -mpibootstrap slurm -inputfile ${INPUTFILE} -outputfile ${OUTPUTFILE} -batchlog ${BATCHLOG} -mpidebug 10 -study std3 -paramfile paramlist.txt
#/apps/3rdparty-ep/COMSOL/COMSOL60_lnx/comsol60/multiphysics/bin/comsol61 batch -nn 1 -nnhost 1 -np 64 -mpibootstrap slurm -inputfile ${INPUTFILE} -outputfile ${OUTPUTFILE} -batchlog ${BATCHLOG} -mpidebug 10 -study std5 -paramfile paramlist.txt


##################################################################################
# COMSOL v6.1

# Study 1
#/apps/3rdparty-ep/COMSOL/COMSOL61_lnx/comsol61/Multiphysics/bin/comsol batch -nn 1 -nnhost 1 -np 16 -mpibootstrap slurm -inputfile ${INPUTFILE} -outputfile ${OUTPUTFILE} -batchlog ${BATCHLOG} -mpidebug 10 -study std4 -paramfile paramlist.txt

#Study 2
#/apps/3rdparty-ep/COMSOL/COMSOL61_lnx/comsol61/Multiphysics/bin/comsol batch -nn 1 -nnhost 1 -np 64 -mpibootstrap slurm -inputfile ${INPUTFILE} -outputfile ${OUTPUTFILE} -batchlog ${BATCHLOG} -mpidebug 10 -study std3 -paramfile paramlist.txt

#Study 3
/apps/3rdparty-ep/COMSOL/COMSOL61_lnx/comsol61/Multiphysics/bin/comsol batch -nn 1 -nnhost 1 -np 64 -mpibootstrap slurm -inputfile ${INPUTFILE} -outputfile ${OUTPUTFILE} -batchlog ${BATCHLOG} -mpidebug 10 -study std5 -paramfile paramlist.txt

##################################################################################


#/apps/3rdparty-ep/COMSOL/COMSOL60_lnx/comsol60/multiphysics/bin/comsol batch -mpibootstrap slurm -inputfile ${INPUTFILE} -outputfile ${OUTPUTFILE} -batchlog ${BATCHLOG} -mpidebug 10 -study std3 -paramfile paramlist.txt
#/apps/3rdparty-ep/COMSOL/COMSOL60_lnx/comsol60/multiphysics/bin/comsol batch -mpibootstrap slurm -inputfile ${INPUTFILE} -outputfile ${OUTPUTFILE} -batchlog ${BATCHLOG} -mpidebug 10 -study std4 -paramfile paramlist.txt
#/apps/3rdparty-ep/COMSOL/COMSOL60_lnx/comsol60/multiphysics/bin/comsol batch -mpibootstrap slurm -inputfile ${INPUTFILE} -outputfile ${OUTPUTFILE} -batchlog ${BATCHLOG} -mpidebug 10 -study std4 -paramfile paramlist.txt
#/apps/3rdparty-ep/COMSOL/COMSOL60_lnx/comsol60/multiphysics/bin/comsol batch -mpibootstrap slurm -inputfile ${INPUTFILE} -outputfile ${OUTPUTFILE} -batchlog ${BATCHLOG} -mpidebug 10 -study std4 -paramfile paramlist.txt
#/apps/3rdparty-ep/COMSOL/COMSOL60_lnx/comsol60/multiphysics/bin/comsol batch -mpibootstrap slurm -inputfile ${INPUTFILE} -outputfile ${OUTPUTFILE} -batchlog ${BATCHLOG} -mpidebug 10 -study std4
#/apps/3rdparty-ep/COMSOL/COMSOL60_lnx/comsol60/multiphysics/bin/comsol batch -mpibootstrap slurm -inputfile ${INPUTFILE} -outputfile ${OUTPUTFILE} -batchlog ${BATCHLOG} -mpidebug 10 -study std3

# Run transient study std3 in comsol files
#comsol batch -inputfile ${INPUTFILE} -outputfile ${OUTPUTFILE} -study std3
#comsol batch -inputfile ${INPUTFILE} -outputfile ${OUTPUTFILE}
