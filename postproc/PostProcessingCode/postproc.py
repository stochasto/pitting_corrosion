''' 
This file contains modular versions of Anh's postprocessing Jupyter code so that it can be run on the command line

Working:
get_files(): This function takes an input folder, which contains a series of input .txt files to be processed. It also asks
for an output directory, where, for each input file, a separate folder is created. In each such folder, all data files processed
for this .txt input file are stored. These files are:
	1. A series of .txt files indexed data_<timestep>.txt, this contains all grid points for that timestep.
	2. A file called 'data_along_pit_surface.csv', which contains data for points along the interface of the pits, for all time points
	3. A series of files called 'data_along_pit_nearest_neighbor_Pit_<timestep>.csv' which contains continuous data along pit surface for that timestep.

	For now, the locations of inDir and outDir are hardcoded.
	
'''

import phase_field_data_process_lib as pfdp
import phase_field_data_process_lib_parallel as pfdpar
import os
import pandas as pd
import numpy as np
import time
from multiprocessing import Pool
import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)

################################################# PARALLEL ##########################################yy

# Given an input folder inDir, it divides the total number of folders within this (one for each param set) among 
# processes. For each input folder, and output folder is created
def get_txt_files_parallel(pid,inDir, inFiles, outDir,vars_list,numProcs):
	start_time = time.time()

	numFiles = len(inFiles)
	fStart = int(pid*numFiles/numProcs)
	fEnd = int((pid+1)*numFiles/numProcs)

	print('pid: fStart: fEnd: ', pid, fStart, fEnd)

	for i in range(fStart,fEnd):
		print('Process ' + str(pid) + ' fName: ' + str(inFiles[i]))


	# variables list
	for fid in range(fStart,fEnd):
		inFile = inFiles[fid]
		inFilePath = inDir + '/' + inFile 
		x = inFile.split('_')
		x = x[2:-2]
		outFolderName = str(x[0])
		for i in range(1,len(x)):
			outFolderName = outFolderName + '_' + str(x[i])
		outFolder = outDir + '/' + outFolderName
		os.mkdir(outFolder)
		#print('Extracting files for ', inFile)
		print('Starting extraction by process ' + str(pid) + ' for file ' + str(inFile))
		pfdpar.data_all_split_file(filename=inFilePath, outFolderPath=outFolder, vars=vars_list )
		print('Finished extraction by process ' + str(pid) + ' for file ' + str(inFile))
		#print('Process done: ',pid)
		#print('File: ',inFile)
	end_time = time.time()
	print ("Process "+ str(pid) +" : " + str(round(end_time-start_time)) + " seconds")
	return pid

def get_surface_csv_parallel(outDir,phipf,xgap,meshRange,vars_list,exportPrefix):
	outFolders = os.listdir(outDir)
	for f in outFolders:
		outFolderPath = outDir + '/' + f
		outCSV = outFolderPath + '/' + 'data_along_pit_surface.csv'
		with Pool() as pool: 
			# call the same function with different data in parallel 
			items = [(i, outFolderPath, vars_list, meshRange, phipf, xgap, exportPrefix, numProcs) for i in range(numProcs)] 
			for result in pool.starmap(pfdpar.get_data_along_pit_surface_parallel, items):
				print("Process "+str(result)+" completed")
			#pfdpar.get_data_along_pit_surface(oFolder=outFolderPath, vars=vars_list,mesh=meshRange, phipf_threshold = phipf, xgap_val = xgap, progress_update=True,export_file=outCSV)


def get_nn_surface_parallel(outDir,vars_list,inputPrefix,outputPrefix,numProcs):
	outFolders = os.listdir(outDir)
	for f in outFolders:
		outFolderPath = outDir + '/' + f
		with Pool() as pool:
			items = [(i, outFolderPath, vars_list, inputPrefix, outputPrefix) for i in range(numProcs)]
			for result in pool.starmap(pfdpar.get_nn_surface_proc,items):
				print('Process ' + str(result) + 'completed' )


