% Function for galvanostatic simulation of pitting
% c{i,1} can be -> a positive integer, eg 15, this is an inclusion that is available. If c{i,8}, i.e a growth current is
%                  associated with this i'th inclusion, then i is growing;
%               -> an array of positive integers, eg [3,54,980], which means it is a cluster of three inclusions. 
%               -> -1, which means it belongs to another cluster. Each cluster has a 'leader', which is an inclusion whose
%                  row corresponds to all details of the cluster. All size dimensions, currents, etc associated with the
%                  cluster are found in this array
%               -> -2, a pit that was once active but repassivated
%               -> -3, a repassivated pit or uninitiated inclusion, that was consumed by a growing cluster.


%function [pitCounts, dimList, clusterCell, r] = Pit_Propagation_Galvano(iApply,finalTime)
function [pitCell, dimCell, clustCell] = Pit_Propagation_Galvano2(iApply,saveTimes,finalTime)

%% Get files
parameters;
%galvano_utilities;

%% Save times
numSave = max(size(saveTimes));
pitCell = cell(numSave,1);
dimCell = cell(numSave,1);
clustCell = cell(numSave,1);
%rCell = cell(numSave,1);

%% Geometry section

%Geometry of the pits
[Na,r_surf,theta_surf]=getGeom();
%Ni=Na;

if (gridType == 'uniform')
    Ni = gridSize^2;
    % X-Y coordinates of inclusion centers
    rx = zeros(Ni,1);
    ry = zeros(Ni,1);
    for i = 1:1:gridSize
        for j = 1:1:gridSize
            inclusionIndex = (i - 1)*gridSize + j;
            rx(inclusionIndex) = i*gridGap;
            ry(inclusionIndex) = j*gridGap;
        end
    end
else
    Ni = Na;
    % X-Y coordinates of inclusion centers
    rx = zeros(Ni,1);
    ry = zeros(Ni,1);
end

sprintf('Number of Inclusions: %d',Ni)

%Collated Pit Geometry description
%r = r_surf;
%theta = theta_surf;

% TEST R AND THETA
%r = (ones(Ni,1)*1e-5).*(rand(Ni,1));
% Uniform
%r = (ones(Ni,1)*rUniformMax).*(rand(Ni,1));
% Lognormal
u = rand(Ni,1);
r = exp(mu_log + sigma_log^2 + sigma_log*norminv(u));
r = r*1e-6;
max(r);
min(r);

theta = 5 + 80*rand(Ni,1);

%r = ones(Ni,1)*1e-5;
%theta = ones(Ni,1)*30;
%theta = 5 + 80*rand(Ni,1);

%cosTheta=[cosTheta_surf; cosd(theta_cone)*ones(size(r_subSurf,1),1)];  
%d=[zeros(size(r_surf,1),1); d_subSurf]; 

cosTheta = cosd(theta);
Area_Inclusions=pi*r.^2.*(1-cosTheta.^2);

%% Read important data files
% initFile is the result of std1 runs from which minimum current for growth
% is determined. This file has: first column radius, for each radius there
% are a few angles, for each angle there are a set of applied currents, for
% each current there is a pit bottom concentration.
%initFile = 'result_std1_1pit.xlsx';

% initCurrents is the result of processing initFile. This contains, for
% each radius, a set of angles and for each angle, there is a min current
% at which Critical conc of 2800 is reached. 
%initCurrents = get_init_currents(initFile);

%initCurrents were earlier being read from a file and processing this with
%get_init_currents. However, accurate simulations have been done for single
%pits for radii 2 to 10 microns and angles 15 to 60 degrees. It has been
%determined what the exact min current is for each geometry for growth.
%This result is in the mincurrentdata sheet of the file alldata_0mics.xlsx. First col is
%radius, second is angle and third is the min growth current. So,
%initCurrents is just the result of reading this file
%initCurrents = readmatrix('single_pit_mincurrents.xlsx');
initCurrents = readmatrix('alldata_0mics.xlsx','Sheet','minCurrentData');

% In initCurrents, there is a list of angles for each radius and the
% corresponding current. A linear relation exists between angles and min
% currents for a given radius, this is determined in rLinTheta. First
% column is radius, second is slope, third is intercept
[rLinTheta rLinCD] = get_linear_theta_current(initCurrents);
rMax = max(rLinTheta(:,1));
numrLinTheta = height(rLinTheta);

