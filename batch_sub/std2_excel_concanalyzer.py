''' This file is just like concanalyzer. The only difference is in the second part. Instead of giving a fixed set of currents and stepzones, they are just read from a file.
The main thing that is required is the path of the input std1 file which is obtained from outList.'''

import numpy as np
import pandas as pd
import os

# Input folder where the actual std1 jobs were run
#inDir = 'single_pit/std1'
#inDir = 'dpit_5mics/std1_2pit_5mics/smallcurr/all'
#inDir = 'dpit_8mics/std1/all'
inDir = 'dpit_5mics/std1_2pit_5mics/pending'

logFile = 'twopit_std1.mph.log'
#resultFile = 'results/single_pit/result_std1_singlepit.xlsx'
#resultFile = 'results/dpit_5mics/result_std1_dpit_5mics_smallcurr.xlsx'
#resultFile = 'results/dpit_8mics/result_std1_dpit_8mics_largecurr.xlsx'
resultFile = 'results/dpit_5mics/result_std1_dpit_5mics_pending.xlsx'
paramFile = 'paramlist.txt'
std1File = 'twopit_std1_result.mph'

# Output excel file with the address of the std1 folders
#outFile = 'std2_input_std1_twopit_conc_2200to2700.xlsx'
#outFile = 'std2_input_std1_rerun_conc_2200to2700.xlsx'
#outFile = 'results/single_pit/std2_singlepit_smallcurrent_input.xlsx'
#outFile = 'results/dpit_5mics/std3_smallcurr_input.xlsx'
#outFile = 'results/dpit_8mics/std2_largecurr_input.xlsx'
outFile = 'results/dpit_5mics/std2_pending_input.xlsx'

# Excel file with geometries and currents
refExcel = 'results/dpits_align.xlsx'
dfRef = pd.read_excel(refExcel,sheet_name='5mics')

# File list
inFolderList = os.listdir(inDir)
numFolders = len(inFolderList)
print('Number of folders: ',numFolders)

errorCount = 0
missingLog = 0

# Read the result excel
df = pd.read_excel(resultFile)
df = df.astype(float)

outList = []

cols1 = ['rpit_1','rpit_2','theta_1','theta_2','I_apply','stepzone','path']
dfStd2 = pd.DataFrame(columns = cols1)

for i in range(numFolders):
#for i in range(20):
	inFolder = os.path.join(inDir, inFolderList[i])
	if (os.path.isdir(inFolder)):
		logPath = os.path.join(inFolder,logFile)
		std1FilePath = os.path.join(inFolder,std1File) # Check if std1 result file is present
	else:
		continue
	if (os.path.isfile(logPath)):
		with open(logPath) as f:
			logContents = f.readlines()
			if ((('Error') not in str(logContents)) and (os.path.isfile(std1FilePath))):
				paramPath = os.path.join(inFolder,paramFile)
				with open(paramPath) as p2:
					lines = [line.rstrip() for line in p2]
					lines = lines[-1]
					lines = str(lines).split()
					lines = list(map(float,lines))
					z = df.loc[(df['rpit_1'] == lines[0]) & (df['rpit_2'] == lines[1]) &(df['theta_1'] == lines[2]) &(df['theta_2'] == lines[3]) &(df['I_apply'] == lines[4])]
					zList = z.values.tolist() # This is a list of lists
					zList[0].append(inFolder)
					outList.append(zList[0])
	else:
		print('Missing log in: ',logPath)
		missingLog = missingLog + 1

df1 = pd.DataFrame(outList)
df1.columns = ['rpit_1','rpit_2','theta_1','theta_2','I_apply','stepzone','left_conc','right_conc','path']

lenDf1 = len(df1)
print(lenDf1)

counter = 0

while (not df1.empty):
	z = df1.loc[(df1['rpit_1'] == df1.iloc[0,0]) & (df1['rpit_2'] == df1.iloc[0,1]) & (df1['theta_1'] == df1.iloc[0,2]) & (df1['theta_2'] == df1.iloc[0,3])] # Select geometry
	zRef = dfRef.loc[(dfRef['rpit_1'] == df1.iloc[0,0]) & (dfRef['rpit_2'] == df1.iloc[0,1]) & (dfRef['theta_1'] == df1.iloc[0,2]) & (dfRef['theta_2'] == df1.iloc[0,3])] # Select geometry in reference excel
	zIndex = z.index
	zRefIndex = zRef.index
	if (len(z)): # If geometry is found, process further
		z = z.sort_values(by=['left_conc','right_conc'])
		#print(z)
		zConcBoth = z.loc[(z['left_conc'] > 2800) & (z['right_conc'] > 2800)] # Currents for which the given geometry satisfies growth condition
		zConcOne = z.loc[(z['left_conc'] > 2800) | (z['right_conc'] > 2800)] # Currents for which the given geometry satisfies growth condition
		if len(zConcBoth):
			zF = zConcBoth.iloc[[0]] # Select the first row among applied currents. The first current that shoots above 3M is chosen.
			dfRef.loc[zRefIndex,'path'] = str(zF.iloc[0,-1])
		elif (len(zConcOne)):
			zF = zConcOne.iloc[[0]] # Select the first row among applied currents. The first current that shoots above 3M is chosen.
			dfRef.loc[zRefIndex,'path'] = str(zF.iloc[0,-1])
	# Drop seen rows
	df1 = df1.drop(zIndex)

print(dfRef)
dfRef.to_excel(outFile)
