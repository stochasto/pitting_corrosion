import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os
import time

def read_data_file(file,variable_list):
    #print(variable_list)
    df = pd.read_csv(file, sep="\t", header=None)
    #print(variable_list)
    df.columns = variable_list
    return df

def get_time_from_filename(file):
    time_cue = file.split('_', 1)[1].split('.', 1)[0]
    if 'calibrate' in file:
        time_file = 0
    else:
        time_file = float(time_cue.replace('p', '.').replace('s', ''))
    return time_file

def get_file_from_time(time_file_dict,time_input):
    for file, t in time_file_dict.items():  # for name, age in dictionary.iteritems():  (for Python 2.x)
        if t == time_input:
            #print(file)
            return file


def get_values_pits_verline(df,xline,y_diffusionLayer=0,xgap=1e-7,plot=False):
    # Get the value along the vertical x=xline without the diffusion layer as default:
    
    df_xline = df[df['x'].between(xline-xgap/2,xline+xgap/2)]
    df_all_xline = df_xline[df_xline.y <= y_diffusionLayer] #No filter the phipf variables (two phases are included)
    #The data for xline has 2 set of data, with the same x values, thus, take average:
    df_all_xline=df_all_xline.sort_values(by='y').reset_index(drop=True)
    #print(df_all_xline)
    #df_all_xline_mean = df_all_xline.groupby(df_all_xline.index // 2).mean()
    #print(df_all_xline_mean)
    if plot:
        plt.plot(df_all_xline_mean.y,df_all_xline_mean.cMe,'r.')
        plt.plot(df_all_xline.y, df_all_xline.cMe, '.')
        plt.show()
    return df_all_xline #This value is already sorted in ascending order of y column
    #return df_all_xline_mean #This value is already sorted in ascending order of y column

