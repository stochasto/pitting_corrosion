
'''
This file is used to obtain an excel file with job details and folder address of those std1 jobs
that ran successfully AND have both pit bottom concentration greater than Ccrit which is 2.7 M. 
These successful jobs are written in a given excel sheet. 

This file scans all folders in a given directory. Some of these jobs will not have run due to license or numerical error. 
If the log file does not contain the word 'Error' and if a result file is found, then it means that
the job ran successfully. Then, the corresponding data is searched in the folder with all the text files
with the std1 results. Depending on the resulting concentrations of the left and right pits, the data
are written to the appropriate sheet in the output excel.

Note: This script needs the an excel file where the text files have already been parsed and the concentrations
recorded. To generate this file, first run batch_analyze_2pit_std1.py

Note: If a job does not run due to license unavailability, then both the words 'Error' and 'error'
are present in the log file. However, if a job fails due to numerical issues, then only the word 'Error' is
present in the file. This allows us to differentiate between jobs that did not run due to license problems and 
jobs that failed due to numerical issues. 

'''

import numpy as np
import pandas as pd
import os

# Input folder with batch sub folders
#inDir = 'qtest/etest/'

#inDir = 'std1_twopit/'
inDir = 'std1_rerun/'

logFile = 'twopit_std1.mph.log'
resultFile = 'results/result_twopit_std1_alldata.xlsx'
paramFile = 'paramlist.txt'
std1File = 'twopit_std1_result.mph'

# Output excel file with the address of the std1 folders
#outFile = 'std2_input_std1_twopit_conc_2200to2700.xlsx'
outFile = 'std2_input_std1_rerun_conc_2200to2700.xlsx'

# File list
inFolderList = os.listdir(inDir)
numFolders = len(inFolderList)
print('Number of folders: ',numFolders)

errorCount = 0
missingLog = 0

# Read the result excel
df = pd.read_excel(resultFile)
df = df.astype(float)
#print('df exp: ',df.loc[df['rpit_1'] == 2e-6])


outList = []

for i in range(numFolders):
#for i in range(100):
       inFolder = inDir + inFolderList[i]
       if (os.path.isdir(inFolder)):
        logPath = inFolder + '/' + logFile
        std1FilePath = inFolder + '/' + std1File # Check if std1 result file is present
        if (os.path.isfile(logPath)):
              with open(logPath) as f:
                   logContents = f.readlines()
                   if ((('Error') not in str(logContents)) and (os.path.isfile(std1FilePath))):
                        #print('Error not found in: ',logPath)
                        paramPath = inFolder + '/' + paramFile
                        with open(paramPath) as p2:
                             lines = [line.rstrip() for line in p2]
                             lines = lines[-1]
                             lines = str(lines).split()
                             lines = list(map(float,lines))
                             #print(lines)
                             z = df.loc[(df['rpit_1'] == lines[0]) & (df['rpit_2'] == lines[1]) &(df['theta_1'] == lines[2]) &(df['theta_2'] == lines[3]) &(df['I_apply'] == lines[4])]
                             zList = z.values.tolist() # This is a list of lists
                             #zList = zList[0]
                             #if ((zList[0][5] >= 2700) or (zList[0][6] >= 2700)):
                             if (((zList[0][5] >= 2200) and (zList[0][5] < 2700) and (zList[0][6] < 2700)) or ((zList[0][6] >= 2200) and (zList[0][6] < 2700) and (zList[0][5] < 2700)) ):
                                  zList[0].append(inFolder)
                                  outList.append(zList[0])
                                  #print(zList)
                                  #print(outList)
                             #print(zList)
        else:
             print('Missing log in: ',logPath)
             missingLog = missingLog + 1

# Create new dataframe for the output with address
dfOut = pd.DataFrame(outList)
dfOut.columns = ['rpit_1','rpit_2','theta_1','theta_2','I_apply','left_conc','right_conc','path']
dfOut.to_excel(outFile)
