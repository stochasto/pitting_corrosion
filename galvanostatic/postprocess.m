function depthPlot = postprocess(pc,dL,c)

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
    
% Plot number of initiations with time
figure
plot(pc.time,pc.inits,'LineWidth',1.5)
legend('Initiations')
ax = gca;
ax.FontName = 'ShellMedium';
ax.FontSize = 12;
xlabel('Time (s)')
ylabel('Number of initiations')

% Plot number of growing clusters
figure
plot(pc.time,pc.growth,'LineWidth',1.5)
legend('Growing clusters')
ax = gca;
ax.FontName = 'ShellMedium';
ax.FontSize = 12;
xlabel('Time (s)')
ylabel('Number of clusters/pits')

% Plot number of mergers
figure
plot(pc.time,pc.mergers,'LineWidth',1.5)
legend('Mergers')
ax = gca;
ax.FontName = 'ShellMedium';
ax.FontSize = 12;
xlabel('Time (s)')
ylabel('Number of mergers')

% Plot number of repassivations
figure
plot(pc.time,pc.repassive,'LineWidth',2)
legend('Repassivations')
ax = gca;
ax.FontName = 'ShellMedium';
ax.FontSize = 12;
xlabel('Time (s)')
ylabel('Number of repassivations')
 
% Plot number of consumed clusters/pits/inclusions
figure
plot(pc.time,pc.consumed,'LineWidth',2)
legend('Consumed entities')
ax = gca;
ax.FontName = 'ShellMedium';
ax.FontSize = 12;
xlabel('Time (s)')
ylabel('Number of consumptions')

% Statistics of pit growths and deaths in a bar graph
figure
bar_y = [pc.inits(end) sum(pc.mergers) sum(pc.repassive) sum(pc.consumed)]
b = bar(bar_y)
b.BarWidth = 0.5;
set(gca,'XTickLabel',{'Total initiations','Total mergers','Total repassivations','Total consumptions'})
ax = gca;
ax.FontName = 'ShellMedium';
ax.FontSize = 12;


    