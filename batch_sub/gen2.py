import numpy as np
import pandas as pd
import itertools as it
import math

### Radius start and end values, gap
rStart = 2e-6
rEnd = 10e-6
rGap = 2e-6

# TEST
#rStart = 1
#rEnd = 3
#rGap = 1

### Radius start and end values, gap, right ellipse
#rStart2 = 1e-6
#rEnd2 = 10e-6
#rGap2 = 0.5e-6

### List of angles
anglesDegree = [15,30,45,60,75]
#anglesDegree = [30,45]
anglesDegree = np.array(anglesDegree)
anglesRadian = anglesDegree*(np.pi/180)
numAngles = len(anglesRadian)

### Applied currents
#iApply = [1e-6,2.5e-6,5e-6,1e-5,2.5e-5,5e-5,7.5e-5,1e-4,2.5e-4,5e-4,7.5e-4,1e-3]
#iApply = [1e-6,5e-6,1e-5,5e-5,7.5e-5,1e-4,5e-4,7.5e-4,1e-3]
#iApply = [1e-5,1.75e-5,2.5e-5,5e-5,7.5e-5,1e-4]
#iApply = [1.75e-5,2.5e-5,3.25e-5,4e-5,5e-5,7.5e-5,1e-4]
#iApply = [5e-5,7.5e-5,9e-5,1e-4]
#iApply = [5e-5,7.5e-5,1e-4,2.5e-4,5e-4,7.5e-4,1e-3,2.5e-3]
iApply = [7.5e-5,1e-4,2.5e-4]
#iApply = [1e-6,1e-7]
numIapply = len(iApply)

# Epsilon step
stepzone = [0.25]


### List of radii
numRads = round((rEnd - rStart)/rGap + 1)
print((rEnd - rStart)/rGap + 1)
print('numrads is i',numRads)
radius = np.linspace(rStart,rEnd,numRads)
print('Radius is ',radius)

#totalParamSets = int(0.5*numRads*(numRads + 1)*numAngles*numAngles*numIapply)
#print('Total parameter sets are ',totalParamSets)

### The array
#allData = np.zeros((totalParamSets,5))
rlist = [radius]
print('rlist is ',rlist)
print('iApply is ',*iApply)
rprod = list(it.combinations_with_replacement(*rlist,2))
print('rprod is ',rprod)
iprod = list(it.combinations_with_replacement(iApply,2))

print('iprod is ',iprod)
#allprod = list(it.product(rprod,anglesRadian,anglesRadian,iApply))
allprod = list(it.product(rprod,anglesRadian,anglesRadian,iApply,stepzone))
#allprod = list(it.product(*rprod,*[anglesRadian],*[anglesRadian],*iApply))
print(allprod[1])
print(allprod[1][1])
print(allprod[1][0][0])

numCombs = len(allprod)



#allData = np.zeros((numCombs,5))
allData = np.zeros((numCombs,6))
#l = [radius,anglesDegree,iApply]
#c = list(it.product(*l))
#print(c)
for ind in range(numCombs):
	allData[ind,0] = allprod[ind][0][0]
	allData[ind,1] = allprod[ind][0][1]
	allData[ind,2] = allprod[ind][1]
	allData[ind,3] = allprod[ind][2]
	allData[ind,4] = allprod[ind][3]
	allData[ind,5] = allprod[ind][4]
            
df1 = pd.DataFrame(allData)
#df1.columns = ['rpit_1','rpit_2','theta_1','theta_2','I_apply']
df1.columns = ['rpit_1','rpit_2','theta_1','theta_2','I_apply','stepzone']

#df1.to_excel('std1_twopit_params_smallcurrent.xlsx')
#df1.to_excel('std1_dpit_5mics_params_stepzone.xlsx')
#df1.to_excel('std1_dpit_5mics_params_smallcurrent.xlsx')
df1.to_excel('std1_dpit_8mics.xlsx')
               

            
            



