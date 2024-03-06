#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=64
#SBATCH -A compsc
#SBATCH -p compsc-guaranteed
#SBATCH -o "slurm.out" 
#SBATCH -e "slurm.err" 
#SBATCH --time=04:30:00
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
MODELTOCOMPUTE="twopit_std2.mph"
MODELRESULT="twopit_std2_result.mph"

#MODELTOCOMPUTE="std1.mph"
#MODELRESULT="std1_result.mph"

#MODELTOCOMPUTE="std2.mph"
#MODELRESULT="std2_result.mph"

#MODELTOCOMPUTE="std2_9dm5.mph"
#MODELRESULT="std2_9dm5_result.mph"


INPUTFILE="${MODELTOCOMPUTE}"
OUTPUTFILE="${MODELRESULT}"
BATCHLOG="${MODELTOCOMPUTE}.log"

export LM_LMCOMSOL_LICENSE_FILE=3072@pejjbt-s-8007.asia-pac.shell.com
#/apps/3rdparty-ep/COMSOL/COMSOL60_lnx/comsol60/multiphysics/bin/comsol batch -N 2 --ntasks-per-node=2 -mode desktop -mpibootstrap slurm -inputfile ${INPUTFILE} -outputfile ${OUTPUTFILE} -batchlog ${BATCHLOG} -mpidebug 10 -study std4 -pname I_apply -plist 10e-5[A],12e-5[A],15e-5[A],16e-5[A]
#/apps/3rdparty-ep/COMSOL/COMSOL60_lnx/comsol60/multiphysics/bin/comsol batch -nnhost 2 --ntasks-per-node=4 -mode desktop -mpibootstrap slurm -inputfile ${INPUTFILE} -outputfile ${OUTPUTFILE} -batchlog ${BATCHLOG} -mpidebug 10 -study std4 -paramfile paramlist.txt
#/apps/3rdparty-ep/COMSOL/COMSOL60_lnx/comsol60/multiphysics/bin/comsol batch -nnhost 2 --ntasks-per-node=4 -mpibootstrap slurm -inputfile ${INPUTFILE} -outputfile ${OUTPUTFILE} -batchlog ${BATCHLOG} -mpidebug 10 -study std4 -paramfile paramlist.txt
#/apps/3rdparty-ep/COMSOL/COMSOL60_lnx/comsol60/multiphysics/bin/comsol batch -nn 8 -nnhost 4 -np 8 -inputfile ${INPUTFILE} -outputfile ${OUTPUTFILE} -batchlog ${BATCHLOG} -mpidebug 10 -study std3 -paramfile paramlist.txt
#/apps/3rdparty-ep/COMSOL/COMSOL60_lnx/comsol60/multiphysics/bin/comsol batch -nn 8 -nnhost 4 -np 8 -mpibootstrap slurm -inputfile ${INPUTFILE} -outputfile ${OUTPUTFILE} -batchlog ${BATCHLOG} -mpidebug 10 -study std3 -paramfile paramlist.txt
#/apps/3rdparty-ep/COMSOL/COMSOL60_lnx/comsol60/multiphysics/bin/comsol batch -nn 1 -nnhost 1 -np 16 -mpibootstrap slurm -inputfile ${INPUTFILE} -outputfile ${OUTPUTFILE} -batchlog ${BATCHLOG} -mpidebug 10 -study std4 -paramfile paramlist.txt
/apps/3rdparty-ep/COMSOL/COMSOL60_lnx/comsol60/multiphysics/bin/comsol batch -nn 1 -nnhost 1 -np 64 -mpibootstrap slurm -inputfile ${INPUTFILE} -outputfile ${OUTPUTFILE} -batchlog ${BATCHLOG} -mpidebug 10 -study std3 -paramfile paramlist.txt
#/apps/3rdparty-ep/COMSOL/COMSOL60_lnx/comsol60/multiphysics/bin/comsol batch -mpibootstrap slurm -inputfile ${INPUTFILE} -outputfile ${OUTPUTFILE} -batchlog ${BATCHLOG} -mpidebug 10 -study std3 -paramfile paramlist.txt
#/apps/3rdparty-ep/COMSOL/COMSOL60_lnx/comsol60/multiphysics/bin/comsol batch -mpibootstrap slurm -inputfile ${INPUTFILE} -outputfile ${OUTPUTFILE} -batchlog ${BATCHLOG} -mpidebug 10 -study std4 -paramfile paramlist.txt
#/apps/3rdparty-ep/COMSOL/COMSOL60_lnx/comsol60/multiphysics/bin/comsol batch -mpibootstrap slurm -inputfile ${INPUTFILE} -outputfile ${OUTPUTFILE} -batchlog ${BATCHLOG} -mpidebug 10 -study std4 -paramfile paramlist.txt
#/apps/3rdparty-ep/COMSOL/COMSOL60_lnx/comsol60/multiphysics/bin/comsol batch -mpibootstrap slurm -inputfile ${INPUTFILE} -outputfile ${OUTPUTFILE} -batchlog ${BATCHLOG} -mpidebug 10 -study std4 -paramfile paramlist.txt
#/apps/3rdparty-ep/COMSOL/COMSOL60_lnx/comsol60/multiphysics/bin/comsol batch -mpibootstrap slurm -inputfile ${INPUTFILE} -outputfile ${OUTPUTFILE} -batchlog ${BATCHLOG} -mpidebug 10 -study std4
#/apps/3rdparty-ep/COMSOL/COMSOL60_lnx/comsol60/multiphysics/bin/comsol batch -mpibootstrap slurm -inputfile ${INPUTFILE} -outputfile ${OUTPUTFILE} -batchlog ${BATCHLOG} -mpidebug 10 -study std3

# Run transient study std3 in comsol files
#comsol batch -inputfile ${INPUTFILE} -outputfile ${OUTPUTFILE} -study std3
#comsol batch -inputfile ${INPUTFILE} -outputfile ${OUTPUTFILE}