% allData and minCurrentData need to be read for each given dpit. For this, the appropriate variables are created and
% files are read. The variables and filenames have to follow the convention below.

dPits = [ '0mics'; '2mics'; '5mics'; '8mics'];
dPitsVal = [0e-6 2e-6 5e-6 8e-6];
numDpits = size(dPits,1);
allDataCell = cell(numDpits,1);
minDataCell = cell(numDpits,1);

for i = 1:1:numDpits
    allDataFile = strcat('alldata_',dPits(i,:),'.xlsx');
    allDataCell{i} = readmatrix(allDataFile,'Sheet','allData');
    minDataCell{i} = readmatrix(allDataFile,'Sheet','minCurrentData');
    
    % sort rows
    if (i > 1)
        allDataCell{i} = sortrows(allDataCell{i},[1,2,3,4,5]);
        minDataCell{i} = sortrows(minDataCell{i},[1,2,3,4]);
    else
        allDataCell{i} = sortrows(allDataCell{i},[1,2,3]);
        minDataCell{i} = sortrows(minDataCell{i},[1,2]);
    end
end

total_inclusions_area = sum(Area_Inclusions)

%% Debug figures
%figure
%hist(Area_Inclusions,sqrt(Ni));


% Plot histograms of potential
% figure;
% hist(Em,100);
% t = strcat('Em for theta cone ',num2str(theta_cone));
% title(t);
%sprintf('Min and Max Em are %f and %f',min(Em),max(Em))

% figure;
% hist(Es,100);
% t = strcat('Es for theta cone ',num2str(theta_cone));
% title(t);
%sprintf('Min and Max Es are %f and %f',min(Es),max(Es))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Stable_Pits = cell(1,1);
%MetaStable_Pits = cell(1,2);
%Non_initiated_Pits = cell(1,1);

% Create timestep array
%numTimes = 101;
%timer = zeros(numTimes,1);
%finalTime = 1000;
%timestep = finalTime/(numTimes - 1);

%% Timesteps
%timeStep = 0.1;
timeStep = 0.1;
timer = 0:timeStep:finalTime;
nTimes = max(size(timer))

% Debugging
% nRemain = zeros(timesteps,1);
% qt = zeros(timesteps,1);
% nPresent = zeros(timesteps,1);

%% Nucleation site geometry and number
%Number of Nucleation sites
n_nucleation=poissrnd(A*nu_n)

%n_nucleation = 1e+6;

timestepcount=0; %timesteps=100;
t_nucleation = zeros(Ni,1);

%nucleation_at_inclusion=zeros(timesteps,Ni);
n_nucleation_instant=0; 
n_nucleation_remaining=n_nucleation;
nucleation_count = zeros(nTimes,1); % Number of nucleations at inclusions at each timestep

inclusions_remaining = Ni;
isInitiated = zeros(Ni,1); % Indicator to show if a given inclusion is initiated
isConsumed = zeros(Ni,1); % Indicator to show if an uninitiated inclusion is consumed by a growing cluster
isGrowing = zeros(Ni,1); % Indicator to show if an initiated inclusion is growing (will grow if pit stability is satisfied)
initiated_inclusions_area = 0;
inclusions_area = total_inclusions_area; % Initially all inclusions are available

% Initial Growth current, allocated only when an inclusion newly initiates. 
growthCurrent = zeros(Ni,1);


%% Important data structures
% pitMatrix: i'th row has details of i'th inclusion. First column is time of
% initiation, second column is width, third is depth
%pitMatrix = zeros(Ni,3); 
% clusterCell, i'th element is a cell with indices of inclusions part of the i'th cluster. In the beginning,
% consider each pit a 1-pit cluster. First column contains the array of indices of constituent nucleations. Other
% columns contain rx, ry of center, width and depth
clusterCell = cell(Ni,11);
for i = 1:1:Ni
    clusterCell{i,1} = i;
    clusterCell{i,2} = rx(i);
    clusterCell{i,3} = ry(i);
    clusterCell{i,4} = 2*r(i); % Initial width
    clusterCell{i,5} = r(i)*(1 + cosd(theta(i))); % Initial depth
    clusterCell{i,6} = 0; % Which other cluster it is growing with, initally 0 shows it is not paired with any other
    clusterCell{i,7} = 0; % rij distance with closest cluster. 0 if not paired or growing alone
    clusterCell{i,8} = 0; % Minimum current, very important parameter 
    clusterCell{i,9} = 0; % If cluster has been checked
    clusterCell{i,10} = theta(i); % Initial angle
    clusterCell{i,11} = 0; % lifetime
