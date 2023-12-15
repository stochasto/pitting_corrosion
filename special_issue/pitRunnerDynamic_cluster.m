% Function to run pit propagation for different expTypes, i.e.
% potentiostatic case. A range of pFails are obtained for
% different applied potentials. 
% Inputs: eMin -> Minimum potential, eMax -> Max potential, scanRate ->
% rate of potential increase

function Ebpar = pitRunnerDynamic_cluster(eMin,scanRate,tMin,tMax,nStep,nSamples)

%% Setup E vector
E = zeros(nStep,2);
E(:,1) = tMin:(tMax - tMin)/(nStep - 1):tMax;
E(1,2) = eMin;

isFail = 0;

for i = 2:1:nStep
    E(i,2) = E(i-1,2) + (E(i,1) - E(i-1,1))*scanRate;
end
%% Cluster %%
% numThreads = 8;
% delete(gcp('nocreate'));
% parpool(numThreads);

numThreads = 32;
delete(gcp('nocreate'));
cl = parcluster(); %create a cluster object
job_id = getenv('LSB_JOBID'); %get the unique job ID
storage_folder = strcat('/glb/home/invmfj/.matlab/local_cluster_jobs/R2019a/', job_id);
mkdir(storage_folder); %make a temporary folder for this session
cl.JobStorageLocation = storage_folder; %and tell the cluster to use it
parpool(cl,numThreads); %create the parallel pool for this cluster

%%
samplesPerThread = floor((nSamples + numThreads - 1)/numThreads)
Ebpar = zeros(samplesPerThread,numThreads);

tic
parfor i = 1:1:numThreads
    Ebpar2 = zeros(samplesPerThread,1);
    for j = 1:1:samplesPerThread
        [isFail, Ebpar2(j)] = Pit_Propagation2(E,nStep,tMax);
    end
    Ebpar(:,i) = Ebpar2;
end
toc

%plot(E(:,1),E(:,2))
%figure
%hist(Ebpar(:))

%% Write output to excel

outFile = strcat('Ebpar_scanRate_',num2str(scanRate),'.xlsx');
writematrix(Ebpar(~isnan(Ebpar(:))),outFile)

