function run_galvano_par(numSamples, numThreads, iApply, tMax, outPath, savePref)

saveTimes = [10 50 100 500 1000];
nSaves = max(size(saveTimes));

%% Cluster %%
% numThreads = 8;
% delete(gcp('nocreate'));
% parpool(numThreads);

%numThreads = 128;
delete(gcp('nocreate'));
parpool(numThreads);

% parcluster
%c1 = parcluster(); %create a cluster object
%c1.NumWorkers = numThreads;
%parpool(c1,numThreads);
% job_id = getenv('LSB_JOBID'); %get the unique job ID
% storage_folder = strcat('/glb/home/invmfj/.matlab/local_cluster_jobs/R2021a/', job_id);
% mkdir(storage_folder); %make a temporary folder for this session
% cl.JobStorageLocation = storage_folder; %and tell the cluster to use it
% parpool(cl,numThreads); %create the parallel pool for this cluster

%% Data structures

samplesPerThread = floor((numSamples + numThreads - 1)/numThreads);

% finData.sInits = zeros(samplesPerThread,numThreads,nSaves);
% finData.sGrowth = zeros(samplesPerThread,numThreads,nSaves);
% finData.sMergers = zeros(samplesPerThread,numThreads,nSaves);
% finData.sRepassive = zeros(samplesPerThread,numThreads,nSaves);
% finData.sConsumed = zeros(samplesPerThread,numThreads,nSaves);
% finData.sMaxDepth = zeros(samplesPerThread,numThreads,nSaves);
% finData.sMaxWidth = zeros(samplesPerThread,numThreads,nSaves);

finData.sInits = zeros(samplesPerThread*nSaves,numThreads);
finData.sGrowth = zeros(samplesPerThread*nSaves,numThreads);
finData.sMergers = zeros(samplesPerThread*nSaves,numThreads);
finData.sRepassive = zeros(samplesPerThread*nSaves,numThreads);
finData.sConsumed = zeros(samplesPerThread*nSaves,numThreads);
finData.sMaxDepth = zeros(samplesPerThread*nSaves,numThreads);
finData.sMaxWidth = zeros(samplesPerThread*nSaves,numThreads);

sInits = zeros(samplesPerThread*nSaves,numThreads);
sGrowth = zeros(samplesPerThread*nSaves,numThreads);
sMergers = zeros(samplesPerThread*nSaves,numThreads);
sRepassive = zeros(samplesPerThread*nSaves,numThreads);
sConsumed = zeros(samplesPerThread*nSaves,numThreads);
sFailed = zeros(samplesPerThread*nSaves,numThreads);
sMaxDepth = zeros(samplesPerThread*nSaves,numThreads);
sMaxWidth = zeros(samplesPerThread*nSaves,numThreads);

repassTimes = cell(1,numThreads); % cell holding repass times

%% Parallel loop



parfor i = 1:numThreads
    tempInits = zeros(samplesPerThread*nSaves,1);
    tempGrowth = zeros(samplesPerThread*nSaves,1);
    tempMergers = zeros(samplesPerThread*nSaves,1);
    tempRepassive = zeros(samplesPerThread*nSaves,1);
    tempConsumed = zeros(samplesPerThread*nSaves,1);
    tempFailed = zeros(samplesPerThread*nSaves,1);
    tempDepth = zeros(samplesPerThread*nSaves,1);
    tempWidth = zeros(samplesPerThread*nSaves,1);

    rTimes = zeros(1,1);

    for j = 1:1:samplesPerThread
        [pc, dL, c] = Pit_Propagation_Galvano2(iApply,saveTimes,tMax);
        timer = pc{1}.time; % Array of timesteps (actual time)
        % pc, dL and c are cell arrays containing nSaves number of cells. pc has nSaves number of structs. pc{1} is for
        % the first save point and pc{nSaves} is for the last. Now, Each sub array in pc{1}, for example, has data for
        % each time point run upto that time, i.e. pc{1}.growth has data upto the first save point in saveTimes. pc{2}
        % has data upto the second time value in saveTimes. This index must be found out for the k'th measurement point.
        for k = 1:1:nSaves
            timeIndex = find(timer == saveTimes(k));
            tempInits((j-1)*nSaves + k) = pc{k}.inits(timeIndex);
            tempGrowth((j-1)*nSaves + k) = pc{k}.growth(timeIndex);
            tempMergers((j-1)*nSaves + k) = sum(pc{k}.mergers(1:timeIndex));
            tempFailed((j-1)*nSaves + k) = sum(pc{k}.failedInitiations(1:timeIndex));
            tempRepassive((j-1)*nSaves + k) = sum(pc{k}.repassive(1:timeIndex));
            tempConsumed((j-1)*nSaves + k) = sum(pc{k}.consumed(1:timeIndex));
            tempDepth((j-1)*nSaves + k) = dL{k}.maxDepth(timeIndex);
            tempWidth((j-1)*nSaves + k) = dL{k}.maxWidth(timeIndex);
