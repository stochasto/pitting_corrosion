#import required packages
import numpy as np
import time
import os
import sys
import re
import csv
import pandas as pd


from multiprocessing import Pool
# Task to execute in each process
def task(value, ddFN, velzFN, numProcs):
 start_time = time.time()
#-------------------------------------------------------------------------------    
# Get inputs

# ddFN = 'dd0.raw'
 dd = np.fromfile(ddFN, dtype='float32', sep="")
 velz = np.fromfile(velzFN, dtype='float32', sep="")

 n_cores = numProcs
 nx = 650
 ny = 650
 nz = 650
 buff = 16
 nz_buff = nz + 2 * buff
 N=nx*ny*nz_buff
 if N != len(dd):
  print("Image Size doesnt match with size in File name")
  sys.exit()
 dd =dd.reshape(nz_buff,ny,nx)
 velz =velz.reshape(nz_buff,ny,nx)
 
 # Sets all the values to NP or NWP
 dd[dd>0] = 1
 dd[dd<0] = -1
 
 k_start = buff + int(value*nz/n_cores)
 k_end = buff + int((value+1)*nz/n_cores)
 
 Rock_Lbl = 0
 WP_Lbl = 1
 NWP_Lbl = -1
 
 Rock_Count = np.zeros( 2* buff + nz + 1, dtype='int')
 WP_Count = np.zeros( 2* buff + nz + 1, dtype='int')
 NWP_Count = np.zeros( 2* buff + nz + 1, dtype='int')
 Slice = np.zeros( 2* buff + nz + 1, dtype='int')
 WP_velz = np.zeros( 2* buff + nz + 1, dtype='float32')
 NWP_velz = np.zeros( 2* buff + nz + 1, dtype='float32')
 
 for k in range(k_start, k_end):
  #for j in range (1,ny-1):
  for j in range (ny):
   #for i in range (1,nx-1):
   for i in range (nx):
     Slice[k] = k
     if dd[k,j,i] ==  Rock_Lbl:
      Rock_Count[k] += 1
     elif dd[k,j,i] == WP_Lbl:
      WP_Count[k] += 1
      WP_velz[k] += velz[k,j,i]
     elif dd[k,j,i] == NWP_Lbl:
      NWP_Count[k] += 1
      NWP_velz[k] += velz[k,j,i]
     else:
      print("Label Unrecogonised")
      sys.exit()
 oFN = 'tmp_file'+ str(value) + '.csv'
 with open(oFN, 'w', newline='') as csvfile:
  fieldnames = ['Slice', 'Rock_Count', 'WP_Count', 'NWP_Count', 'WP_velz_avg', 'NWP_velz_avg']
  writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
  writer.writeheader()
  for i in range(len(Slice)):
   if Slice[i] > 0:
    WP_velz_avg = WP_velz[i]/WP_Count[i]
    NWP_velz_avg = NWP_velz[i]/NWP_Count[i]
    writer.writerow({'Slice': Slice[i], 'Rock_Count': Rock_Count[i], \
                     'WP_Count': WP_Count[i], 'NWP_Count': NWP_Count[i], \
                     'WP_velz_avg': WP_velz_avg, 'NWP_velz_avg': NWP_velz_avg })
    
#print("Slice %d to %d : Rock %d WP %d NWP %d" %(k_start, k_end-1, Rock_Count, WP_Count, NWP_Count))
 
 end_time = time.time()
 print ("Process "+ str(value) +" : " + str(round(end_time-start_time)) + " seconds")
 return value

# Entry point for the program
if __name__ == '__main__':
 start_time = time.time()
 dirFiles = [filename for filename in os.listdir('.') if filename.startswith("dd")]
 dirFiles.sort(key=lambda f: int(re.sub('\D', '', f)))
 print(dirFiles)
 print("Checking availability Velocity file")
 for ddFN in dirFiles:
  velzFN = ddFN.replace('dd','velz')
  if not os.path.isfile(velzFN):
   print(velzFN, ' not found, exiting')
   sys.exit()
 for ddFN in dirFiles:
  nameFN, ext = os.path.splitext(ddFN)
  print('Processing :', ddFN)
  numProcs = 32
  # create the process pool
  with Pool() as pool: 
   # call the same function with different data in parallel 
   items = [(i, ddFN, velzFN, numProcs) for i in range(numProcs)] 
   for result in pool.starmap(task, items):
    # report the values from processes to show progress
    print("Process "+str(result)+" completed")
  wData = pd.DataFrame()
  for i in range(numProcs):
   rFN = 'tmp_file'+ str(i) + '.csv'
   data = pd.read_csv(rFN)
   wData = pd.concat([wData, data], axis=0)
   oFN = 'SliceData_'+nameFN+'.csv'
   wData.to_csv(oFN, index=False)
   os.remove(rFN)

  end_time = time.time()
  print ("Run Time" + str(round(end_time-start_time)) + " seconds")
