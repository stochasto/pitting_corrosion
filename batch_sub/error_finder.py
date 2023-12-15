''' This file searches for the word 'error' log files in a series of folders of param sweeps. Sometimes
due to limited comsol licenses, more than four jobs do not run at a time, and the jobs end with an error.
Hence, such failed jobs are scanned and then copied to a different folder.

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
inDir = 'std2/'
logFile = 'twopit_std2.mph.log'

# Folders to which log files with error to be copied to
outDir = 'std1_rerun2/'

# File list
inFolderList = os.listdir(inDir)
numFolders = len(inFolderList)
print('Number of folders: ',numFolders)

errorCount = 0
missingLog = 0

for i in range(numFolders):
       inFolder = inDir + inFolderList[i]
       if (os.path.isdir(inFolder)):
        logPath = inFolder + '/' + logFile
        if (os.path.isfile(logPath)):
             with open(logPath) as f:
                 logContents = f.readlines()
             if ('Error') in str(logContents):
                 print('Error found in: ',logPath)
                 errorCount = errorCount + 1
                 #os.system('cp -r %s %s' % (inFolder, outDir))
        else:
             print('Missing log in: ',logPath)
             missingLog = missingLog + 1
             #os.system('cp -r %s %s' % (inFolder, outDir))
        #if not (os.path.isfile(logPath)):
        #     print(inFolder)
        #     os.system('cp -r %s %s' % (inFolder, outDir))

print('Total error count: ',errorCount)
print('Total missing logs: ',missingLog)
    
    
