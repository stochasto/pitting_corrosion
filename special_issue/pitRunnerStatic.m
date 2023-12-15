% Function to run pit propagation for different expTypes, i.e.
% potentiostatic case. A range of pFails are obtained for
% different applied potentials. 
% Inputs: eMin -> Minimum potential, eMax -> Max potential

function pFail = pitRunnerStatic(eMin,eMax,nStep)

E = eMin:(eMax - eMin)/nStep:eMax;

s = max(size(E));

pFail = zeros(s,1);

for i = 1:1:s
    pFail(i) = Pit_Propagation(E(i));
end

plot(E,pFail)