end

distMatrix = zeros(Ni,3);

% Important, pitCounts
% 
pitCounts.time = timer;
pitCounts.inits = zeros(nTimes,1);
pitCounts.growth = zeros(nTimes,1);
pitCounts.mergers = zeros(nTimes,1);
pitCounts.repassive = zeros(nTimes,1);
pitCounts.consumed = zeros(nTimes,1);
pitCounts.failedInitiations = zeros(nTimes,1);

dimList.time = timer;
dimList.depthList = cell(nTimes,1);
dimList.maxDepth = zeros(nTimes,1);
dimList.widthList = cell(nTimes,1);
dimList.maxWidth = zeros(nTimes,1);

%%
%Debug
% nRemain(1) = n_nucleation;
% qt(1) = 0;
% nPresent(1) = 0;

%% Save
nSave = min(nTimes,10);
outPath = 'C:\Users\Vishal.Metri\Documents\pitting\data\results_galvano';
outPrefix = 'c';
saveFreq = floor(nTimes/nSave);

n_nucleation_prev = 0;

% saveIndex is the index of time to save
saveIndex = 1;

for timestepcount=2:1:nTimes
    totalGrowing = 0; % Total number of pits growing counter, set to 0
    totalMergers = 0;
    totalRepassive = 0;
    totalConsumed = 0;
    totalFailedInitiations = 0;
    %timestepcount=timestepcount+1;
    q=1-exp(-gam*timer(timestepcount));
    
    % So far
    n_nucleation_remaining=n_nucleation_remaining-n_nucleation_instant;
    n_nucleation_instant=binornd(n_nucleation_remaining,q);
    
    % Alternate
    %n_nucleation_tot=binornd(n_nucleation,q);
    %n_nucleation_instant = n_nucleation_tot - n_nucleation_prev;
    %n_nucleation_prev = n_nucleation_tot;
    
    n_nucleation_instant_inclusions = binornd(n_nucleation_instant,alpha_i);
    nucleation_count(timestepcount) = n_nucleation_instant_inclusions;
    %inclusions_nucleated = 0;
    
    inclusions_area = total_inclusions_area - initiated_inclusions_area;
    
    % Debug
    %nRemain(timestepcount) = nRemain(timestepcount - 1) - n_nucleation_instant;
    %qt(timestepcount) = q;
    %nPresent(timestepcount) = n_nucleation_instant;
    
    % Set initial growth currents to zero in the beginning
    %growthCurrent = zeros(Ni,1);
    
    for i=1:Ni
        %clusterCell{i,8} = 0; % Set minimum current requirement to 0 initially
        if ((~isInitiated(i)) && (n_nucleation_instant_inclusions > 0) && (~isConsumed(i)))
            z = n_nucleation_instant_inclusions*Area_Inclusions(i)/inclusions_area;
            %z = n_nucleation_instant_inclusions*Area_Inclusions(i)/total_inclusions_area;
            %nucleation_at_inclusion(timestepcount,i)= round(z);
            %j = nucleation_at_inclusion(timestepcount,i);
            j = round(z);
%             if (timer(timestepcount) == 20)
%                 j;
%                 fprintf(fid,'%d %f %d\n',i,Area_Inclusions(i),j);
%             end
            if (j > 0)
                iTimes = zeros(j,1);
                % Draw j times for the i'th inclusion. Times have to be sampled from gam(1 - q(x))/q(timestepcount). The cdf
                % works out to be: F(t) = (1 - exp(-gam*t))/(q(timestepcount)). Equating this to a
                % uniform random gives the time as: t = (-1/gam)*log(1 - u*q(timestepcount))
                % However, withing time interval t1 to t2, we have to sample from the truncated distribution between t1 and t2,
                % whose CDF is given by (F(t) - F(t1))/(F(t2) - F(t1)).
                % Equating this to u gives: t = (-1/gam)*log((1-u)exp(-gam*t1) + u*exp(-gam*t2))
                u = rand(j,1);
                %iTimes(1) = (-1/gam)*log(1 - u*q);
                iTimes = (-1/gam)*log( (1 - u)*exp(-gam*timer(timestepcount - 1)) + u*exp(-gam*timer(timestepcount)));
                t_nucleation(i) = min(iTimes);
