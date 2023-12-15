%galvano_utilities

%% This function estimates the minimum current required for single pits to grow (conc at pit bottom must be greater than 2.8M)
% It is seen that the C at pit bottom increases linearly with applied
% current, so a linear fit is done to estimate the min current

function initCurrents = get_init_currents(initFile)

stdVals = readmatrix(initFile);

% sort the matrix by radius, angles and concentrations at pit bottom
stdVals_sorted = sortrows(stdVals,[2 3 5]);

s = max(size(stdVals_sorted));

% unique radii
rads = unique(stdVals_sorted(:,2));
% unique angles
angles = unique(stdVals_sorted(:,3));

numRads = max(size(rads));
numAngles = max(size(angles));

% final data structure
initCurrents = zeros(numRads*numAngles,3);

ind = 0;

% loop over unique radii
for i = 1:1:numRads
    % loop over unique angles
    for j = 1:1:numAngles
        ind = ind + 1;
        initCurrents(ind,1) = rads(i);
        initCurrents(ind,2) = angles(j);
        % Currents and concentrations for current radius and angle
        i1 = stdVals_sorted((stdVals_sorted(:,2) == rads(i)) & (stdVals_sorted(:,3) == angles(j)),4);
        c1 = stdVals_sorted((stdVals_sorted(:,2) == rads(i)) & (stdVals_sorted(:,3) == angles(j)),5);
        %p = polyfit(i1,c1,1);
        p = polyfit(log10(i1),log10(c1),1);
        % Linearly determined current for conc = 2800
        %initCurrents(ind,3) = (2800 - p(2))/p(1);
        %Logarithmic
        initCurrents(ind,3) = 10^((log10(2800) - p(2))/p(1));
    end
end

% Convert to radians
initCurrents(:,2) = initCurrents(:,2)*(180/pi);
        
        
    
