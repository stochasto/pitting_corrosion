#import numpy as np
import pandas as pd
import os
import shutil

paramData = pd.read_excel('std1_dpit_5mics_params_smallcurrent.xlsx')

# Enter first folder number #
print("Enter first folder number")
firstNum = int(input())

# Comsol parameter file name
comsolParamFile = 'paramlist.txt'

# Comsol file name
#comsolFile = 'std1.mph'
comsolFile = 'twopit_std1.mph'

# Slurm file name
slurmFile = 'runSlurm_std1.sh'

numFolders = paramData.shape[0]
print('Number of folders are ',numFolders)

numParams = paramData.shape[1]
print('Number of parameters are ',numParams)
cols = list(paramData.columns.values) # Column name list
print(cols)

firstLine = ""
for val in cols:
    firstLine += str(val) + " "

print(firstLine)

for i in range(numFolders):
	# Parameter values in the i'th row
	z = paramData.iloc[i,:]
	# Output folder name
	outStr = ""
	# Line of parameter values for the i'th parameter set
	paramLine = ""
	## Output folder name generation and parameter line ##
	for j in range(numParams):
		outStr += str(cols[j]) + "_" + str(z[j]) + "_"
		paramLine += str(z[j]) + " "
	outStr += str(firstNum)
	firstNum += 1
	print(outStr)
	print(paramLine)

	# Generate paramlist file
	with open(comsolParamFile,'a') as f:
		f.write(firstLine + '\n')
		f.write(paramLine+ '\n')

	os.mkdir(outStr)
	shutil.move(comsolParamFile,outStr)
	shutil.copy(comsolFile,outStr)
	shutil.copy(slurmFile,outStr)