%                 if (timestepcount == 10)
%                     t_nucleation(i)
%                 end

                 isInitiated(i) = 1;
                 % Check if the initiated i'th inclusion grows. For this, determine the min current required for growth
                 % Nearest possible radius is chosen
                 if (r(i) <= rMax)
                    radInd = find( rLinTheta(:,1) >= r(i),1,'first');
                 else
                     radInd = numrLinTheta;
                 end
                 % Initial current required for growth is determined from linear fit of theta and current from rLinTheta
%                  if(max(rLinTheta(radInd,:)) == 0)
%                      rLinTheta
%                      r(i)
%                  end
                 try
                    growthCurrent(i) = rLinTheta(radInd,2)*theta(i) + rLinTheta(radInd,3);
                 catch
                     rLinTheta(radInd,:)
                     radInd
                     r(i)
                 end
                 clusterCell{i,8} = growthCurrent(i);
            end    
        end    
    end
    
    
    % To do: Keep a matrix of ij pairs, that are selected based on minimum distance
    % Growth law to be determined based on distance (dpit)
    distCount = 0;
    % Loop over clusters
    for i = 1:1:Ni - 1
        %if ( (clusterCell{i,1} ~= -1) & (isInitiated(i)) )
        if ( (max(clusterCell{i,1}) > 0) & (isInitiated(i)) )
            for j = i+1:1:Ni
                %if ( (clusterCell{j,1} ~= -1) & (isInitiated(j)) )
                if ( (max(clusterCell{j,1}) > 0) & (isInitiated(j)) )
                    rij = sqrt((clusterCell{i,2} - clusterCell{j,2})^2 + (clusterCell{i,3} - clusterCell{j,3})^2);
                    if (rij < radiusCheck)
                        distCount = distCount + 1;
                        distMatrix(distCount,1) = i;
                        distMatrix(distCount,2) = j;
                        distMatrix(distCount,3) = rij;
                    end
                end
            end
        end
    end
    
    % Distance matrix is sorted with rij-distances. Then, minimum values are chosen from the first row and the i-j pair
    % corresponding to this distance is filtered out.
    %distMatrix = distMatrix(find(distMatrix(:,1)),:);
    distMatrix = distMatrix(1:distCount,:);
    distMatrix = sortrows(distMatrix,3);
    %fprintf('Height distmatrix is %d\n',height(distMatrix))
    while (height(distMatrix) > 0)
        % Index of cluster 1
        c1Index = distMatrix(1,1);
        % Index of cluster 2
        c2Index = distMatrix(1,2);
        % c1 is paired with c2, distance as well
        clusterCell{c1Index,6} = c2Index;
        clusterCell{c1Index,7} = distMatrix(1,3);
        % c2 is paired with c1
        clusterCell{c2Index,6} = c1Index;
        clusterCell{c2Index,7} = distMatrix(1,3);
        % Remove rows where c1Index appears
        distMatrix((distMatrix(:,1) == c1Index) | (distMatrix(:,2)==c1Index),:) = [];
        % Remove rows where c2Index appears
        distMatrix((distMatrix(:,1) == c2Index) | (distMatrix(:,2)==c2Index),:) = [];
    end
    
    % Some clusters have been allocated a pair at this point. However, there could be a few with no pairs and so will
    % grow as stand alone pits. Loop over clusters, determine minimum current of each pair or standalone
    
    % The minimum current allocation rule must change. Each pit, when it first starts growing, is given a mincurrent 
    % according to rLinTheta. This must stay constant throughout the simulation. The min current required for growth 
    % is the value determined from single pit simulations in the sheet single_pit_mincurrents. If a cluster is paired
    % with another one, the mincurrents do not change. 

    
