% plot histograms for each save point. allPath is the path of the allData excel, output of run_galvano_par. Number of
% columns are equal to number of threads run, number of rows are samplesPerThread*nSave, where nSave is the number of
% time points at which the data was measured per sample. saveTimes is this list of sampling times

function postproc_parallel(saveTimes, allPath, timePath)

nSaves = max(size(saveTimes));

%% Read data
allDataNuc = readmatrix(allPath,'Sheet','nucleations');
allDataRepass = readmatrix(allPath,'Sheet','repassives');
allDataCons = readmatrix(allPath,'Sheet','consumptions');
allDataFail = readmatrix(allPath,'Sheet','failed_inits');
allDataDepth = readmatrix(allPath,'Sheet','max_depth');
allDataWidth = readmatrix(allPath,'Sheet','max_width');


timeData = readmatrix(timePath);

h = height(allDataNuc);
w = width(allDataNuc);

% numThreads and samplesPerThread
numThreads = w; % this is the number of cols in allData, each col is from a thread
samplesPerThread = h/nSaves;

totalSamples = numThreads*samplesPerThread;

%% Output data structures and main loop
nucs = zeros(totalSamples,nSaves); % each column for a given save time
repass = zeros(totalSamples,nSaves); 
cons = zeros(totalSamples,nSaves); 
fail = zeros(totalSamples,nSaves); 
depth = zeros(totalSamples,nSaves); 
width1 = zeros(totalSamples,nSaves); 

for j = 1:1:numThreads
    for i = 1:1:samplesPerThread
        nucs((j-1)*samplesPerThread + i,:) = allDataNuc((i-1)*nSaves+1:i*nSaves,j);
        repass((j-1)*samplesPerThread + i,:) = allDataRepass((i-1)*nSaves+1:i*nSaves,j);
        cons((j-1)*samplesPerThread + i,:) = allDataCons((i-1)*nSaves+1:i*nSaves,j);
        fail((j-1)*samplesPerThread + i,:) = allDataFail((i-1)*nSaves+1:i*nSaves,j);
        depth((j-1)*samplesPerThread + i,:) = allDataDepth((i-1)*nSaves+1:i*nSaves,j);
        width1((j-1)*samplesPerThread + i,:) = allDataWidth((i-1)*nSaves+1:i*nSaves,j);
    end
end

%% Plotting

% Plot allData
nBins = floor(sqrt(totalSamples));
figure
for k = 1:1:nSaves
    [rtd,x] = hist(nucs(:,k),nBins);
    %plot(x,rtd)
    plot(x,rtd,'LineWidth',2)
    %leg = strcat('Time ',num2str(saveTimes(k)));
    %legend(leg)
    ax = gca;
    ax.FontName = 'ShellMedium';
    ax.FontSize = 12;
    xlabel('Nucleations')
    ylabel('Count')
    hold on
end

figure
for k = 1:1:nSaves
    [rtd,x] = hist(repass(:,k),nBins);
    %plot(x,rtd)
    plot(x,rtd,'LineWidth',2)
    %leg = strcat('Time ',num2str(saveTimes(k)));
    %legend(leg)
    ax = gca;
    ax.FontName = 'ShellMedium';
    ax.FontSize = 12;
    xlabel('Repassivations')
    ylabel('Count')
    hold on
end

figure
for k = 1:1:nSaves
    [rtd,x] = hist(cons(:,k),nBins);
    %plot(x,rtd)
    plot(x,rtd,'LineWidth',2)
    %leg = strcat('Time ',num2str(saveTimes(k)));
    %legend(leg)
    ax = gca;
    ax.FontName = 'ShellMedium';
    ax.FontSize = 12;
    xlabel('Consumptions')
    ylabel('Count')
    hold on
end

figure
for k = 1:1:nSaves
    [rtd,x] = hist(fail(:,k),nBins);
    %plot(x,rtd)
    plot(x,rtd,'LineWidth',2)
    %leg = strcat('Time ',num2str(saveTimes(k)));
    %legend(leg)
    ax = gca;
    ax.FontName = 'ShellMedium';
    ax.FontSize = 12;
    xlabel('Failed Initiations')
    ylabel('Count')
    hold on
end

figure
for k = 1:1:nSaves
    [rtd,x] = hist(depth(:,k),nBins);
    %plot(x,rtd)
    plot(x,rtd,'LineWidth',2)
    %leg = strcat('Time ',num2str(saveTimes(k)));
    %legend(leg)
    ax = gca;
    ax.FontName = 'ShellMedium';
    ax.FontSize = 12;
    xlabel('Max depth')
    ylabel('Count')
    hold on
end

figure
for k = 1:1:nSaves
    [rtd,x] = hist(width1(:,k),nBins);
    %plot(x,rtd)
    plot(x,rtd,'LineWidth',2)
    %leg = strcat('Time ',num2str(saveTimes(k)));
    %legend(leg)
    ax = gca;
    ax.FontName = 'ShellMedium';
    ax.FontSize = 12;
    xlabel('Max width')
    ylabel('Count')
    hold on
end

% Plot times
nBins2 = floor(sqrt(max(size(timeData))));
figure
[rtd,x] = hist(timeData,nBins2);
plot(x,rtd)

    


