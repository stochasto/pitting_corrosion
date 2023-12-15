% Function to run pit propagation for different expTypes, i.e.
% potentiostatic case. A range of pFails are obtained for
% different applied potentials. 
% Inputs: eMin -> Minimum potential, eMax -> Max potential, scanRate ->
% rate of potential increase

function Ebpar = pitRunnerDynamic(eMin,scanRate,tMin,tMax,nStep,nSamples)

E = zeros(nStep,2);
E(:,1) = tMin:(tMax - tMin)/(nStep - 1):tMax;
E(1,2) = eMin;

isFail = zeros(nSamples,1);
Eb = zeros(nSamples,1);

for i = 2:1:nStep
    E(i,2) = E(i-1,2) + (E(i,1) - E(i-1,1))*scanRate;
end

%%% Parallel
numThreads = 8;
delete(gcp('nocreate'));
parpool(numThreads);

samplesPerThread = floor((nSamples + numThreads - 1)/numThreads)

Ebpar = zeros(samplesPerThread,numThreads);

% for i = 1:1:numThreads
%     for j = 1:1:voltPerThread
%         currVolt = (i-1)*voltPerThread + j;
%         if (currVolt <= nVoltage)
%             Epar(j,i) = E(currVolt);
%         end
%     end
% end

%%%%%%%%%%%%%

tic
parfor i = 1:1:numThreads
    Ebpar2 = zeros(samplesPerThread,1);
    for j = 1:1:samplesPerThread
        [isFail, Ebpar2(j)] = Pit_Propagation2(E,nStep,tMax);
    end
    Ebpar(:,i) = Ebpar2;
end
toc

plot(E(:,1),E(:,2))
figure
hist(Ebpar(:),sqrt(max(size(Ebpar))))

%%% Write output to excel

outFile = strcat('Ebpar_scanRate_',num2str(scanRate),'.xlsx');
writematrix(Ebpar(~isnan(Ebpar(:))),outFile)

%size(~isnan(Eb))
%pFail = Pit_Propagation(E);