%             finData.sInits(:,j,k) = pc.inits{k}(end);
%             finData.sGrowth(i) = pc.growth{k}(end);
%             finData.sMergers(i) = sum(pc.mergers);
%             finData.sRepassive(i) = sum(pc.repassive);
%             finData.sConsumed(i) = sum(pc.consumed);
%             finData.sMaxDepth(i) = dL.maxDepth(end);
%             finData.sMaxWidth(i) = dL.maxWidth(end);
        end
        rTimes = [rTimes; get_repass_times(c{nSaves})];
    end
    sInits(:,i) = tempInits;
    sGrowth(:,i) = tempGrowth;
    sMergers(:,i) = tempMergers;
    sRepassive(:,i) = tempRepassive;
    sConsumed(:,i) = tempConsumed;
    sFailed(:,i) = tempFailed;
    sMaxDepth(:,i) = tempDepth;
    sMaxWidth(:,i) = tempWidth;
    repassTimes{i} = rTimes;
end

save_data(sInits, sGrowth, sMergers, sRepassive, sConsumed, sFailed, sMaxDepth, sMaxWidth, repassTimes, outPath, savePref);
end

%% Save data
function save_data(sInits, sGrowth, sMergers, sRepassive, sConsumed, sFailed, sMaxDepth, sMaxWidth, repassTimes, outPath, savePref)

if (ispc)
    savePath = strcat(outPath,'\',savePref,'_allData.xlsx');
    savePathTime = strcat(outPath,'\',savePref,'_repass_times.csv');
elseif (isunix)
    savePath = strcat(outPath,'/',savePref,'_allData.xlsx');
    savePathTime = strcat(outPath,'/',savePref,'_repass_times.csv');
end

writematrix(sInits,savePath,'Sheet','nucleations');
writematrix(sGrowth,savePath,'Sheet','growths');
writematrix(sMergers,savePath,'Sheet','mergers');
writematrix(sRepassive,savePath,'Sheet','repassives');
writematrix(sConsumed,savePath,'Sheet','consumptions');
writematrix(sFailed,savePath,'Sheet','failed_inits');
writematrix(sMaxDepth,savePath,'Sheet','max_depth');
writematrix(sMaxWidth,savePath,'Sheet','max_width');

writecell(repassTimes,savePathTime);

end

%% Repassivation times
function [timeCell] = get_repass_times(c)

s = max(size(c));

timeCell = zeros(s,1);
ind = 0;

for i = 1:1:s
    if (((c{i,1} == -2 ) | (c{i,1} == -3)) & (c{i,11}))
        ind = ind+1;
        timeCell(ind) = c{i,11};
    end
end

timeCell = timeCell(1:ind);
end


% finData.initMean = mean(finData.sInits);
% finData.growthMean = mean(finData.sGrowth);
% finData.mergerMean = mean(finData.sMergers);
% finData.repassiveMean = mean(finData.sRepassive);
% finData.consumedMean = mean(finData.sConsumed);
% finData.depthMean = mean(finData.sMaxDepth);
% finData.widthMean = mean(finData.sMaxWidth);
% 
% finData.initStd = std(finData.sInits);
% finData.growthStd = std(finData.sGrowth);
% finData.mergerStd = std(finData.sMergers);
% finData.repassiveStd = std(finData.sRepassive);
% finData.consumedStd = std(finData.sConsumed);
% finData.depthStd = std(finData.sMaxDepth);
% finData.widthStd = std(finData.sMaxWidth);
    


