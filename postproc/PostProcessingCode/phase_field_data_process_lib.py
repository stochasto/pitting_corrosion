import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

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


def get_data_along_pit_surface(file_list, vars,
                               mesh = np.arange(-5e-5, 5e-5, 0.05e-5),
                               export_file ='../processed_data/data_along_pit_surface.csv',
                               phipf_threshold = 0,
                               xgap_val = 0.25e-6,
                               progress_update = False):

    df_surf_all = pd.DataFrame(columns=vars)
    print('new')

    # Make ymesh
     
    ymesh = np.arange(-4.99e-5, 0, 0.2e-6) # test

    for file in file_list:
        # Important: df need to be sorted (Ascending as default: bottom to top of the pit)
        df = read_data_file(file, vars).sort_values(by=['y'])
        t = get_time_from_filename(file)
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
    return df_surf_all



def time_to_data_filename(t,file_type='.txt'):
    "Create datafile name based on the given time"
    t_split = str(round(t,2)).split('.')
    name = 'data_'+ t_split[0]+'p'+t_split[1]+'s'+file_type
    if t == 0:
        name = 'data_'+ t_split[0]+'s'+file_type
    return name

def data_all_split_file(filename,vars):
    ''' Split the orgiinal dataset exported from Comsol at different time step
    to smaller dataset based on the each simulating time and export to txt datafile'''

    df = pd.read_csv(filename, sep="\t", header=None)
    nvars = len(vars) - 2  # the first 2 rows are x, y
    i = 2
    while True:
        idx_list = np.append([0, 1], np.arange(i, i + nvars))
        #print(nvars, idx_list)
        # print(i,idx_list)
        df_sub = df.iloc[:, idx_list]
        t = df_sub.iloc[0, -1]
        filename = time_to_data_filename(t)
        df_sub.to_csv(filename, header=False, index=False, sep='\t')
        print('Export to file ' + filename + ': Done')
        i = i + nvars
        if i >= len(df.columns):
            break






