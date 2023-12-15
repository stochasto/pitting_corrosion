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
        p = polyfit(i1,c1,1);
        % Linearly determined current for conc = 2800
        initCurrents(ind,3) = (2800 - p(2))/p(1);
    end
end

% Convert to radians
initCurrents(:,2) = initCurrents(:,2)*(180/pi);

end


%% This function returns the linear coefficients for a given radius in initCurrents
function rLinTheta = get_linear_theta_current(initCurrents)

rads = unique(initCurrents(:,1));
rads = sortrows(rads);

numRads = max(size(rads));

% rLinTheta gives the linear relationship between angle theta and min
% current for each given r. First column is radius, second and third
% columns are slope and intercept of the linear equation
rLinTheta = zeros(numRads,3);

rLinTheta(:,1) = rads;

for i = 1:1:numRads
    x1 = initCurrents(initCurrents(:,1) == rads(i),:);
    p = polyfit(x1(:,2),x1(:,3));
    rLinTheta(i,2) = p(1);
    rLinTheta(i,3) = p(2);
end

end

%% This function allocates single current to a growing cluster
function minCurrent = allocate_single_current(c1,i1,B)

r1 = 0.5*c1{i1,4};
theta1 = c1{i1,10};

% For single pit, until better data is available, we will consider the minimum pair current with radius 2e-6.
sub1 = B(B(:,1) == 2e-6,:);
rads = unique(sub1(:,3));
% Of these radii, choose the one closest to r1
[c ind] = min(abs(rads - r1));

% rads(ind) is the radius in B that we is closest to r1, this is chosen
sub2 = sub1(sub1(:,3) == rads(ind),:);

% So far radii are chosen. Now angles must be chosen.
% It is possible that multiple angles for the first radius of 2e-6 are chosen. If so, then choose the
% rows with maximum angle for 2e-6

ang2 = unique(sub2(:,2));
if (height(ang2) > 1) % If there are multiple angles for 2e-6, choose the max
    sub2 = sub2( (sub2(:,2) == max(ang2)),:);
end

% sub2 now has only one angle for 2e-6, the max angle. Say if 2e-6 had 15, 30 and 75 angles, now only rows with 75
% degree angle will be present. If there are multiple rows, it means that there are multiple angles for the second
% target pit, corresponding to r1. We must choose the angle closest to theta1.
if (height(sub2) > 1) 
    ang3 = unique(sub2(:,4));
    [c ind] = min(abs(ang3 - theta1));
    minCurrent = sub2((sub2(:,4) == ang3(ind)),5);
else
    minCurrent = sub2(1,5);
end

end

%% 

function minCurrent = allocate_pair_current(c1,i1,i2,B)

r1 = 0.5*c1{i1,4};
theta1 = c1{i1,10};

r2 = 0.5*c1{i2,4};
theta2 = c1{i2,10};

theta = [theta1 theta2];

[rMin indMin] = min([r1 r2]);
[rMax indMax] = max([r1 r2]);

% Check for values closest to rMin in first column

rads1 = unique(B(:,1));
% Of these radii, choose the one closest to rMin
[c ind] = min(abs(rads1 - rMin));
B = B( B(:,1) == rads1(ind),:);

rads2 = unique(B(:,3));
% Of these radii, choose the one closest to rMax
[c ind] = min(abs(rads2 - rMax));
B = B( B(:,3) == rads2(ind),:);

% Choose angles. First try choosing theta1 and then theta2. Then try theta2 first then theta1. Measure the deviation in
% each method. Choose the method with the least deviation.

% Theta1 first
ang1 = unique(B(:,2));
[dev1 ind] = min(abs(ang1 - theta(indMin)));
sub1 = B( B(:,2) == ang1(ind),:);
ang2 = unique(sub1(:,4));
[dev2 ind] = min(abs(ang2 - theta(indMax)));
subFinal_1 = sub1( sub1(:,4) == ang2(ind),:);

devMethod1 = dev1 + dev2;

% Theta2 first
ang1 = unique(B(:,4));
[dev1 ind] = min(abs(ang1 - theta(indMax)));
sub2 = B( B(:,4) == ang1(ind),:);
ang2 = unique(sub2(:,2));
[dev2 ind] = min(abs(ang2 - theta(indMin)));
subFinal_2 = sub2( sub2(:,2) == ang2(ind),:);

devMethod2 = dev1 + dev2;

if (devMethod1 < devMethod2)
    minCurrent = subFinal_1(1,5);
else
    minCurrent = subFinal_2(1,5);