%     for i = 1:1:Ni
%         %if ( (clusterCell{i,1} ~= -1) & (isInitiated(i)) & (~clusterCell{i,9}) )
%         if ( (max(clusterCell{i,1}) > 0) & (isInitiated(i)) & (~clusterCell{i,9}) )
%             % Check if cluster has been paired
%             if (clusterCell{i,6})
%                 j = clusterCell{i,6}; % Index of other cluster
%                 %fprintf('Pairs %d %d\n',i,j)
%                 % Mark  both i and j clusters as checked
%                 clusterCell{i,9} = 1; 
%                 clusterCell{j,9} = 1;
%                 % Allocate min currents, check growthCurrent
%                 if (growthCurrent(i) && ~growthCurrent(j))
%                     clusterCell{i,8} = growthCurrent(i);
%                     clusterCell{j,8} = allocate_single_current(clusterCell,j,minDataCell{2});
%                 elseif (~growthCurrent(i) && growthCurrent(j))
%                     clusterCell{j,8} = growthCurrent(j);
%                     clusterCell{i,8} = allocate_single_current(clusterCell,i,minDataCell{2});
%                 elseif (growthCurrent(i) && growthCurrent(j))
%                     clusterCell{i,8} = growthCurrent(i);
%                     clusterCell{j,8} = growthCurrent(j);
%                 else
%                     clusterCell{i,8} = allocate_pair_current(clusterCell,i,j,minDataCell{1});
%                     clusterCell{j,8} = 0; % Current already allocated to i
%                 end
%             else
%                 clusterCell{i,9} = 1; 
%                 %fprintf('Standalone %d\n',i)
%                 if (growthCurrent(i))
%                     clusterCell{i,8} = growthCurrent(i);
%                 else
%                     clusterCell{i,8} = allocate_single_current(clusterCell,i,minDataCell{2});
%                 end
%             end
%         end
%     end
    
    % All minCurrents are determined. Currents are now allocated to each cluster, growth rates determined and pits are
    % grown along with mergers.
    minCurrents = cell2mat(clusterCell(:,8));
    indGrowing = find(minCurrents); % indices of growing clusters
    numGrowing = length(indGrowing); % number of growing clusters
    % currs is an important array
    % First column is indices of growing clusters, second is the corresponding mincurrents, third is the extracurrent
    % This is used to calculate the actual current for the pit. This is done as follows:
    % iApply is the applied current. This has to be split among all the growing pits/clusters. A mincurrent for pit
    % growth is already calculated in clusterCell{:,8}. We sum up the mincurrents and count the integer number of times
    % this sum is a part of iApply, i.e. numI = floor(iApply/totalMinCurrent). numI is the integer number of times each
    % mincurrent for a pit appears in iApply. On top of that we calculate iRemaining which is the amount remaining after
    % division by totalMinCurrent. 
    % The iRemaining is divided such that the cluster with minimum current requirement gets its share first. When
    % iRemaining runs out, the other pits do not get any extra current.
    currs = zeros(numGrowing,3); 
    currs(:,1) = indGrowing;
    currs(:,2) = minCurrents(indGrowing);
    currs = sortrows(currs,2);
    
    totalMinCurrent = sum(currs(:,2)); % Sum of all minimum currents
    if (totalMinCurrent)
        numI = floor(iApply/totalMinCurrent); % iApply is some multiple of totalMinCurrent and some extra
        iRemaining = iApply - numI*totalMinCurrent; % The extra amount lesser than totalMinCurrent
        sumI = cumsum(currs(:,2));
        currs(:,3) = currs(:,2); 
        currs(find(sumI > iRemaining,1,'first'):end,3) = 0;
    else
        fprintf('No current demand at %f\n',timer(timestepcount))
        continue
        %fprintf('Not enough current, simulation ends at %f\n',timer(timestepcount))
        %break % If there is no current, kill the simulation
    end
    
    for i = 1:1:Ni
        % Check if cluster is initiatated, not part of a cluster and has a growth current
        %if ( (clusterCell{i,1} ~= -1) & (isInitiated(i)) & (clusterCell{i,8}) )
        % A cluster is growing if it has a positive index in the first column and is initiated. In addition, we need to
        % avoid double counting a pair, so if an i-j pair is detected, the min current for the j'th cluster has been set to
        % zero earlier. All these are checked below.
        growingInds = zeros(2,1);
        growingCurrs = zeros(2,1);
        if ( (max(clusterCell{i,1}) > 0) & (isInitiated(i)) & (clusterCell{i,8}) & (~clusterCell{i,9}) )
            clusterCell{i,9} = 1; % checked i
            % Check if cluster is paired or growing stand-alone
            if ( clusterCell{i,6})
                j = clusterCell{i,6};
                clusterCell{j,9} = 1; % checked j
                iC_i = numI*currs(currs(:,1)==i,2) + currs(currs(:,1)==i,3); % Important: Current allocated to i'th cluster
                iC_j = numI*currs(currs(:,1)==j,2) + currs(currs(:,1)==j,3); % Important: Current allocated to j'th cluster
                if ((iC_i) & (iC_j)) % both i and j have enough current to grow, so pair growth is done
                    growingInds(1) = i;
                    growingInds(2) = j;
                    growingCurrs(1) = iC_i;
                    growingCurrs(2) = iC_j;
                    totalGrowing = totalGrowing + 2;
                    clusterCell{i,11} = clusterCell{i,11} + timeStep;
                    clusterCell{j,11} = clusterCell{j,11} + timeStep;
                elseif ((iC_i) & ~(iC_j)) % i grows and j repassivates
                    growingInds(1) = i; % Mark i for growth
                    growingCurrs(1) = iC_i;
                    if (clusterCell{j,11}) % If pit has been growing, it has a lifetime
                        clusterCell{j,1} = -2; % j repassivates
                        totalRepassive = totalRepassive + 1;
                    else
                        clusterCell{j,1} = -4; % failed initiation
                        totalFailedInitiations = totalFailedInitiations + 1;
                    end
                    totalGrowing = totalGrowing + 1;
                    clusterCell{i,11} = clusterCell{i,11} + timeStep;
                elseif (~(iC_i) & (iC_j)) % j grows and i repassivates
                    growingInds(1) = j; % Mark j for growth
                    growingCurrs(1) = iC_j;
                    if (clusterCell{i,11}) % If pit has been growing, it has a lifetime
                        clusterCell{i,1} = -2; % i repassivates
                        totalRepassive = totalRepassive + 1;
                    else
                        clusterCell{i,1} = -4; % failed initiation
                        totalFailedInitiations = totalFailedInitiations + 1;
                    end
                    totalGrowing = totalGrowing + 1;
                    clusterCell{j,11} = clusterCell{j,11} + timeStep;
                else % both i and j repassivate
                    if (clusterCell{i,11}) % If pit has been growing, it has a lifetime
                        clusterCell{i,1} = -2; % i repassivates
                        totalRepassive = totalRepassive + 1;
                    else
                        clusterCell{i,1} = -4; % failed initiation
                        totalFailedInitiations = totalFailedInitiations + 1;
                    end
                    if (clusterCell{j,11}) % If pit has been growing, it has a lifetime
                        clusterCell{j,1} = -2; % j repassivates
                        totalRepassive = totalRepassive + 1;
                    else
                        clusterCell{j,1} = -4; % failed initiation
                        totalFailedInitiations = totalFailedInitiations + 1;
                    end
                    continue % continue the loop since both repassivate and there is no growth
                end
            else % single unpaired cluster
                iC_i = numI*currs(currs(:,1)==i,2) + currs(currs(:,1)==i,3); % Important: Current allocated to i'th cluster
                if (iC_i)
                    growingInds(1) = i;
                    growingCurrs(1) = iC_i;
                    clusterCell{i,11} = clusterCell{i,11} + timeStep;
                    totalGrowing = totalGrowing + 1;
                else
                    if (clusterCell{i,11}) % If pit has been growing, it has a lifetime
                        clusterCell{i,1} = -2; % i repassivates
                        totalRepassive = totalRepassive + 1;
                    else
                        clusterCell{i,1} = -4; % failed initiation
                        totalFailedInitiations = totalFailedInitiations + 1;
                    end
                    continue
                end
            end
            % Analyze growingInds and growingCurrs. If execution has reached here, it means that either or both of the
            % pits are growing. If both are growing, then growingInds has both non-zero entries, else only the first
            % entry is non-zero, and this could be either i or j.
            if growingInds(2) ~= 0 % both i and j are growing
                % determine dPit to choose the correct allDataCell. We have data for dPit 2, 5 and 8e-6. By taking
                % midpoints of these intervals, the correct dPit sheet to be sent are determined
                dPit = clusterCell{i,7} - (clusterCell{i,4} + clusterCell{j,4})*0.5;
                if (dPit <= 3.5e-6) % use dPit_2microns
                    [wSlope,wIntercept,dSlope,dIntercept] = get_pair_rates(clusterCell,i,j,allDataCell{2});
                elseif ((dPit > 3.5e-6) & (dPit < 6.5e-6)) % use dPit_5microns
                    [wSlope,wIntercept,dSlope,dIntercept] = get_pair_rates(clusterCell,i,j,allDataCell{3});
                else % use dPit_8microns
                    [wSlope,wIntercept,dSlope,dIntercept] = get_pair_rates(clusterCell,i,j,allDataCell{4});
                end
                %iCurrent = numI*currs(currs(:,1)==i,2) + currs(currs(:,1)==i,3); % Important: Current allocated to i'th cluster