def get_depths_parallel(pid, outDir, nnFileName, depthFileName, dpit, numProcs):
	
	start_time = time.time()

	fList = os.listdir(outDir)
	numFiles = len(fList)
	fStart = int(pid*numFiles/numProcs)
	fEnd = int((pid+1)*numFiles/numProcs)

	print('pid: fStart: fEnd: ', pid, fStart, fEnd)

	for i in range(fStart,fEnd):
		outFolderPath = outDir + '/' + fList[i]
		nnFilePath = outFolderPath + '/' + outFileName
		pfdpar.get_depth_width(outFolderPath, fList[i], nnFileName, depthFileName, dpit)
	end_time = time.time()
	print ("Process get depths parallel "+ str(pid) +" : " + str(round(end_time-start_time)) + " seconds")
	return pid





################################################# PARALLEL ##########################################yy

def compile_and_sort_nn(outDir,vars_list,nnPrefix,outFileName,numProcs, ftype = '.csv'):
	start_time = time.time()
	outFolders = os.listdir(outDir)
	for f in outFolders:
		dfOut = pd.DataFrame(columns = vars_list)
		outFilePath = outDir + '/' + f + '/' + outFileName
		for pid in range(numProcs):
			nnFilePath = outDir + '/' + f + '/' + nnPrefix + '_' + str(pid) + ftype
			df = pd.read_csv(nnFilePath,index_col=0) 
			dfOut = pd.concat([dfOut,df],axis=0)
		#dfOut = dfOut.sort_values(by=['t'])
		dfOut.to_csv(outFilePath)
		print('NN file written for ' + str(f))
	end_time = time.time()
	print('Compile and sort time: ', str(round(end_time - start_time)), ' seconds')

def get_surface_csv(outDir,phipf,xgap,meshRange,vars_list):
	outFolders = os.listdir(outDir)
	for f in outFolders:
		outFolderPath = outDir + '/' + f
		outCSV = outFolderPath + '/' + 'data_along_pit_surface.csv'
		txtList = os.listdir(outFolderPath)
		pfdpar.get_data_along_pit_surface_parallel(oFolder=outFolderPath, vars=vars_list,mesh=meshRange, phipf_threshold = phipf, xgap_val = xgap, progress_update=True,export_file=outCSV)

def get_txt_files(inDir,outDir,vars_list):
	inFiles = os.listdir(inDir)
	# variables list
	for inFile in inFiles:
		inFilePath = inDir + '/' + inFile 
		x = inFile.split('_')
		x = x[2:-2]
		outFolderName = str(x[0])
		for i in range(1,len(x)):
			outFolderName = outFolderName + '_' + str(x[i])
		outFolder = outDir + '/' + outFolderName
		os.mkdir(outFolder)
		print('Extracting files for ', inFile)
		pfdpar.data_all_split_file(filename=inFilePath, outFolderPath=outFolder, vars=vars_list )

def clear_txt_files(outDir):
	fList = os.listdir(outDir)
	for f in fList:
		outFolderPath = outDir + '/' + f
		os.chdir(outFolderPath)
		os.system('rm -r *.txt')

def clear_unorg_files(outDir,inputPrefix, numProcs, ftype= '.csv'):
	fList = os.listdir(outDir)
	for f in fList:
		outFolderPath = outDir + '/' + f
		os.chdir(outFolderPath)
		for i in range(numProcs):
			unorgFile = inputPrefix + '_' + str(i) + ftype
			if (os.path.isfile(unorgFile)):
				os.remove(unorgFile)



def clear_nn_files(outDir,nnPrefix, numProcs, ftype= '.csv'):
	fList = os.listdir(outDir)
	for f in fList:
		outFolderPath = outDir + '/' + f
		os.chdir(outFolderPath)
		for i in range(numProcs):
			nnFile = nnPrefix + '_' + str(i) + ftype
			if (os.path.isfile(nnFile)):
				os.remove(nnFile)



