# Run this file in comsol_batch folder
# This file reads an input excel file and copies files from runs which have exceeded Ccrit and then
# runs the same with smaller currents. In order for pits to grow, the bottom concs must exceed Ccrit which 
# is 2700. 
# Details of these jobs and their source file folders are in the excel which is read in paramData.

#import numpy as np
import pandas as pd
import os
import shutil

#paramData = pd.read_excel('std2_dpit_2um_aboveccrit_smallcurrent.xlsx')
#paramData = pd.read_excel('std2_dpit_2um_aboveccrit_vsmallcurrent.xlsx')
#paramData = pd.read_excel('std2_dpit_2um_aboveccrit_vsmallcurrent_2.xlsx')
#paramData = pd.read_excel('std2_dpit_2um_aboveccrit_vsmallcurrent_3.xlsx')
#paramData = pd.read_excel('std2_dpit_5mics_medium.xlsx')
#paramData = pd.read_excel('std2_dpit_5mics_high.xlsx')
#paramData = pd.read_excel('std2_dpit_5mics_low.xlsx')
#paramData = pd.read_excel('results/single_pit/std2_singlepit_input_2.xlsx')
#paramData = pd.read_excel('results/single_pit/std2_singlepit_smallcurrent_input_2.xlsx')
#paramData = pd.read_excel('results/dpit_5mics/std3_smallcurr_final_1.xlsx')
#paramData = pd.read_excel('results/dpit_5mics/std3_smallcurr_final_2.xlsx')
#paramData = pd.read_excel('results/dpit_8mics/std2_largecurr_final_1.xlsx')
paramData = pd.read_excel('results/dpit_8mics/std2_largecurr_final_2.xlsx')

# Enter first folder number #
print("Enter first folder number")
firstNum = int(input())

# Comsol parameter file name
comsolParamFile = 'paramlist.txt'

# Comsol file name
#comsolFile = 'std1.mph'
#std1File = 'twopit_std1_result.mph'
#std2File = 'twopit_std2.mph'

std1File = 'twopit_std1_result.mph'
std2File = 'twopit_std2.mph'
#std2File = 'twopit_std3.mph'

# Single pit
#std1File = 'std1_result.mph'
#std2File = 'std2.mph'
#std2File = 'std3.mph'

# Output directory where folders will be generated
#outDir = 'std2_dpit_2mics_smallcurrent'
#outDir = 'dpit_5mics/std2_5mics_low'
#outDir = 'single_pit/std2/s2'
#outDir = 'single_pit/std3/s2'
#outDir = 'dpit_5mics/std3/a4'
#outDir = 'dpit_5mics/std3/a6'
#outDir = 'dpit_8mics/std2/a1'
outDir = 'dpit_8mics/std2/a4'

# Slurm file name
slurmFile = 'runSlurm_std2.sh'
#slurmFile = 'runSlurm_std3.sh'

numFolders = paramData.shape[0]
print('Number of folders are ',numFolders)

cols = list(paramData.columns.values) # Column name list
print(cols)
numParams = len(cols) - 1
print('Number of parameters are ',numParams)

firstLine = ""
#for val in cols:
#firstLine += str(val) + " "

for i in range(numParams):
    firstLine += str(cols[i]) + " "

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
	
	# Get std1 result from original folder and copy to new folder
	inFolder = str(z[-1])
	std1FilePath = inFolder + '/' + std1File
	outStd2Folder = outDir + '/' + outStr
	outPath = outStd2Folder + '/' + std2File

	os.mkdir(outStd2Folder)
	shutil.move(comsolParamFile,outStd2Folder)
	#shutil.copy(std1FilePath,outStd2Folder)
	shutil.copy(std1FilePath,outPath)
	shutil.copy(slurmFile,outStd2Folder)





