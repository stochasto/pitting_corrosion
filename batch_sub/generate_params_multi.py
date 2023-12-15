import numpy as np
import pandas as pd

### Radius start and end values, gap
rStart = 1e-6
rEnd = 3e-6
rGap = 1e-6

# TEST
rStart = 1
rEnd = 3
rGap = 1

### Radius start and end values, gap, right ellipse
#rStart2 = 1e-6
#rEnd2 = 10e-6
#rGap2 = 0.5e-6

### List of angles
#anglesDegree = [15,30,45,60,75]
anglesDegree = [1,2]
anglesDegree = np.array(anglesDegree)
anglesRadian = anglesDegree*(np.pi/180)
numAngles = len(anglesRadian)

### Applied currents
#iApply = [1e-6,2.5e-6,5e-6,1e-5,2.5e-5,5e-5,7.5e-5,1e-4,2.5e-4,5e-4,7.5e-4,1e-3]
#iApply = [1e-6,5e-6,1e-5,5e-5,7.5e-5,1e-4,5e-4,7.5e-4,1e-3]
iApply = [1e-6,1e-5]
numIapply = len(iApply)

### List of radii
numRads = int((rEnd - rStart)/rGap + 1)
radius = np.linspace(rStart,rEnd,numRads)

totalParamSets = int(0.5*numRads*(numRads + 1)*numAngles*numAngles*numIapply)
print('Total parameter sets are ',totalParamSets)

### The array
allData = np.zeros((totalParamSets,5))

for radInd1 in range(numRads - 1):
	for radInd2 in range(radInd1, numRads):
		for angInd1 in range(numAngles):
			for angInd2 in range(numAngles):
        			for iInd in range(numIapply):
            				ind = iInd + angInd2*numIapply +angInd1*numAngles*numIapply + radInd2*numAngles*numAngles*numIapply + radInd1*(numRads - radInd1 + 1)*numAngles*numAngles*numIapply
            				allData[ind,0] = radius[radInd1]
            				allData[ind,1] = radius[radInd2]
            				allData[ind,2] = anglesRadian[angInd1]
            				allData[ind,3] = anglesRadian[angInd2]
            				allData[ind,4] = iApply[iInd]
            
df1 = pd.DataFrame(allData)
df1.columns = ['rpit_1','rpit_2','theta_1','theta_2','I_apply']

df1.to_excel('std1_twopit_params.xlsx')
               

            
            



