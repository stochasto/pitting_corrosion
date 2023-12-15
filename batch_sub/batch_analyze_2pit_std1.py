''' This script reads the batch results of std1 2 pit simulations and reads the concentrations at the bottom of both left and right pit.
The input is the directory of text files with the information and the output is an excel sheet, where each row corresponds to a param set
and the concentrations of left and right pit are written in two adjacent columns
'''

import numpy as np
import pandas as pd
import os

# Folder
#inDir = 'results/twopit_std1/dpit_2mics_smallcurrent/'
#inDir = 'results/dpit_5mics/std1_twopit_5mics/'
inDir = 'results/dpit_8mics/std1_twopit_8mics/'

# Output file name
outFile = 'results/dpit_8mics/result_std1_dpit_8mics_largecurr.xlsx'

# File list
inFileList = os.listdir(inDir)
numFiles = len(inFileList)
print('Number of files: ',numFiles)

# Output structure
allData = np.zeros((numFiles,8))

for i in range(numFiles):
    fName = inFileList[i]
    fPath = inDir + fName
    with open(fPath) as f:
        lines = [line.rstrip() for line in f]
    lines = lines[-1]
    lines = str(lines).split()
    allData[i,0] = lines[0]  # rpit_1
    allData[i,1] = lines[1]  # rpit_2
    allData[i,2] = lines[2]  # theta_1
    allData[i,3] = lines[3]  # theta_2
    allData[i,4] = lines[4]  # I_apply
    allData[i,5] = lines[5]  # left_conc
    allData[i,6] = lines[7]  # right_conc
    allData[i,7] = lines[8]  # right_conc

df1 = pd.DataFrame(allData)
df1.columns = ['rpit_1','rpit_2','theta_1','theta_2','I_apply','stepzone','left_conc','right_conc']
df1.to_excel(outFile)


