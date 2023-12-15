% % %  Matlab script example using Comsol Multiphysics Livelink for Matlab

%% Load comsol file: 
filename = '2D_multi_pits';
model = mphopen(filename);
model.mphlaunch; %Open comsol desktop file
ModelUtil.showProgress(true) %Show progress of the solving

%% Parameter sweep in tranisent study:
var_name = 'theta';
var_value = 30;
var_unit = '[ degree]'
t_range = 'range(0,0.01,0.5)'
filename = [filename,'_',var_name,'=',num2str(var_value)];
filepath = 'C:\Users\vanan\OneDrive\Desktop\Pit Propagation Model\Single Pit Growth'
study_name = 'std3'

% Set parameters for the model:
model.param.set(var_name,[num2str(var_value),var_unit]); 
% Set time and run the transient model
std = model.study(study_name).feature("time")
std.set('tlist', t_range)

% Plot while solving:
std.set('plot','on')
std.set('plotgroup', 'pg32')

% Run the mode:
try
    model.study(study_name).run;        
    error_mess=[];
catch
    disp('error while running, check error message')
    error_mess = mphshowerrors(model)%Show error message:
end

%% Save the data and the running model:
filename_new = [filename,'_',var_name,'=',num2str(var_value)];
modelName = fullfile(filepath,[filename_new,'.mph']);
mphsave(model,modelName); 

% % if length(mphtags) ~=0
% %     ModelUtil.remove('Model')
% % end