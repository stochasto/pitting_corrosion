function depthPlot = postprocess(pc,dL,c, savePref, savePath)

nTimes = max(size(pc.time));

%% Process dL, which is a structure. dL.depthList and dL.widthList have for each time, a cell array of list of depths 
% and widths of growing clusters. Loop is to check the size of these arrays one by one to make a final plot

numGrowing = 0;

for i = 1:1:nTimes
    numGrowing = numGrowing + max(size(dL.depthList{i}));
end

depthPlot.time = zeros(numGrowing,1);
depthPlot.depth = zeros(numGrowing,1);
depthPlot.width = zeros(numGrowing,1);

counter = 0;

for i = 1:1:nTimes
    numPits = max(size(dL.depthList{i}));
    if (numPits)
        depthPlot.time(counter + 1:counter+numPits) = dL.time(i);
        depthPlot.depth(counter+1:counter+numPits) = dL.depthList{i};
        depthPlot.width(counter+1:counter+numPits) = dL.widthList{i};
        counter = counter + numPits;
    end
end


%% Plotting

% Generate save file path
savePref1 = strcat(savePath,'\',savePref);

% Plot depth with time of all pits and max depth
scatter(depthPlot.time,depthPlot.depth,10)
hold on
plot(dL.time,dL.maxDepth,'LineWidth',1.5)
legend('Depth of pits','Max depth')
ax = gca;
ax.FontName = 'ShellMedium';
ax.FontSize = 12;
xlabel('Time (s)')
ylabel('Depth (m)')
depthFilePath = strcat(savePref1,'_depths');
saveas(gcf,depthFilePath,'fig')

% Plot width with time of all pits and max width
figure
scatter(depthPlot.time,depthPlot.width)
hold on
plot(dL.time,dL.maxWidth,'LineWidth',1.5)
legend('Width of pits','Max width')
ax = gca;
ax.FontName = 'ShellMedium';
ax.FontSize = 12;
xlabel('Time (s)')
ylabel('Width (m)')
widthFilePath = strcat(savePref1,'_widths');
saveas(gcf,widthFilePath,'fig')
    
% Plot number of nucleations with time
figure
plot(pc.time,pc.inits,'LineWidth',1.5)
legend('Nucleations')
ax = gca;
ax.FontName = 'ShellMedium';
ax.FontSize = 12;
xlabel('Time (s)')
ylabel('Number of nucleations')
nuclFilePath = strcat(savePref1,'_nucleations');
saveas(gcf,nuclFilePath,'fig')

% Plot number of growing clusters
figure
plot(pc.time,pc.growth,'LineWidth',1.5)
legend('Growing clusters')
ax = gca;
ax.FontName = 'ShellMedium';
ax.FontSize = 12;
xlabel('Time (s)')
ylabel('Number of clusters/pits')
growingFilePath = strcat(savePref1,'_growing');
saveas(gcf,growingFilePath,'fig')


% Plot number of mergers
figure
plot(pc.time,pc.mergers,'LineWidth',1.5)
legend('Mergers')
ax = gca;
ax.FontName = 'ShellMedium';
ax.FontSize = 12;
xlabel('Time (s)')
ylabel('Number of mergers')
mergerFilePath = strcat(savePref1,'_mergers');
saveas(gcf,mergerFilePath,'fig')

% Plot number of repassivations
figure
plot(pc.time,pc.repassive,'LineWidth',2)
legend('Repassivations')
ax = gca;
ax.FontName = 'ShellMedium';
ax.FontSize = 12;
xlabel('Time (s)')
ylabel('Number of repassivations')
repassFilePath = strcat(savePref1,'_repassivations');
saveas(gcf,repassFilePath,'fig')
 
% Plot number of consumed clusters/pits/inclusions
figure
plot(pc.time,pc.consumed,'LineWidth',2)
legend('Consumed entities')
ax = gca;
ax.FontName = 'ShellMedium';
ax.FontSize = 12;
xlabel('Time (s)')
ylabel('Number of consumptions')
consumedFilePath = strcat(savePref1,'_comsumptions');
saveas(gcf,consumedFilePath,'fig')

% Plot number of failed initiations
figure
plot(pc.time,pc.failedInitiations,'LineWidth',2)
legend('Failed Initiations')
ax = gca;
ax.FontName = 'ShellMedium';
ax.FontSize = 12;
xlabel('Time (s)')
ylabel('Number of failed initiations')
failIniFilePath = strcat(savePref1,'_failed_initiations');
saveas(gcf,failIniFilePath,'fig')

% Statistics of pit growths and deaths in a bar graph
figure
bar_y = [pc.inits(end) sum(pc.failedInitiations) sum(pc.mergers) sum(pc.repassive) sum(pc.consumed)]
b = bar(bar_y)
b.BarWidth = 0.5;
set(gca,'XTickLabel',{'Total nucleations', 'Total failed initiations', 'Total mergers','Total repassivations','Total consumptions'})
ax = gca;
ax.FontName = 'ShellMedium';
ax.FontSize = 12;
barFilePath = strcat(savePref1,'_bar');
saveas(gcf,barFilePath,'fig')


    