def get_values_pits_horline(df,yline,ygap=1e-7,plot=False):
    #Select the data along the horizontal line y=yline
    df_yline = df[df['y'].between(yline-ygap/2,yline+ygap/2)]
    #Filter out the pseudo-phase domain:
    df_liq_yline=df_yline[df_yline.phipf >= 0].reset_index(drop=True).sort_values(by='x')
    #The data for yline has 2 set of data, with the same x values, thus, take average:
    df_liq_yline_mean = df_liq_yline.groupby(df_liq_yline.index // 2).mean()
    if plot:
        plt.plot(df_liq_yline.x,df_liq_yline.cMe,'.')
        plt.plot(df_liq_yline_mean.x,df_liq_yline_mean.cMe,'r.')
        plt.show()
    return df_liq_yline_mean

def get_values_pits_horline2(df,yline,xmin,xmax,ygap=1e-7,plot=False):
    #Select the data along the horizontal line y=yline
    df_yline = df[df['y'].between(yline-ygap/2,yline+ygap/2)]
    df_yline2 = df_yline[df_yline['x'].between(xmin,xmax)]
    df_all_yline=df_yline2.sort_values(by='x').reset_index(drop=True)
    #Filter out the pseudo-phase domain:
    #df_liq_yline=df_yline[df_yline.phipf >= 0].reset_index(drop=True).sort_values(by='x')
    #The data for yline has 2 set of data, with the same x values, thus, take average:
    #df_liq_yline_mean = df_liq_yline.groupby(df_liq_yline.index // 2).mean()
    #if plot:
    #    plt.plot(df_liq_yline.x,df_liq_yline.cMe,'.')
    #    plt.plot(df_liq_yline_mean.x,df_liq_yline_mean.cMe,'r.')
    #    plt.show()
    return df_all_yline



def get_data_along_pit_surface(oFolder, vars,
                               mesh = np.arange(-5e-5, 5e-5, 0.05e-5),
                               export_file ='../processed_data/data_along_pit_surface.csv',
                               phipf_threshold = 0,
                               xgap_val = 0.25e-6,
                               progress_update = False):

    df_surf_all = pd.DataFrame(columns=vars)
    print('new')

    # Make ymesh
     
    ymesh = np.arange(-4.99e-5, 0, 0.2e-6) # test
    fList = os.listdir(oFolder)

    for file1 in fList:
        file = oFolder + '/' + file1
        # Important: df need to be sorted (Ascending as default: bottom to top of the pit)
        df = read_data_file(file, vars).sort_values(by=['y'])
        t = get_time_from_filename(file1)
        for line in mesh: #Get data long vertical line x = xline in the given mesh resolution
            df_line = get_values_pits_verline(df,xline=line,plot=False,xgap=xgap_val).reset_index(drop=True)
            phipf=df_line['phipf']
            for i,val in enumerate(phipf):
                try:
                    prod_phipf = phipf[i]*phipf[i+1]

                    #if ( (df_line['x'][i] < 8.8e-6) and (df_line['x'][i] > 8.6e-6) and (df_line['y'][i] > -9e-7) and (df_line['y'][i] < -1e-7) ):
                    #    print(df_line.iloc[i,:])

                    #print(i,prod_phipf)
                    if prod_phipf <= 0: #Select the values at the interface
                        df_surf_all = df_surf_all.append(df_line.iloc[i,:])
                        df_surf_all = df_surf_all.append(df_line.iloc[i+1, :])
                        x=df_line.x[i]
                        y=df_line.y[i]
                        #if ( (df_line['x'][i] < 8.8e-6) and (df_line['x'][i] > 8.6e-6) and (df_line['y'][i] > -9e-7) and (df_line['y'][i] < -1e-7) ):
                        #    print(df_line.iloc[i,:])
                except KeyError:
                    #print('Current at:',i,val)
                    pass
                continue
            df_surf_all = df_surf_all[df_surf_all['phipf']>= phipf_threshold]

            ### New horline ###

        for line in ymesh:
            df_line = get_values_pits_horline2(df,yline=line,xmin=min(mesh),xmax=max(mesh),plot=False,ygap=xgap_val).reset_index(drop=True)
            phipf=df_line['phipf']
            for i,val in enumerate(phipf):
                try:
                    prod_phipf = phipf[i]*phipf[i+1]

                    #if ( (df_line['x'][i] < 8.8e-6) and (df_line['x'][i] > 8.6e-6) and (df_line['y'][i] > -9e-7) and (df_line['y'][i] < -1e-7) ):
                    #    print(df_line.iloc[i,:])

                    #print(i,prod_phipf)
                    if prod_phipf <= 0: #Select the values at the interface
                        if ((df_line['x'][i] not in df_surf_all['x']) and (df_line['y'][i] not in df_surf_all['y'])):
                            df_surf_all = df_surf_all.append(df_line.iloc[i,:])
                            df_surf_all = df_surf_all.append(df_line.iloc[i+1, :])
                            x=df_line.x[i]
                            y=df_line.y[i]
                        #if ( (df_line['x'][i] < 8.8e-6) and (df_line['x'][i] > 8.6e-6) and (df_line['y'][i] > -9e-7) and (df_line['y'][i] < -1e-7) ):
                        #    print(df_line.iloc[i,:])
                except KeyError:
                    #print('Current at:',i,val)
                    pass
                continue
            df_surf_all = df_surf_all[df_surf_all['phipf']>= phipf_threshold]


        if progress_update:
            print('Finish processing file:', file, 'time:', t)

    #Export to csv datafile:
    df_surf_all.to_csv(export_file)
    #return df_surf_all



def time_to_data_filename(t,file_type='.txt'):
    "Create datafile name based on the given time"
    t_split = str(round(t,2)).split('.')
    name = 'data_'+ t_split[0]+'p'+t_split[1]+'s'+file_type
    if t == 0:
        name = 'data_'+ t_split[0]+'s'+file_type
    return name

def data_all_split_file(filename,outFolderPath,vars):
    ''' Split the orgiinal dataset exported from Comsol at different time step
    to smaller dataset based on the each simulating time and export to txt datafile'''

    #df = pd.read_csv(filename, sep="\t", header=None)
    try:
        df = pd.read_csv(filename, sep="\t", header=None)
    except:
        print('Failed to read csv ',filename)
    nvars = len(vars) - 2  # the first 2 rows are x, y
    i = 2
    while True:
        idx_list = np.append([0, 1], np.arange(i, i + nvars))
        #print(nvars, idx_list)
        # print(i,idx_list)
        df_sub = df.iloc[:, idx_list]
        t = df_sub.iloc[0, -1]
        filename = time_to_data_filename(t)
        filePath = outFolderPath + '/' + filename
        df_sub.to_csv(filePath, header=False, index=False, sep='\t')
        #df_sub.to_csv(filename, header=False, index=False, sep='\t')
        #print('Export to file ' + filename + ': Done')
        i = i + nvars
        if i >= len(df.columns):
            break



'''
#####################################################################################
#####################################################################################
#####################################################################################
Parallel section starts
#####################################################################################
#####################################################################################
#####################################################################################

'''


def get_data_along_pit_surface_parallel(pid, outDir, vars, mesh, phipf_threshold, xgap_val, exportPrefix, numProcs):

    # pid - process id
    # outDir - directory where .txt files for each time are located
    # vars - variable list (columns of dataframe)
    # mesh - X mesh, y mesh is hardcoded
    # phipf_threshold - minimum value of phipf to select
    # xgap_val - gap between x values, not very important
    # exportPrefix - Prefix for each process generated output csv file
    # numProcs - number of processes (workers)
    
    start_time = time.time()
    df_surf_all = pd.DataFrame(columns=vars)

    fList = os.listdir(outDir) # List of all time .txt files
    numFiles = len(fList)
    
    fStart = int(pid*numFiles/numProcs) # Index of first time file
    fEnd = int((pid+1)*numFiles/numProcs) # Index of last time file
    
    print('pid: fStart: fEnd: ', pid, fStart, fEnd)
    print('new')

    # Make ymesh
     
    ymesh = np.arange(-4.99e-5, 0, 0.2e-6) # test

    for fid in range(fStart, fEnd):
        inFile = fList[fid]
        file = outDir + '/' + inFile 
        #file = oFolder + '/' + file1
        # Important: df need to be sorted (Ascending as default: bottom to top of the pit)
        try:
            df = read_data_file(file, vars).sort_values(by=['y'])
        except:
            print('Failed to read file in unorg ',outDir)
            print('Time file is ', file)
            print('list of files is ', fList)
        try:
            t = get_time_from_filename(inFile)
        except:
            print('Failed to get time in unorg ',outDir)
            print('Time file is ', file)
        for line in mesh: #Get data long vertical line x = xline in the given mesh resolution
            df_line = get_values_pits_verline(df,xline=line,plot=False,xgap=xgap_val).reset_index(drop=True)
            phipf=df_line['phipf']
            for i,val in enumerate(phipf):
                try:
                    prod_phipf = phipf[i]*phipf[i+1]

                    #if ( (df_line['x'][i] < 8.8e-6) and (df_line['x'][i] > 8.6e-6) and (df_line['y'][i] > -9e-7) and (df_line['y'][i] < -1e-7) ):
                    #    print(df_line.iloc[i,:])

                    #print(i,prod_phipf)
                    if prod_phipf <= 0: #Select the values at the interface
                        df_surf_all = df_surf_all.append(df_line.iloc[i,:])
                        df_surf_all = df_surf_all.append(df_line.iloc[i+1, :])
                        x=df_line.x[i]
                        y=df_line.y[i]
                        #if ( (df_line['x'][i] < 8.8e-6) and (df_line['x'][i] > 8.6e-6) and (df_line['y'][i] > -9e-7) and (df_line['y'][i] < -1e-7) ):
                        #    print(df_line.iloc[i,:])
                except KeyError:
                    #print('Current at:',i,val)
                    pass
                continue
            df_surf_all = df_surf_all[df_surf_all['phipf']>= phipf_threshold]

            ### New horline ###

        for line in ymesh:
            df_line = get_values_pits_horline2(df,yline=line,xmin=min(mesh),xmax=max(mesh),plot=False,ygap=xgap_val).reset_index(drop=True)
            phipf=df_line['phipf']
            for i,val in enumerate(phipf):
                try:
                    prod_phipf = phipf[i]*phipf[i+1]

                    #if ( (df_line['x'][i] < 8.8e-6) and (df_line['x'][i] > 8.6e-6) and (df_line['y'][i] > -9e-7) and (df_line['y'][i] < -1e-7) ):
                    #    print(df_line.iloc[i,:])

                    #print(i,prod_phipf)
                    if prod_phipf <= 0: #Select the values at the interface
                        if ((df_line['x'][i] not in df_surf_all['x']) and (df_line['y'][i] not in df_surf_all['y'])):
                            df_surf_all = df_surf_all.append(df_line.iloc[i,:])
                            df_surf_all = df_surf_all.append(df_line.iloc[i+1, :])
                            x=df_line.x[i]
                            y=df_line.y[i]
                        #if ( (df_line['x'][i] < 8.8e-6) and (df_line['x'][i] > 8.6e-6) and (df_line['y'][i] > -9e-7) and (df_line['y'][i] < -1e-7) ):
                        #    print(df_line.iloc[i,:])
                except KeyError:
                    #print('Current at:',i,val)
                    pass
                continue
            df_surf_all = df_surf_all[df_surf_all['phipf']>= phipf_threshold]

    #Export to csv datafile:
    outPath = str(outDir) + '/' + str(exportPrefix) + '_' + str(pid) + '.csv'
    df_surf_all.to_csv(outPath)
    end_time = time.time()
    print ("Process unorg data parallel "+ str(pid) +" : " + str(round(end_time-start_time)) + " seconds")
    return pid
    #return df_surf_all


# This function reads in output of  get_data_along_suface_parallel. The pid'th
# process for this function reads the output of the pid'th earlier process
# Each file has a few times. The unique time list is determined and for each time,
# the output is the nearest neighbour data along the surface.

def get_nn_surface_proc(pid, outDir, vars, inputPrefix, outputPrefix, ftype = '.csv'):
    
    start_time = time.time()
    
    fName = outDir + '/' + inputPrefix + '_' + str(pid) + ftype

    # df reads the output data file of the pid'th process that was generated from get_data_along_suface_parallel
    # This file has a few times of surface data
    #df = read_data_file(fName, vars).sort_values(by=['y'])
    df = pd.read_csv(fName,index_col=0) 
    
    # Get 
    tList = df['t'].unique()
    dfOut = pd.DataFrame(columns = vars)

    ## Re-arrange data to to show order along the pit surface
    for t in tList:
        df_t = df[df['t']==t] # original

            ### Test ####################
        '''vars_list= ['x', 'y', 'cMe', 'phil', 'phipf','phis','I','iloc','t']
        inFile = 'data_0s.txt'
        df_actual = pd.read_csv(inFile, sep="\t", header=None)
        df_actual.columns = vars_list

        df_xline = df[df['x'].between(-7e-5,7e-5)]
        df_t = df_xline[df_xline.y <= 0.0] #No filter the phipf variables (two phases are included)
        '''
        ##############################
        df_t.index = np.arange(1,len(df_t)+1)
        df_t['cord'] = list(zip(df_t.x, df_t.y))
        df_t_sub = df_t.iloc[:,[0,1,-1]].sort_values(by=['y','x'],ascending=False)
        # testing
        #print(df_t.iloc[0,[0,1,2,-1]])
        print(df_t_sub.loc[1])

        n = df_t.shape[0]
        l_dict = {}

        for i in np.arange(1,n+1):
            for j in np.arange(i+1,n+1):
                x1,y1,_ = df_t_sub.loc[i]
                x2,y2,_ = df_t_sub.loc[j]
                l = np.sqrt((x2-x1)**2+(y2-y1)**2)
                l_dict[(i,j)]=[l,0]
                l_dict[(j, i)] = [l, 0]
            l_dict[(i, i)] = [0,1]

        ### Find the nearest neighbors for each points, given the start points coordinate of the path:
        start_point_cord =df_t_sub.iloc[0,-1]
        start_point_idx = df_t_sub.index[df_t_sub['cord']==start_point_cord].to_list()[0]
        print('Start point (idx,x,y):',start_point_idx,start_point_cord)

        point_list_idx = np.arange(1,n+1)
        next_point_idx = 0
        previous_point_idx = 0
        l_total = 0
        j=0
        is_seen = 0
        point_seen =[]
        l_total_list =[]
        while True:
            l_min = 10
            # Start point is fixed for the entire duration of the for loop. Suppose start point idx is 238. In the loop, the distance from this
            # point to every other point in the list is checked. At each target point with index i, the distance of the pair l_dist(i,238) is checked.
            # If an i is found such that the distance l_min so far is smaller than the prvious value, then this i point is assigned as next point. The loop repeats like this
            # until all the other points are checked. Finally, start point is assigned to previous point, and the next point label becomes the new start point and the loop
            # repeats again from i = 1. 
            for i in point_list_idx:
                if i not in point_seen:
                    cord = (i,start_point_idx)
                    reverse_cord = (start_point_idx,i)
                    l =l_dict[cord][0]
                    is_seen = l_dict[cord][1]
                    #print(cord,l_dict[cord])

                    if (is_seen==0) & (l_min>l):
                        l_min = l
                        next_point_idx=i
                        l_dict[cord][1] = 1
                        l_dict[reverse_cord][1] = 1

            previous_point_idx = start_point_idx
            point_seen.append(previous_point_idx)
            start_point_idx = next_point_idx

            l_total+=l_min
            l_total_list.append(l_total)

            #print('previous point',previous_point_idx,',start point',start_point_idx,',min distance:',round(l_min,8),',total length',round(l_total,8))
            j+=1
            #if j==n-1: #j==n-1:
            if j==n: #j==n-1:
               break

        #check points seen, l total list, and dimension:
        u, c = np.unique(point_seen, return_counts=True)
        print('Duplicate:',u[c>1])

        df_t_reindex = df_t.reindex(point_seen)
        df_t_reindex['l_accum']=l_total_list

        dfOut = pd.concat([dfOut,df_t_reindex],axis=0)

       
    outFile = outDir + '/' + outputPrefix + '_' + str(pid) + ftype
    dfOut.to_csv(outFile)
    end_time = time.time()
    print ("Process nn parallel "+ str(pid) +" : " + str(round(end_time-start_time)) + " seconds")
    return pid



    ''' Useful info, might be used later

        print('#point seen:',len(point_seen), 'len l_total_list:',len(l_total_list))
        print('#rows in df_t:',n)
        print('Shape of df_t_reindex:',df_t_reindex.shape)
        print('Total perimeters (microns)',l_total)
    '''

# This function calculates pit depth and widths as a function of time

def get_depth_width(outDir, outFolder, nnFileName, outFileName, dpit, minDist = 5e-7):
    nnFilePath = outDir + '/' + nnFileName
    df = pd.read_csv(nnFilePath,index_col=0) 
    tList = df['t'].unique()
    tList.sort()
    #print('sorted tList is ', tList)
    numTimes = len(tList)

    # Contains only max depth, width and potential at pit bottom vs time data
    #outData = np.zeros((numTimes,4))
    outData = np.zeros((numTimes,6))

    count = 0

    for t in tList:
        df_t = df[df['t']==t] # original
        df_t = df_t.reset_index(drop=True)

        numPoints = df_t.shape[0]
        #print('numPoints is ' + str(numPoints))
        #print(df_t)
        # At time=0, get pit bottom coordinates of both left and right pits
        if ( t == 0):
            x = outFolder.split('_')
            if (dpit): # If a dpit value is given, it is for 2 pits, else single pit
                leftRadius = float(x[2][0])*10**(-1*float(x[2][-1]))
                rightRadius = float(x[5][0])*10**(-1*float(x[5][-1]))
                leftAngle = float(x[8])
                rightAngle = float(x[11])
                # determine iApply
                i1 = x[14]
                i2 = i1.split('E')
                iApply = float(i2[0])*10**(float(i2[-1]))
                print('i is ',iApply)
            else:
                radius = float(x[1][0])*10**(-1*float(x[1][-1]))
                angle = float(x[3])
                # determine iApply
                i1 = x[6]
                i2 = i1.split('E')
                iApply = float(i2[0])*10**(float(i2[-1]))
                print('i is ',iApply)


            if (iApply == 1e-4):
                widthEps = 4e-6
            else:
                widthEps = 1e-6

            if (dpit):
                # Right pit bottom coordinates
                #rightBot = [0.5*dpit + rightRadius, -1*(rightRadius*(1 + np.cos(rightAngle)))]
                # Left pit bottom coordinates
                #leftBot =  [-0.5*dpit - leftRadius, -1*(leftRadius*(1 + np.cos(leftAngle)))]
                # Initial left pit depth
                #leftDepth_0 = leftBot[1]
                # Initial right pit depth
                #rightDepth_0 = rightBot[1]
                # Max right point
                xtremeRight_0 = 0.5*dpit + 2*rightRadius
                # Min left point
                xtremeLeft_0 = -0.5*dpit - 2*leftRadius
                # Allocate these x-extremes to previously seen initial max points
                prevXtremeRight = xtremeRight_0
                prevXtremeLeft = xtremeLeft_0
            else:
                # Pit bottom coordinates
                #rightBot = [0.5*dpit + radius, -1*(radius*(1 + np.cos(angle)))]
                # Max right point
                xtremeRight_0 = radius
                # Min left point
                xtremeLeft_0 = -radius
                # Allocate these x-extremes to previously seen initial max points
                prevXtremeRight = xtremeRight_0
                prevXtremeLeft = xtremeLeft_0
            
            #yThreshRight = -(0.75*rightRadius*np.cos(rightAngle))
            #yThreshLeft = -(0.75*leftRadius*np.cos(leftAngle))
            #yThresh = max(yThreshLeft,yThreshRight)
        
        depthList = []
        indexList = []

        x1 = df_t['x'][0]
        x2 = df_t['x'][1]
        y1 = df_t['y'][0]
        y2 = df_t['y'][1]

        if (y2 < y1): # decreasing
            trend = -1
        elif (y2 > y1): # increasing
            trend = 1
        else:
            trend = 0
        prevTrend = trend
        for i in range(numPoints - 1):
            # Initial two points
            x1 = df_t['x'][i]
            x2 = df_t['x'][i+1]
            y1 = df_t['y'][i]
            y2 = df_t['y'][i+1]

            dist1 = np.sqrt( (x2 - x1)**2 + (y2 - y1)**2 )

            if (dist1 <= minDist):
                if (y2 < y1): # decreasing
                    prevTrend = trend
                    trend = -1
                elif (y2 > y1): # increasing
                    prevTrend = trend
                    trend = 1
                else: # increasing
                    continue
            
                #if ( ( prevDecr == 0 )) and (decr == -1) ):
                if ((prevTrend != 0) and (prevTrend != trend )):
                    if (trend == 1):
                        depthList.append(y1)
                        indexList.append(i)
        outData[count,0] = t
        pitDepth = min(depthList)
        outData[count,1] = pitDepth # Max pit depth
        #outData[count,2] = np.abs(max(df_t['x']) - min(df_t['x'])) # Pit width 

        # A bit more intelligence to calculate max pit width. It turns out that sometimes, an extreme
        # x value can creep into the df. This has to be successively removed
        #idx = df_t.index[df_t['y'] < yThresh]
        #x = df_t['x'].loc[idx]
        x1 = df_t['x']
        xValsMax = x1.to_list()
        xValsMin = x1.to_list()

        # Find maximum value of x
        for i in range(len(xValsMax)):
            xMax = max(xValsMax)
            if ( np.abs(xMax - prevXtremeRight) > widthEps):
                xValsMax.remove(xMax)
            else:
                prevXtremeRight = xMax
                break
        # Find minimum value of x
        for i in range(len(xValsMin)):
            xMin = min(xValsMin)
            if ( np.abs(xMin - prevXtremeLeft) > widthEps):
                xValsMin.remove(xMin)
            else:
                prevXtremeLeft = xMin
                break


        outData[count,2] = np.abs(xMax - xMin) # Pit width 
        outData[count,4] = xMax
        outData[count,5] = xMin

        #for i in range(len(xVals)):
        #    maxX = max(xVals)
        #    if (maxX - prevXtremeRight)



        # Potential is taken at the pit bottom. The potential corresponding to this point is the phis value
        # at the same index in indexList
        phisIndex = indexList[depthList.index(pitDepth)]
        outData[count,3] = df_t['phis'][phisIndex]
        count = count + 1

        
        #print('Time ' + str(t) + ' depths are ' )
        #print(depthList)
        #print('Number of depths ',len(depthList))
    #print('Number of times ', len(tList))
    #print('Initial left depth ', leftDepth_0)
    #print('Initial right depth ', rightDepth_0)
    dfOut = pd.DataFrame(outData)
    dfOut.columns = ['t','max depth','max width','phis','xMax','xMin']

    outFilePath = outDir + '/' + outFileName
    dfOut.to_csv(outFilePath)




    



'''
#####################################################################################
#####################################################################################
#####################################################################################
Parallel section ends
#####################################################################################
#####################################################################################
#####################################################################################

'''



