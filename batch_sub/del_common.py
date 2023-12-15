import os

inDir = '/glb/home/invmfj/workdir_ir7/Code/Phase_Field/test/qlog/psweep/comsol_batch/results/single_pit/std2'

# Read list of files in destination
fListDest = 'fList_shou'
with open(fListDest,'r') as fDest:
	lines = [line.rstrip() for line in fListDest]

fListSource = os.listdir(inDir)

targets = []

for sourceFile in fListSource:
	if sourceFile in lines:
		targets.append(sourceFile)

print(targets)