%                 if (iCurrent == 0)
%                     clusterCell{i,1} = -2; % Pit repassivates
%                     clusterCell{j,1} = -2; % Pit repassivates
%                     totalRepassive = totalRepassive + 2;
%                     continue
%                 else
%                     totalGrowing = totalGrowing + 2;
%                 end
                %fprintf('Here\n')
                iCurrent = sum(growingCurrs); % add both i and j currents to determine slopes
                newWidthRate = wSlope*iCurrent + wIntercept;
                newDepthRate = dSlope*iCurrent + dIntercept;
            
                % Update width and depth
                clusterCell{i,4} = max(clusterCell{i,4} + newWidthRate*timeStep,1e-12);
                clusterCell{i,5} = max(clusterCell{i,5} + newDepthRate*timeStep,1e-12);
                clusterCell{j,4} = max(clusterCell{j,4} + newWidthRate*timeStep,1e-12);
                clusterCell{j,5} = max(clusterCell{j,5} + newDepthRate*timeStep,1e-12);
                
                % Store width and depth in dimList
                dimList.depthList{timestepcount} = [dimList.depthList{timestepcount} clusterCell{i,5} clusterCell{j,5}];
                dimList.widthList{timestepcount} = [dimList.widthList{timestepcount} clusterCell{i,4} clusterCell{j,4}];
            else
                ind = growingInds(1); % index of growing cluster, could be i or j
                [wSlope,wIntercept,dSlope,dIntercept] = get_single_rates(clusterCell,ind,allDataCell{1});
                iCurrent = growingCurrs(1);
                %iCurrent = numI*currs(currs(:,1)==ind,2) + currs(currs(:,1)==ind,3); % Important: Current allocated to i'th cluster
