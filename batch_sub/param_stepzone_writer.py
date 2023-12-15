import os
import numpy as np

inDir = '/glb/home/invmfj/workdir_ir7/Code/Phase_Field/test/qlog/psweep/comsol_batch/single_pit/std2/s2'

fList = os.listdir(inDir)

#print(fList)

nFiles = len(fList)

print('nFiles is ',nFiles)

cols = ['rpit','theta','I_apply','stepzone']

firstLine = ""
for val in cols:
    firstLine += str(val) + " "

for i in range(nFiles):
	inFilePath = os.path.join(inDir,fList[i])
	if (os.path.isdir(inFilePath)):
		paramFilePath = os.path.join(inFilePath,'paramlist.txt')
		paramLine = ""

		folderNameSplit = str(fList[i]).split('_')
		print(len(folderNameSplit))
		folderNameSplit[8] = str(0.6) # this is stepzone

		# write paramline
		paramLine = str(folderNameSplit[1]) + " " + str(folderNameSplit[3]) + " " + str(folderNameSplit[6]) + " " + str(folderNameSplit[8])
		print(paramLine)
		with open(paramFilePath,'w') as f:
			f.write(firstLine + '\n')
			f.write(paramLine+ '\n')

		#with open(paramFilePath,'r+') as paramFile:
		#	lines = [line.rstrip() for line in paramFile]
		#	print(lines)