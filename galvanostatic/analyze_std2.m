%% This function takes in a global folder with different subfolders, which have the result files of depth_time.csv.
%  For example, inFolder could be dpit_5mics. Within this, there are subfolders of dpit_5mics_2em6, etc. By doing this,
%  the data for a given dpit are all in the same data structure.
% Tentative plan: Write all the r-theta values to a matrix. Process this matrix to get iMin values for a given r-theta
% combination.  
% Structure of output allData: column 1 -> r1, col 2 -> theta1, col3 -> r2, col4 -> theta2, co5 -> iApply, col6->
% widthSlope, col7 -> depthSlope
% minCurrentData has the minimum growth current for a given r1,theta1,r2,theta2 combination. get_min_current reads
% allData and gathers all the iApply rows for a given pair of pits. From these rows, it analyzes the width and depth
% slopes to determine if the pits are growing. If the pits are not growing (small slope), the next current at which the
% pit grows is the min current for growth.

function [allData, minCurrentData] = analyze_std2(inFolderPath, csvFileName)

a1 = dir(inFolderPath);

a1 = a1(3:end);
s1 = max(size(a1));

dataFile = 'depth_time.csv';

%% Get number of files to process

numFiles = 0;

for i = 1:1:s1
    dirName = a1(i).name;
    subFolderPath = strcat(inFolderPath,'\',dirName);
    b1 = dir(subFolderPath);
    numFiles = numFiles + length(b1) - 2;
end

sprintf('number of files are %s',numFiles);

%% Process the files

% Create array of length numFiles, each row has data of that file. 
allData = zeros(numFiles,9);

counter = 0;

for i = 1:1:s1
    dirName = a1(i).name;
    subFolderPath = strcat(inFolderPath,'\',dirName)
    b1 = dir(subFolderPath);
    b1 = b1(3:end);
    s2 = max(size(b1));
    
    for j = 1:1:s2
        % Increment counter for new file
        counter = counter + 1; 
        % Name of the folder with r1,theta1, etc.
        fName = b1(j).name;
        % Process the file name to give the various variables r1, theta1, etc.
        paramData = process_file_name(fName);
        % Read data file and find slopes of width, depth
        dataFilePath = strcat(subFolderPath,'\',fName,'\',dataFile);
        dt = readmatrix(dataFilePath);
        % Depth linear fit
        % Do this fit only if relative difference in depths is greater than 2%
        depth = dt(:,3)*-1;
        if ( ((max(depth) - min(depth))/max(depth)) > 0.02 )
            pDepth = polyfit(dt(:,2),depth,1);
            dIntercept = pDepth(2);
        else
            pDepth = 0;
            dIntercept = 0;
        end
        % Width linear fit
        % Do this fit only if relative difference in width is greater than 2%
        width = dt(:,4);
        if ( ((max(width) - min(width))/max(width)) > 0.02 )
            pWidth = polyfit(dt(:,2),dt(:,4),1);
            wIntercept = pWidth(2);
        else
            pWidth = 0;
            wIntercept = 0;
        end
        
        % Fill up allData
        allData(counter,1) = paramData{1}; % r1
        allData(counter,2) = paramData{3}; % theta1
        allData(counter,3) = paramData{2}; % r2
        allData(counter,4) = paramData{4}; % theta2
        allData(counter,5) = paramData{5}; % iApply
        allData(counter,6) = pWidth(1);    % Width slope
        allData(counter,7) = wIntercept;   % Width intercept
        allData(counter,8) = pDepth(1);    % Depth slope 
        allData(counter,9) = dIntercept;   % Depth intercept

    end
end

%% Sort allData
allData = sortrows(allData, [1,2,3,4,5]);

minCurrentData = get_min_current(allData);

%% Write to csv
csvFilePath = strcat(inFolderPath,'\',csvFileName);
writematrix(allData,csvFilePath,'Sheet','allData');
writematrix(minCurrentData,csvFilePath,'Sheet','minCurrentData');


end


%% This function processes the file name to give geometry and iApply data
function pData = process_file_name(fName)

pData = cell(5,1);

fSplit = split(fName,'_');

% Process radius 1, split it further at E
r1Str = split(fSplit{3},'E');
r1 = str2double(r1Str{1})*10^(str2double(r1Str{2}));
% Process radius 1, split it further at E
r2Str = split(fSplit{6},'E');
r2 = str2double(r2Str{1})*10^(str2double(r2Str{2}));

% Process theta 1 and 2, convert to degrees
theta1 = str2double(fSplit{9})*180/pi;
theta2 = str2double(fSplit{12})*180/pi;

% Process iApply
iApplyStr = split(fSplit{15},'E');
iApply = str2double(iApplyStr{1})*10^(str2double(iApplyStr{2}));

% iApply from Comsol is ten times larger, so get actual value
iApply = iApply/10;

% Fill pData
pData{1} = r1;
pData{2} = r2;
pData{3} = theta1;
pData{4} = theta2;
pData{5} = iApply;

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
    aSub = sortrows(aSub, 6);
    
    prevSize = height(minCurrent);
    
    for j = 1:1:sizeSub
        minWidthSlope = aSub(j,6);
        if (minWidthSlope > 1e-12)
            minCurrent = [minCurrent; [aSub(j,1) aSub(j,2) aSub(j,3) aSub(j,4) aSub(j,5)]];
            break
        end
    end
    
    % If minCurrent is not changed, i.e. no suitable current is found for min growth, then provide small default current
    % of 5e-7 mics
    if (height(minCurrent) == prevSize)
        minCurrent = [minCurrent; [aSub(j,1) aSub(j,2) aSub(j,3) aSub(j,4) 5e-7]];
    end
    rowCount = rowCount + sizeSub;
    if (rowCount > s)
        break
    end
end

% Remove initial row of zeros
minCurrent = minCurrent(2:end,:);

end

            
            
    
    
        