%                 if (iCurrent == 0)
%                     clusterCell{i,1} = -2; % Pit repassivates
%                     totalRepassive = totalRepassive + 1;
%                     continue
%                 else
%                     totalGrowing = totalGrowing + 1;
%                 end
                %fprintf('Here\n')
                newWidthRate = wSlope*iCurrent + wIntercept;
                newDepthRate = dSlope*iCurrent + dIntercept;
                
                % Update width and depth
                clusterCell{ind,4} = max(clusterCell{ind,4} + newWidthRate*timeStep,1e-12);
                clusterCell{ind,5} = max(clusterCell{ind,5} + newDepthRate*timeStep,1e-12);
                % Store width and depth in dimList
                dimList.depthList{timestepcount} = [dimList.depthList{timestepcount} clusterCell{ind,5}];
                dimList.widthList{timestepcount} = [dimList.widthList{timestepcount} clusterCell{ind,4}];
            end
        end
    end
    
    % Run i-j loop to check mergers with other clusters and to remove uninitiated nucleations which are consumed
    for i = 1:1:Ni
        %if ( (clusterCell{i,1} ~= -1) & (isInitiated(i)) )
        if ( (max(clusterCell{i,1}) > 0) & (isInitiated(i)) )
           for j =  1:1:Ni
           if( i ~= j)
               %i1 = max(clusterCell{i,1});
               %j1 = max(clusterCell{j,1});
               %if ( (clusterCell{j,1} ~= -1) & (isInitiated(j)) )
               %if ( (i1 > 0) & (j1 > 0) & (isInitiated(i1)) & (isInitiated(j1)) ) % Both are growing clusters
               if ( (max(clusterCell{j,1}) > 0) & (isInitiated(j)) ) % Both i and j are growing clusters
                   rij = sqrt((clusterCell{i,2} - clusterCell{j,2})^2 + (clusterCell{i,3} - clusterCell{j,3})^2);
                   r1 = clusterCell{i,4}*0.5;
                   r2 = clusterCell{j,4}*0.5;
                   r0 = r1 + r2;
                   if ( rij < r0 )
                       totalMergers = totalMergers + 1;
                       clusterCell{i,1} = [clusterCell{i,1} clusterCell{j,1}];
                       clusterCell{j,1} = -1;
                       % New center is just the midpoint of line joining centers for now, will change later with a more
                       % accurate expression
                       clusterCell{i,2} = (clusterCell{i,2} + clusterCell{j,2})*0.5;
                       clusterCell{i,3} = (clusterCell{i,3} + clusterCell{j,3})*0.5;
                       % New theta preserves area
                       %x = (0.5*clusterCell{i,4}*clusterCell{j,4} + 0.25*( (clusterCell{i,4}*cosd(clusterCell{i,10}))^2 ...
                       %    + (clusterCell{j,4}*cosd(clusterCell{j,10}))^2))/(r0^2);
                       cost = (cosd(clusterCell{i,10})*(r1^2) + cosd(clusterCell{j,10})*(r2^2) - 2*r1*r2)/(r1 + r2)^2;
                       if (cost > 1)
                           fprintf('cos theta is %f\n',cost)
                           fprintf('r0 %f\n',r0)
                           fprintf('r1 %f\n',r1)
                           fprintf('r2 %f\n',r2)
                           fprintf('theta 1 %f\n', clusterCell{i,10})
                           fprintf('theta 2 %f\n',clusterCell{j,10})
                       end
                       %cost = sqrt(x);
                       clusterCell{i,10} = acosd(cost); % New angle in degrees
                       % New width is sum of old widths
                       clusterCell{i,4} = r0*2;
                       % New depth 
                       clusterCell{i,5} = r0*(1 + cost);
                   end
               elseif (~isInitiated(j) & (~isConsumed(j)))  % Uninitiated inclusions are removed if consumed by a cluster
                   rij = sqrt((clusterCell{i,2} - clusterCell{j,2})^2 + (clusterCell{i,3} - clusterCell{j,3})^2);
                   r0 = (clusterCell{i,4} + clusterCell{i,5})*0.5;
                   if (rij < r0)
                       isConsumed(j) = 1;
                       totalConsumed = totalConsumed + 1;
                       clusterCell{j,1} = -3; % Consumed index
                   end
               elseif ( isInitiated(j) & (~isConsumed(j))) % Initiated but repassivated inclusion, which is consumed
                   rij = sqrt((clusterCell{i,2} - clusterCell{j,2})^2 + (clusterCell{i,3} - clusterCell{j,3})^2);
                   r0 = (clusterCell{i,4} + clusterCell{i,5})*0.5;
                   if (rij < r0)
                       isConsumed(j) = 1;
                       %totalConsumed = totalConsumed + 1;
                       clusterCell{j,1} = -3; % Consumed index
                   end
               end
                   
           end 
           end
        end
        clusterCell{i,9} = 0; % Reset for checking next iteration
    end
    
    pitCounts.inits(timestepcount) = sum(isInitiated);
    pitCounts.growth(timestepcount) = totalGrowing;
    pitCounts.mergers(timestepcount) = totalMergers;
    pitCounts.repassive(timestepcount) = totalRepassive;
    pitCounts.consumed(timestepcount) = totalConsumed;
    pitCounts.failedInitiations(timestepcount) = totalFailedInitiations;
    
    %fprintf('Time %d\n',timestepcount);
    if (dimList.depthList{timestepcount})
        dimList.maxDepth(timestepcount) = max(dimList.depthList{timestepcount});
    end
    if (dimList.widthList{timestepcount})
        dimList.maxWidth(timestepcount) = max(dimList.widthList{timestepcount});
    end

    if (timer(timestepcount) == saveTimes(saveIndex))
        pitCell{saveIndex} = pitCounts;
        dimCell{saveIndex} = dimList;
        clustCell{saveIndex} = clusterCell;
        saveIndex = saveIndex + 1;
    end

    
%     if (mod(timestepcount,saveFreq) == 0)
%         saveFilePath = strcat(outPath,'\',outPrefix,'_',num2str(timestepcount),'.xlsx');
%         saveGalvano(clusterCell,saveFilePath,Ni,isInitiated);
%     end
        
end
end

%% Function 
function saveGalvano(c,fPath,Ni,isInitiated)

h = height(c);
w = width(c);

nz = cell(h,w+2); % Two extra columns for size of clusters and inclusion indices 

for i = 1:1:h
    s1 = max(size(c{i,1})); 
    nz{i,w+1} = s1;
    nz{i,w+2} = isInitiated(i);
    if ( s1 > 1)
        nz{i,1} = Ni+1;    
    else
        nz{i,1} = c{i,1};
    end    
end

nz(:,2:w) = c(:,2:end);

writecell(nz,fPath);
end

