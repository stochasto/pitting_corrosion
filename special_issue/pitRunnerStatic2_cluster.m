% Function to run pit propagation for different expTypes, i.e.
% potentiostatic case. A range of pFails are obtained for
% different applied potentials. 
% Inputs: eMin -> Minimum potential, eMax -> Max potential

function pFail = pitRunnerStatic2_cluster(eMin,eMax,nStep,nSamples)
%% Setup E 
E = eMin:(eMax - eMin)/nStep:eMax;

nVoltage = max(size(E))

pFail = zeros(nVoltage,1);
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

%% Parallel setup
voltPerThread = floor((nVoltage + numThreads - 1)/numThreads)

Epar = zeros(voltPerThread,numThreads);
pFailPar = zeros(voltPerThread,numThreads);

% 2D array of input voltages for parallelization
for i = 1:1:numThreads
    for j = 1:1:voltPerThread
        currVolt = (i-1)*voltPerThread + j;
        if (currVolt <= nVoltage)
            Epar(j,i) = E(currVolt);
        end
    end
end

%% Parallel loop
tic
parfor i = 1:1:numThreads
    pFail2 = zeros(voltPerThread,1);
    Epar2 = Epar(:,i);
    for k = 1:1:voltPerThread
        currVolt = (i-1)*voltPerThread + k;
        if (currVolt <= nVoltage)
            isFail = zeros(nSamples,1);
            Eb = zeros(nSamples,1);
            for j = 1:1:nSamples
                [isFail(j), Eb(j)] = Pit_Propagation2(Epar2(k),501,5000);
            end
            if (sum(isFail > 0))
                pFail2(k) = max(size(find(isFail)))/nSamples;
            end
        end
    end
    pFailPar(:,i) = pFail2;
end
toc

%% Put 2D output of pFails into a 1D array
for i = 1:1:numThreads
    for j = 1:1:voltPerThread
        currVolt = (i-1)*voltPerThread + j; 
        if (currVolt <= nVoltage)
            pFail(currVolt) = pFailPar(j,i);
        end
    end
end

%% Write output to excel

outMatrix = zeros(nVoltage,2);
outMatrix(:,1) = E(1:nVoltage);
outMatrix(:,2) = pFail(1:nVoltage);

outFile = strcat('pFail_static_nSamples_',num2str(nSamples),'.xlsx');
writematrix(outMatrix,outFile)
%plot(E',pFail)