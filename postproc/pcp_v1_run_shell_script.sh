#!/bin/sh
# embedded options to bsub - start with #BSUB

# -- Name of the job --
#BSUB -J pcp_v1

# -- specify queue --
#BSUB -q adept

# -- specify wall clock time to run as hh:mm --
##BSUB -W 04:00

# -- specify the number of processors --
#BSUB -n 16

# -- specify the number of nodes --
##BSUB -R "span[hosts=5]"

# -- user e-mail address --
#BSUB -u vananhthi.nguyen@mail.utoronto.ca
# -- mail notification --
# -- at start --
##BSUB -B
# -- at completion --
#BSUB -N

# -- Specify the output and error files. %J is the job ID --
# -- -o and -e mean append, -oo and-eo mean overwrite --
#BSUB -oo pcp_v1_J.out
#BSUB -eo pcp_v1_%J.err


# -- Model Input and output files --
MODELTOCOMPUTE="pcp_v1_in.mph"
MODELRESULT="pcp_v1_out.mph"

INPUTFILE="${HOME}/pcp_v1/${MODELTOCOMPUTE}"
OUTPUTFILE="${HOME}/pcp_v1/${MODELRESULT}"


# Run transient study std3 in comsol files
comsol batch -inputfile ${INPUTFILE} -outputfile ${OUTPUTFILE} -study std3