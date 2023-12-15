''' This file searches for the word 'error' log files in a series of folders of param sweeps. Sometimes
due to limited comsol licenses, more than four jobs do not run at a time, and the jobs end with an error.
Hence, such failed jobs are scanned and then copied to a different folder.

Note: If a job does not run due to license unavailability, then both the words 'Error' and 'error'
are present in the log file. However, if a job fails due to numerical issues, then only the word 'Error' is
present in the file. This allows us to differentiate between jobs that did not run due to license problems and 
jobs that failed due to numerical issues. 

In this code, the word 'Error' is searched for. If found, it means that either due to non-availability of license
or due to numerical error, the job did not run and hence we cannot run study 2. If 'Error' is not found, then that
folder is moved to a target folder for std2 runs. In addition, the following changes are made:
1. The file twopit_std1_result.mph is renamed to twopit_std2.mph
2. runSlurm_std2.sh is copied to the folder

'''

import numpy as np
import pandas as pd
import os

# Input folder with batch sub folders
#inDir = 'qtest/etest/'
inDir = 'std1_twopit/'
logFile = 'twopit_std1.mph.log'
std1File = 'twopit_std1_result.mph'
std2File = 'twopit_std2.mph'
batchFile = 'runSlurm_std2.sh'

#inExcel = 'std2_list.xlsx'
inExcel = 'std2_smallconc_list.xlsx'

# Folders to which log files with error to be copied to
outDir = 'std2_smallconc/'

# File list
#inFolderList = os.listdir(inDir)

df = pd.read_excel(inExcel)

numFolders = df.shape[0]
print('Number of folders: ',numFolders)

nonErrorCount = 0
missingLog = 0

for i in range(numFolders):
       inFolder = df['path'][i]
       print(inFolder)
       if (os.path.isdir(inFolder)):
        logPath = inFolder + '/' + logFile
        std1FilePath = inFolder + '/' + std1File
        std2FilePath = inFolder + '/' + std2File
        if (os.path.isfile(logPath)):
             with open(logPath) as f:
                 logContents = f.readlines()
             if ((('Error') not in str(logContents)) and (os.path.isfile(std1FilePath))):
                 print('Generating std2 files for: ',logPath)
                 nonErrorCount = nonErrorCount + 1
                 os.system('cp %s %s' % (batchFile, inFolder))
                 os.system('cp %s %s' % (std1FilePath, std2FilePath))
                 os.system('cp -r %s %s' % (inFolder, outDir))
        else:
             print('Missing log in: ',logPath)
             missingLog = missingLog + 1
             #os.system('cp -r %s %s' % (inFolder, outDir))
        #if not (os.path.isfile(logPath)):
        #     print(inFolder)
        #     os.system('cp -r %s %s' % (inFolder, outDir))

print('Total std2 folders: ', nonErrorCount)
print('Total missing logs: ',missingLog)
    
    
