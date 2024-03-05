%% This function takes in a global folder with different subfolders, which have the result files of depth_time.csv for a single pit

% allData: column 1 -> r, col 2 -> theta, col3 -> iApply, col4 -> widthSlope, col5 -> depthSlope
% minCurrentData has the minimum growth current for a given r, theta combination. 
% The min currents are determined by simulations and are written in the minCurrentData sheet.

function [allData] = analyze_single(inFolderPath, csvFileName)

a1 = dir(inFolderPath);

a1 = a1(3:end);
numFiles = max(size(a1));

dataFile = 'depth_time.csv';

sprintf('number of files are %s',numFiles)

%% Process the files

% Create array of length numFiles, each row has data of that file. 
allData = zeros(numFiles,7);

for i = 1:1:numFiles
%for i = 1:1:2
    fName = a1(i).name;
    paramData = process_file_name(fName);
    % Read data file and find slopes of width, depth
    dataFilePath = strcat(inFolderPath,'\',fName,'\',dataFile);
    dt = readmatrix(dataFilePath);
    % Depth linear fit
    % Do this fit only if relative difference in depths is greater than 10%
    depth = dt(2:end,3)*-1;
    if ( ((max(depth) - min(depth))/max(depth)) > 0.1 )
        pDepth = polyfit(dt(2:end,2),depth,1);
        dIntercept = pDepth(2);
    else
        pDepth = 0;
        dIntercept = 0;
    end
    % Width linear fit
    % Do this fit only if relative difference in width is greater than 10%
    width = dt(2:end,4);
    if ( ((max(width) - min(width))/max(width)) > 0.1 )
        pWidth = polyfit(dt(2:end,2),dt(2:end,4),1);
        wIntercept = pWidth(2);
    else
        pWidth = 0;
        wIntercept = 0;
    end
        
    % Fill up allData
    allData(i,1) = paramData{1}; % r1
    allData(i,2) = paramData{2}; % theta1
    allData(i,3) = paramData{3}; % iApply
    allData(i,4) = pWidth(1);    % Width slope
    allData(i,5) = wIntercept;   % Width intercept
    allData(i,6) = pDepth(1);    % Depth slope 
    allData(i,7) = dIntercept;   % Depth intercept

    %end
end

%% Sort allData
allData = sortrows(allData, [1,2,3]);

%minCurrentData = get_min_current(allData);

%% Write to csv
% The output csv files are in a folder called 'alldata', one level above
% inFolderPath.
inSplit = split(inFolderPath,'\');
inSplit = inSplit(1:end - 1)
outPath = inSplit{1}
for i = 2:1:max(size(inSplit))
    outPath = strcat(outPath,'\',inSplit{i});
end
csvFilePath = strcat(outPath,'\','alldata','\',csvFileName);
writematrix(allData,csvFilePath,'Sheet','allData');
%writematrix(minCurrentData,csvFilePath,'Sheet','minCurrentData');


end


%% This function processes the file name to give geometry and iApply data
function pData = process_file_name(fName)

pData = cell(3,1);

fSplit = split(fName,'_');

% Process radius 1, split it further at E
r1Str = split(fSplit{2},'E');
r = str2double(r1Str{1})*10^(str2double(r1Str{2}));
% Process radius 2, split it further at E
%r2Str = split(fSplit{6},'E');
%r2 = str2double(r2Str{1})*10^(str2double(r2Str{2}));

% Process theta 1, convert to degrees
theta = str2double(fSplit{4})*180/pi;
%theta2 = str2double(fSplit{12})*180/pi;

% Process iApply
iApplyStr = split(fSplit{7},'E');
iApply = str2double(iApplyStr{1})*10^(str2double(iApplyStr{2}));

% iApply from Comsol is ten times larger, so get actual value
iApply = iApply/10;

% Fill pData
pData{1} = r;
pData{2} = theta;
pData{3} = iApply;

end

%% Function to determine min current, gets sorted row allData in A
function minCurrent = get_min_current(A)

s = height(A);

rowCount = 1;

minCurrent = zeros(1,5);

for i = 1:1:s
    aSub = A((A(:,1) == A(rowCount,1)) & (A(:,2) == A(rowCount,2)) & (A(:,3) == A(rowCount,3)) & (A(:,4) == A(rowCount,4)),:);
    sizeSub = height(aSub);    
    % Sort sub-array by width slope
    %aSub = sortrows(aSub, 6);
    % Sort sub-array by depth slope
    %aSub = sortrows(aSub, 8);
    
    prevSize = height(minCurrent);
    % aSub now has a set of currents, for the first few there might be no
    % growth. The least current at which the pits grow has to be found.
    %growInd = find(aSub(:,8));
    aSub = aSub(aSub(:,8) ~= 0,:); % Growing depths found
    aSub = sortrows(aSub,5); % Sort by current for non-zero depths
    minGrowingDepthSlope = aSub(1,8); % Min current is at first row in sorted aSub
    if (minGrowingDepthSlope > 1e-12)
        %minCurrent = [minCurrent; [aSub(growInd,1) aSub(growInd,2) aSub(growInd,3) aSub(growInd,4) aSub(growInd,5)]];
        minCurrent = [minCurrent; [aSub(1,1) aSub(1,2) aSub(1,3) aSub(1,4) aSub(1,5)]];
    end
    
%     for j = 1:1:sizeSub
%         minWidthSlope = aSub(j,8); % by depth
%         if (minWidthSlope > 1e-12)
%             minCurrent = [minCurrent; [aSub(j,1) aSub(j,2) aSub(j,3) aSub(j,4) aSub(j,5)]];
%             break
%         end
%     end
    
    % If minCurrent is not changed, i.e. no suitable current is found for min growth, then provide small default current
    % of 5e-7 mics
    if (height(minCurrent) == prevSize)
        %minCurrent = [minCurrent; [aSub(growInd,1) aSub(growInd,2) aSub(growInd,3) aSub(growInd,4) 5e-7]];
        minCurrent = [minCurrent; [aSub(1,1) aSub(1,2) aSub(1,3) aSub(1,4) 5e-7]];
    end
    rowCount = rowCount + sizeSub;
    if (rowCount > s)
        break
    end
end

% Remove initial row of zeros
minCurrent = minCurrent(2:end,:);

end

            
            
    
    
        