if __name__ == '__main__':
	print('In main')
	###### VARIABLES ######
	# input directory with list of files that must be analyzed
	#inDir = '/glb/data/drs1/users/Bangalore/invmfj/iterativeRecon/B1M4/mlem_test/fdk_centershift/rocks/json/comsol_batch/post_test/temp/test_in'
	#inDir = '/glb/data/drs1/users/Bangalore/invmfj/iterativeRecon/B1M4/mlem_test/fdk_centershift/rocks/json/bng_backup/comsol_batch/dpit_2mics/std2_results_largeconc'
	#inDir = '/glb/data/drs1/users/Bangalore/invmfj/iterativeRecon/B1M4/mlem_test/fdk_centershift/rocks/json/bng_backup/comsol_batch/dpit_2mics/std2_smallcurr_results2'
	#inDir = '/glb/data/drs1/users/Bangalore/invmfj/iterativeRecon/B1M4/mlem_test/fdk_centershift/rocks/json/bng_backup/comsol_batch/dpit_2mics/std2_smallcurr_results1'
	#inDir = '/glb/data/drs1/users/Bangalore/invmfj/iterativeRecon/B1M4/mlem_test/fdk_centershift/rocks/json/bng_backup/comsol_batch/dpit_2mics/dpit_2mics_smallcurrent'
	#inDir = '/glb/data/drs1/users/Bangalore/invmfj/iterativeRecon/B1M4/mlem_test/fdk_centershift/rocks/json/bng_backup/comsol_batch/dpit_2mics/std2_new_smallcurr'
	inDir = '/glb/data/drs1/users/Bangalore/invmfj/iterativeRecon/B1M4/mlem_test/fdk_centershift/rocks/json/bng_backup/comsol_batch/single/std2'
	#inDir = '/glb/data/drs1/users/Bangalore/invmfj/iterativeRecon/B1M4/mlem_test/fdk_centershift/rocks/json/bng_backup/comsol_batch/dpit_5mics/std2_2pit_5mics/dpit_5mics_2em6'
	#inDir = '/glb/data/drs1/users/Bangalore/invmfj/iterativeRecon/B1M4/mlem_test/fdk_centershift/rocks/json/bng_backup/comsol_batch/dpit_5mics/std2_2pit_5mics/dpit_5mics_4em6'
	#inDir = '/glb/data/drs1/users/Bangalore/invmfj/iterativeRecon/B1M4/mlem_test/fdk_centershift/rocks/json/bng_backup/comsol_batch/dpit_5mics/std2_2pit_5mics/dpit_5mics_6em6'
	#inDir = '/glb/data/drs1/users/Bangalore/invmfj/iterativeRecon/B1M4/mlem_test/fdk_centershift/rocks/json/bng_backup/comsol_batch/dpit_5mics/std2_2pit_5mics/dpit_5mics_8em6'
	#inDir = '/glb/data/drs1/users/Bangalore/invmfj/iterativeRecon/B1M4/mlem_test/fdk_centershift/rocks/json/bng_backup/comsol_batch/dpit_5mics/std2_2pit_5mics/dpit_5mics_1em5'
	# output directory where processed files will be stored, a directory will be made for each input file which will contain the files
	#outDir = '/glb/data/drs1/users/Bangalore/invmfj/iterativeRecon/B1M4/mlem_test/fdk_centershift/rocks/json/comsol_batch/post_test/output'
	#outDir = '/glb/data/drs1/users/Bangalore/invmfj/iterativeRecon/B1M4/mlem_test/fdk_centershift/rocks/json/comsol_batch/post_test/output/dpit_2mics/std2_results_largeconc'
	#outDir = '/glb/data/drs1/users/Bangalore/invmfj/iterativeRecon/B1M4/mlem_test/fdk_centershift/rocks/json/comsol_batch/post_test/output/dpit_2mics/std2_smallcurr_results2'
	#outDir = '/glb/data/drs1/users/Bangalore/invmfj/iterativeRecon/B1M4/mlem_test/fdk_centershift/rocks/json/comsol_batch/post_test/output/dpit_2mics/std2_smallcurr_results1'
	#outDir = '/glb/data/drs1/users/Bangalore/invmfj/iterativeRecon/B1M4/mlem_test/fdk_centershift/rocks/json/comsol_batch/post_test/output/dpit_2mics/dpit_2mics_smallcurrent'
	#outDir = '/glb/data/drs1/users/Bangalore/invmfj/iterativeRecon/B1M4/mlem_test/fdk_centershift/rocks/json/comsol_batch/post_test/output/dpit_2mics/std2_new_smallcurr'
	outDir = '/glb/data/drs1/users/Bangalore/invmfj/iterativeRecon/B1M4/mlem_test/fdk_centershift/rocks/json/comsol_batch/post_test/output/single'
	#outDir = '/glb/data/drs1/users/Bangalore/invmfj/iterativeRecon/B1M4/mlem_test/fdk_centershift/rocks/json/comsol_batch/post_test/output/dpit_5mics/dpit_5mics_2em6'
	#outDir = '/glb/data/drs1/users/Bangalore/invmfj/iterativeRecon/B1M4/mlem_test/fdk_centershift/rocks/json/comsol_batch/post_test/output/dpit_5mics/dpit_5mics_4em6'
	#outDir = '/glb/data/drs1/users/Bangalore/invmfj/iterativeRecon/B1M4/mlem_test/fdk_centershift/rocks/json/comsol_batch/post_test/output/dpit_5mics/dpit_5mics_6em6'
	#outDir = '/glb/data/drs1/users/Bangalore/invmfj/iterativeRecon/B1M4/mlem_test/fdk_centershift/rocks/json/comsol_batch/post_test/output/dpit_5mics/dpit_5mics_8em6'
	#outDir = '/glb/data/drs1/users/Bangalore/invmfj/iterativeRecon/B1M4/mlem_test/fdk_centershift/rocks/json/comsol_batch/post_test/output/dpit_5mics/dpit_5mics_1em5'
	#outDir = '/glb/data/drs1/users/Bangalore/invmfj/iterativeRecon/B1M4/mlem_test/fdk_centershift/rocks/json/comsol_batch/post_test/output/dpit_2mics/temp'
	#outDir = '/glb/data/drs1/users/Bangalore/invmfj/iterativeRecon/B1M4/mlem_test/fdk_centershift/rocks/json/comsol_batch/post_test/temp/test_out'
	#outDir = '/glb/data/drs1/users/Bangalore/invmfj/iterativeRecon/B1M4/mlem_test/fdk_centershift/rocks/json/comsol_batch/post_test/csvtest'
	#outDir = '/glb/data/drs1/users/Bangalore/invmfj/iterativeRecon/B1M4/mlem_test/fdk_centershift/rocks/json/comsol_batch/post_test/full_out_test'
	vars_list= ['x', 'y', 'cMe', 'phil', 'phipf','phis','I','iloc','t']
	phipf = -0.15
	xgap = 0.02e-6
	meshRange = np.arange(-7.01e-5, 7.01e-5, 0.2e-6) # test

	#numProcs = 16
	################################################
	################################################
	################################################

	# Important. Set pit depth
	#dpit = 2e-6 
	dpit = 0
	#numProcs = 16
	numProcs = 32


	################################################
	################################################
	################################################

	inFiles = os.listdir(inDir)

	## Controls
	#getText = False
	##getText = True
	#getUnorg = False
	#clearTxt = False
	#getNN = False
	#clearUnorg = True
	#compileNN = False
	#clearNN = False
	#getDepth = False

	getText = False
	getUnorg = True
	clearTxt = True
	getNN = True
	clearUnorg = True
	compileNN = True
	clearNN = True
	getDepth = True


	# Serial function calls
	#get_txt_files(inDir,outDir,vars_list)
	#get_surface_csv(outDir,phipf,xgap,meshRange,vars_list)
	
	# Call parallel codes

	# Read the l
	# ist of files in inDir. For each file, an output folder is created in outDir. In each such folder, txt files are created for each timestep 
	if (getText):
		with Pool() as pool: 
			# call the same function with different data in parallel 
			#items = [(i, inDir, inFiles, outDir, vars_list, 32) for i in range(32)] 
			items = [(i, inDir, inFiles, outDir, vars_list, numProcs) for i in range(numProcs)] 
			for result in pool.starmap(get_txt_files_parallel, items):
				print("Process "+str(result)+" completed")

	

	# In each output folder, there are now a series of .txt files for each timestep. In each output folder, get_surface_csv_parallel generates numProcs number of 
	# files. Each such file has surface data for a few timesteps. As the output, there will be numProcs number of files of unorganized surface points.
	exportPrefix = 'unorg'
	if (getUnorg):
		get_surface_csv_parallel(outDir,phipf,xgap,meshRange,vars_list,exportPrefix)
	
	# remove txt files
	if (clearTxt): 
		clear_txt_files(outDir)

	# get_nn_surface_parallel takes in the numProcs files in each output folder and organizes them as per nearest neighbour. The output is again numProcs number of files
	# only this time organized. Each output file here has the same timesteps as the input file.
	inputPrefix = exportPrefix
	outputPrefix = 'nn'
	if (getNN):
		get_nn_surface_parallel(outDir,vars_list,inputPrefix,outputPrefix,numProcs)

	# Remove unorganized surface data files
	if (clearUnorg):
		clear_unorg_files(outDir, inputPrefix, numProcs)

	# In each output folder, there are now numProcs number of nearest neighbour files. Each file has a few timesteps data. All these files are compiled into a 
	# file with all the timesteps, called outFileName
	nnPrefix = outputPrefix
	outFileName = 'all_nn_data.csv'
	if (compileNN):
		compile_and_sort_nn(outDir,vars_list,nnPrefix,outFileName,numProcs)
	
	# Remove nearest neighbour surface data files
	if (clearNN):
		clear_nn_files(outDir, nnPrefix, numProcs)

	#get_depths_parallel(outDir,vars_list,outFileName)

	#dpit = 2e-6
	nnFileName = outFileName
	depthFileName = 'depth_time.csv'
	if (getDepth):
		with Pool() as pool: 
		# call the same function with different data in parallel 
			items = [(i, outDir, nnFileName, depthFileName, dpit, numProcs) for i in range(numProcs)] 
			#items = [(i, outDir, nnFileName, depthFileName, dpit, 2) for i in range(2)] 
			for result in pool.starmap(get_depths_parallel, items):
				print("Process "+str(result)+" completed")

	## Testing ##
	#outFolder = 'rpit_1_4E-6_rpit_2_1E-5_theta_1_0.785398163397448_theta_2_0.523598775598299_I_apply_7.5E-5'
	#nnFilePath = outDir + '/' + outFolder + '/' + 'all_nn_data_1.csv'
	#nnFileName = 'all_nn_data_1.csv'
	#outFileName = 'depth_time.csv'
	#pfdpar.get_depth_width(outDir, outFolder, nnFileName, outFileName, 2e-6, minDist = 5e-7)

	#nnFilePath = '/glb/data/drs1/users/Bangalore/invmfj/iterativeRecon/B1M4/mlem_test/fdk_centershift/rocks/json/comsol_batch/post_test/csvtest/unorg_0_only.csv'
	#pfdpar.get_nn_surface_proc(1,outDir,vars_list,'unorg_0','org')



# Parallel code placeholder
'''
	 with Pool() as pool:
	# call the same function with different data in parallel
	    items = [(i, ddFN, velzFN, numProcs) for i in range(numProcs)]
	    for result in pool.starmap(task, items):
	     # report the values from processes to show progress
	     print("Process "+str(result)+" completed")
'''
	
