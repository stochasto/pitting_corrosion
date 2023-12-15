'''
Generate std3 files with smaller currents from reading std2 file.

Same geometry from the std2 jobs is taken, currents changed to small currents for std3.
'''


import numpy as np
import pandas as pd

# std2 file
std2File = 'std2_dpit_8mics_largecurr_final.xlsx'

# std3 output file 
std3File = 'std3_dpit_8mics.xlsx'

# Currents and stepzone (dummy)
iApply = [1e-6, 2.5e-6, 5e-6, 7.5e-6]
stepZone = [0.25, 0.25, 0.25, 0.25]

iZip = list(zip(iApply,stepZone))
numJobsPerGeom = len(iZip)

df2 = pd.read_excel(std2File)

cols1 = ['rpit_1','rpit_2','theta_1','theta_2','I_apply','stepzone','path']
df3 = pd.DataFrame(columns = cols1)

while ( not df2.empty):
	zSub = df2.loc[(df2['rpit_1'] == df2.iloc[0,0]) & (df2['rpit_2'] == df2.iloc[0,1]) & (df2['theta_1'] == df2.iloc[0,2]) & (df2['theta_2'] == df2.iloc[0,3])] # Select geometry
	zSubIndex = zSub.index
	r1 = [df2.iloc[0,0]] * numJobsPerGeom
	print(r1)
	r2 = [df2.iloc[0,1]]*numJobsPerGeom
	t1 = [df2.iloc[0,2]]*numJobsPerGeom
	t2 = [df2.iloc[0,3]]*numJobsPerGeom
	pth = [df2.iloc[0,6]]*numJobsPerGeom
	outList = list(zip(r1,r2,t1,t2,iApply,stepZone,pth))
	dfTemp = pd.DataFrame(outList,columns=cols1)
	df3 = pd.concat([df3,dfTemp],ignore_index=True)

	df2 = df2.drop(zSubIndex)

print(df3)
df3.to_excel(std3File)

	

