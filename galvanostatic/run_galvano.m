function finData = run_galvano(numSamples, iApply, tMax)

finData.sInits = zeros(numSamples,1);
finData.sGrowth = zeros(numSamples,1);
finData.sMergers = zeros(numSamples,1);
finData.sRepassive = zeros(numSamples,1);
finData.sConsumed = zeros(numSamples,1);
finData.sMaxDepth = zeros(numSamples,1);
finData.sMaxWidth = zeros(numSamples,1);

for i = 1:1:numSamples
    [pc, dL, c, r] = Pit_Propagation_Galvano(iApply,tMax);
    
    finData.sInits(i) = pc.inits(end);
    finData.sGrowth(i) = pc.growth(end);
    finData.sMergers(i) = sum(pc.mergers);
    finData.sRepassive(i) = sum(pc.repassive);
    finData.sConsumed(i) = sum(pc.consumed);
    finData.sMaxDepth(i) = dL.maxDepth(end);
    finData.sMaxWidth(i) = dL.maxWidth(end);
    
end

finData.initMean = mean(finData.sInits);
finData.growthMean = mean(finData.sGrowth);
finData.mergerMean = mean(finData.sMergers);
finData.repassiveMean = mean(finData.sRepassive);
finData.consumedMean = mean(finData.sConsumed);
finData.depthMean = mean(finData.sMaxDepth);
finData.widthMean = mean(finData.sMaxWidth);

finData.initStd = std(finData.sInits);
finData.growthStd = std(finData.sGrowth);
finData.mergerStd = std(finData.sMergers);
finData.repassiveStd = std(finData.sRepassive);
finData.consumedStd = std(finData.sConsumed);
finData.depthStd = std(finData.sMaxDepth);
finData.widthStd = std(finData.sMaxWidth);
    


