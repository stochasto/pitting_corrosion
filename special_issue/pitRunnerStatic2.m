% Function to run pit propagation for different expTypes, i.e.
% potentiostatic case. A range of pFails are obtained for
% different applied potentials. 
% Inputs: eMin -> Minimum potential, eMax -> Max potential

function pFail = pitRunnerStatic2(eMin,eMax,nStep,nSamples)

E = eMin:(eMax - eMin)/nStep:eMax;
size(E)

nVoltage = max(size(E))

pFail = zeros(nVoltage,1);

%%% Parallel
numThreads = 8;
delete(gcp('nocreate'));
parpool(numThreads);

voltPerThread = floor((nVoltage + numThreads - 1)/numThreads)

Epar = zeros(voltPerThread,numThreads);
pFailPar = zeros(voltPerThread,numThreads);

for i = 1:1:numThreads
    for j = 1:1:voltPerThread
        currVolt = (i-1)*voltPerThread + j;
        if (currVolt <= nVoltage)
            Epar(j,i) = E(currVolt);
        end
    end
end

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
                [isFail(j), Eb(j)] = Pit_Propagation2(Epar2(k),101,5000);
            end
            if (sum(isFail > 0))
                pFail2(k) = max(size(find(isFail)))/nSamples;
            end
        end
    end
    pFailPar(:,i) = pFail2;
end
toc

for i = 1:1:numThreads
    for j = 1:1:voltPerThread
        currVolt = (i-1)*voltPerThread + j; 
        if (currVolt <= nVoltage)
            pFail(currVolt) = pFailPar(j,i);
        end
    end
end

plot(E',pFail)