end

end

%% Function to get width and depth growth rates for a single pit

function [wSlopeWithI, wIntercept, dSlopeWithI, dIntercept] = get_single_rates(c1,i1,A)

r1 = 0.5*c1{i1,4};
theta1 = c1{i1,10};

% For single pit, until better data is available, we will consider the minimum pair current with radius 2e-6.
sub1 = A(A(:,1) == 2e-6,:);
rads = unique(sub1(:,3));
% Of these radii, choose the one closest to r1
[c ind] = min(abs(rads - r1));

% rads(ind) is the radius in A that is closest to r1, this is chosen
sub2 = sub1(sub1(:,3) == rads(ind),:);

%Now, 2e-6 and r1 closest radii are present. There are multiple angles corresponding to both 2e-6 and r1. Here, we
%choose the angle closest to theta1 in sub2.

ang2 = unique(sub2(:,4));
% Of these angles, choose the one closest to theta1
[c ind] = min(abs(ang2 - theta1));

sub2 = sub2(sub2(:,4) == ang2(ind),:);

ang3 = unique(sub2(:,2));
if (height(ang3) > 1)
    sub2 = sub2( (sub2(:,2) == max(ang3)),:);
end

% Now sub2 has 2e-6, r1 and only one angle for 2e-6 and theta1
if (height(sub2) > 1)
    iApply = sub2(:,5);
    w = sub2(:,6);
    d = sub2(:,8);
    pWidth = polyfit(iApply,w,1);
    pDepth = polyfit(iApply,d,1);
    wSlopeWithI = pWidth(1);
    wIntercept = pWidth(2);
    dSlopeWithI = pDepth(1);
    dIntercept = pDepth(2);
else
    wSlopeWithI = 0;
    wIntercept = sub2(1,6);
    dSlopeWithI = 0;
    dIntercept = sub2(1,8);
end

end
    
%% Function to get width and depth growth rates for a pair of pits

function [wSlopeWithI, wIntercept, dSlopeWithI, dIntercept] = get_pair_rates(c1,i1,i2,A)

r1 = 0.5*c1{i1,4};
theta1 = c1{i1,10};

r2 = 0.5*c1{i2,4};
theta2 = c1{i2,10};

theta = [theta1 theta2];

[rMin indMin] = min([r1 r2]);
[rMax indMax] = max([r1 r2]);

% Check for values closest to rMin in first column

rads1 = unique(A(:,1));
% Of these radii, choose the one closest to rMin
[c ind] = min(abs(rads1 - rMin));
A = A( A(:,1) == rads1(ind),:);

rads2 = unique(A(:,3));
% Of these radii, choose the one closest to rMax
[c ind] = min(abs(rads2 - rMax));
A = A( A(:,3) == rads2(ind),:);

% Choose angles. First try choosing theta1 and then theta2. Then try theta2 first then theta1. Measure the deviation in
% each method. Choose the method with the least deviation.

% Theta1 first
ang1 = unique(A(:,2));
[dev1 ind] = min(abs(ang1 - theta(indMin)));
sub1 = A( A(:,2) == ang1(ind),:);
ang2 = unique(sub1(:,4));
[dev2 ind] = min(abs(ang2 - theta(indMax)));
subFinal_1 = sub1( sub1(:,4) == ang2(ind),:);

devMethod1 = dev1 + dev2;

% Theta2 first
ang1 = unique(A(:,4));
[dev1 ind] = min(abs(ang1 - theta(indMax)));
sub2 = A( A(:,4) == ang1(ind),:);
ang2 = unique(sub2(:,2));
[dev2 ind] = min(abs(ang2 - theta(indMin)));
subFinal_2 = sub2( sub2(:,2) == ang2(ind),:);

devMethod2 = dev1 + dev2;

if (devMethod1 < devMethod2)
    subFinal = subFinal_1;
else
    subFinal = subFinal_2;
end

if (height(subFinal) > 1)
    iApply = subFinal(:,5);
    w = subFinal(:,6);
    d = subFinal(:,8);
    pWidth = polyfit(iApply,w,1);
    pDepth = polyfit(iApply,d,1);
    wSlopeWithI = pWidth(1);
    wIntercept = pWidth(2);
    dSlopeWithI = pDepth(1);
    dIntercept = pDepth(2);
else
    wSlopeWithI = 0;
    wIntercept = subFinal(1,6);
    dSlopeWithI = 0;
    dIntercept = subFinal(1,8);
end

end
    
    
    
        
        
    
