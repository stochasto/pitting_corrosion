
'''
This file analyzes the result of batch_analyze_1pit_std1.py to generate folders for std2 for single pits. 
The pit bottom conc is analyzed. For some currents this will be less than 2.8M. The first current at which conc reaches 3M or more is taken as the reference pit 
for that geometry. Earlier, this was done by hand after realizing that once a pit grows, any current could be applied. This led to a lot of manual work.
This script avoids all that manual work by automating.

The output is an excel file with locations of the std1 folders whose results will be copied to generate the std2 submit files.
For a given reference pit, a range of currents and stepzones are given

This will be submitted to study2.

For very small currents, study3 with no stepzone has to be applied. This will need a small change to the code.

'''


import numpy as np
import pandas as pd
import os

# Input folder where the actual std1 jobs were run
inDir = 'single_pit/std1'

logFile = 'std1.mph.log'
resultFile = 'results/single_pit/result_std1_singlepit.xlsx'
paramFile = 'paramlist.txt'
std1File = 'std1_result.mph'

# Output excel file with the address of the std1 folders
#outFile = 'std2_input_std1_twopit_conc_2200to2700.xlsx'
#outFile = 'std2_input_std1_rerun_conc_2200to2700.xlsx'
outFile = 'results/single_pit/std2_singlepit_smallcurrent_input.xlsx'

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

# Build the final std2 dataframe. After the correct std1 source folder is chosen, it will be used to populate this final dataframe
# with Iapply and stepzone values
# iStepList has a list of iapply and stepzones
iStepList =  [[9e-6,0.25], [1e-5,0.25], [1.75e-5,0.25], [2.5e-5,0.25], [3.25e-5,0.25], [5e-5,0.5], [7.5e-5,0.5], [1e-4,0.6]]

# Study 2
#iApply = [9e-6,1e-5,1.75e-5,2.5e-5,3.25e-5,5e-5,7.5e-5,1e-4]
#stepZone = [0.25,0.25,0.25,0.25,0.25,0.5,0.5,0.6]
# Study 3
iApply = [1e-6,2.5e-6,5e-6,7.5e-6]
stepZone = [0.25] * 4 # Stepzone is not used in study 3, just given for consistency

# Zip the two
iZip = list(zip(iApply,stepZone))
print(iZip)

# For a given geometry, the currents and stepzones in iZip should be given 
# These are numJobsPerGeom in number
numJobsPerGeom = len(iZip)

cols1 = ['rpit','theta','I_apply','stepzone','path']
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
                             		#print(lines)
                             		#z = df.loc[(df['rpit_1'] == lines[0]) & (df['rpit_2'] == lines[1]) &(df['theta_1'] == lines[2]) &(df['theta_2'] == lines[3]) &(df['I_apply'] == lines[4])]
					z = df.loc[(df['rpit_1'] == lines[0]) &  (df['theta_1'] == lines[1]) & (df['I_apply'] == lines[2])]
					#z = df.loc[(df['rpit_1'] == lines[0]) &  (df['theta_1'] == lines[1]) ]
					zList = z.values.tolist() # This is a list of lists
					#print(zList[0])
					#zList = zList[0]
                             		#if ((zList[0][5] >= 2700) or (zList[0][6] >= 2700)):
                             		#if (((zList[0][5] >= 2200) and (zList[0][5] < 2700) and (zList[0][6] < 2700)) or ((zList[0][6] >= 2200) and (zList[0][6] < 2700) and (zList[0][5] < 2700)) ):
					zList[0].append(inFolder)
					outList.append(zList[0])
	else:
		print('Missing log in: ',logPath)
		missingLog = missingLog + 1
#print(outList)

# Process outList. This now has rpit, theta, I_apply, conc and address of the source folder. So for a given r and theta, there are now a range of I_apply values
# Some of these I_apply do not go beyond 2.8M, they are not important. We only the first I_apply which gives a conc greater than 3M. This must be filtered out

df1 = pd.DataFrame(outList)
df1.columns = ['rpit','theta','I_apply','conc','path']

lenDf1 = len(df1)
print(lenDf1)

# Get the r, theta pairs
rads = df1['rpit'].unique()
angles = df1['theta'].unique()

numRads = len(rads)
numAngles = len(angles)

for i in range(numRads):
	r = rads[i]
	for j in range(numAngles):
		theta = angles[j]
		z = df1.loc[(df1['rpit'] == r) & (df1['theta'] == theta)] # Select geometry
		if (len(z)): # If geometry is found, process further
			z = z.sort_values(by=['conc'])
			#print(z)
			zConc = z.loc[z['conc'] > 2800] # Currents for which the given geometry satisfies growth condition
			if len(zConc):
				zF = zConc.iloc[[0]] # Select the first row among applied currents. The first current that shoots above 3M is chosen.
				#print(zF) 
				# Now that current is chosen, we know the source folder of std1 files. Generate the range of currents which must be tested
				rs = [r] * numJobsPerGeom
				thetas = [theta] * numJobsPerGeom
				pth = list(zF['path']) * numJobsPerGeom
				outList2 = list(zip(rs,thetas,iApply,stepZone,pth)) # This is a list of tuples
				dfTemp = pd.DataFrame(outList2,columns=cols1) # Convert list of tuples to a dataframe
				dfStd2 = pd.concat([dfStd2,dfTemp],ignore_index=True) # Concatenate dataframes

print(dfStd2)
dfStd2.to_excel(outFile)






# Create new dataframe for the output with address
#dfOut = pd.DataFrame(outList)
#dfOut.columns = ['rpit_1','rpit_2','theta_1','theta_2','I_apply','left_conc','right_conc','path']
#dfOut.to_excel(outFile)