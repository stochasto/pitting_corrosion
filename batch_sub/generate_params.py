import numpy as np
import pandas as pd

### Radius start and end values, gap
rStart = 2e-6
rEnd = 10e-6
rGap = 2e-6

### List of angles
anglesDegree = [15,30,45,60,75]
anglesDegree = np.array(anglesDegree)
anglesRadian = anglesDegree*(np.pi/180)
numAngles = len(anglesRadian)

### Applied currents
#iApply = [1e-6,2.5e-6,5e-6,1e-5,2.5e-5,5e-5,7.5e-5,1e-4,2.5e-4,5e-4,7.5e-4,1e-3]
#iApply = [5e-5,7.5e-5,1e-4]
#iApply = [5e-5,7.5e-5,1e-4,2.5e-4,5e-4,7.5e-4,1e-3,2.5e-3]
iApply = [5e-5,7.5e-5,1e-4,2.5e-4]
numIapply = len(iApply)

### List of radii
numRads = int((rEnd - rStart)/rGap + 1)
radius = np.linspace(rStart,rEnd,numRads)

# Large radii
#radius = [25e-6,50e-6,75e-6,100e-6,250e-6,500e-6,750e-6,1000e-6]
#numRads = len(radius)

totalParamSets = numRads*numAngles*numIapply
print('Total parameter sets are ',totalParamSets)

### The array
allData = np.zeros((totalParamSets,3))

for radInd in range(numRads):
    for angInd in range(numAngles):
        for iInd in range(numIapply):
            ind = iInd + angInd*numIapply +radInd*numIapply*numAngles
            allData[ind,0] = radius[radInd]
            allData[ind,1] = anglesRadian[angInd]
            allData[ind,2] = iApply[iInd]
            
df1 = pd.DataFrame(allData)
df1.columns = ['rpit','theta','I_apply']

#df1.to_excel('std1_single_pit_params.xlsx')
df1.to_excel('std1_single_pit_largeradius_params.xlsx')
               

            
            



