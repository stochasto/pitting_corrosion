''' This file has a function to compare two dataframes. After std1 is run there are a lot of files. These are analyzed by batch_analyze_2pit_std1.py
to generate pit bottom concentrations. This file is further processed with std2_conacnalyzer.py to yield a big dataframe with a bunch of currents for each geometry. Pit bottom 
concs which satisfy stability criteria are chosen. However this yields a large number of jobs, we only have to select a subset for std2. The subsets were earlier done manually. 
dpit of  2mics and 5 mics were run for some geometries in a very manual way. A subset of dpit 8 mics were also chosen in bhaskara, manually, for these geometries by looking at the done
files in local comp. Now dpit of 8 mics has to be run in shou. For this, the bhaskara excel file is taken as input, since this has the manually chosen geometries for running std2. This file will
be used as source to choose geometries in the large std2 file run here (output of std2_concanalyzer). Finally, those geometries are selected automatically here.'''

import numpy as np
import pandas as pd

# The input subset file with required geometries (made in Bhaskara manually)
subsetFile = 'std2_largecurr_final_bhask.xlsx'
# The file with all the geometries here
fullFile = 'std2_largecurr_input.xlsx'

# Output file
outFile = 'std2_dpit_8mics_largecurr_final.xlsx'

dfSub = pd.read_excel(subsetFile)
dfFull = pd.read_excel(fullFile)

zKeepIndex = []

while (not dfSub.empty):
	zSub = dfSub.loc[(dfSub['rpit_1'] == dfSub.iloc[0,0]) & (dfSub['rpit_2'] == dfSub.iloc[0,1]) & (dfSub['theta_1'] == dfSub.iloc[0,2]) & (dfSub['theta_2'] == dfSub.iloc[0,3])] # Select geometry
	zSubIndex = zSub.index
	zKeep = dfFull.loc[(dfFull['rpit_1'] == dfSub.iloc[0,0]) & (dfFull['rpit_2'] == dfSub.iloc[0,1]) & (dfFull['theta_1'] == dfSub.iloc[0,2]) & (dfFull['theta_2'] == dfSub.iloc[0,3])] # Select geometry
	#print(zFull)
	zKeepTempIndex = list(zKeep.index)
	if (len(zKeepTempIndex)):
		print(zKeepTempIndex)
		zKeepIndex.extend(zKeepTempIndex)
		#zFullIndex.append(list(zFull.index))
	dfSub = dfSub.drop(zSubIndex)
	print(len(dfSub))

print('zKeepIndex: ',zKeepIndex)
#zFullDropIndex = list(dfFull.index)
zFullIndex = list(dfFull.index)
zFullDropIndex = []
zFullDropIndex = [x for x in zFullIndex if x not in zKeepIndex]
print('zFullDropIndex: ',zFullDropIndex)
dfFull = dfFull.drop(zFullDropIndex)

print(dfFull)
dfFull.to_excel(outFile)
