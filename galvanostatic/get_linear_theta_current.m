%% This function returns the linear coefficients for a given radius in initCurrents. The first column of initCurrents is radius, second is angle theta 
%% in degrees, third is minimum current for a given r,theta combination. Each radius has four angles of 15, 30, 45 and 60 degrees.
%% Function also returns rLinCD, which gives theta coefficients for min current density
function [rLinTheta rLinCD] = get_linear_theta_current(initCurrents)

rads = unique(initCurrents(:,1));
rads = sortrows(rads);

numRads = max(size(rads));

% rLinTheta gives the linear relationship between angle theta and min
% current for each given r. First column is radius, second and third
% columns are slope and intercept of the linear equation
rLinTheta = zeros(numRads,3);
rLinCD = zeros(numRads,3);

rLinTheta(:,1) = rads;
rLinCD(:,1) = rads;

%% compute minimum current densities
initCurrents = [initCurrents zeros(max(size(initCurrents)),1)];
ar = 2*pi*(initCurrents(:,1).^2).*(1 + cosd(initCurrents(:,2)));
initCurrents(:,4) = initCurrents(:,3)./ar;

for i = 1:1:numRads
    % First choose part of initCurrents for the i'th unique radius
    x1 = initCurrents(initCurrents(:,1) == rads(i),:);
    %x2 = initCurrents(initCurrents(:,1) == rads(i),:);
    % Fit current vs theta for this r with a linear equation
    p = polyfit(x1(:,2),x1(:,3),1);
    rLinTheta(i,2) = p(1);
    rLinTheta(i,3) = p(2);

    % Fit current vs theta for this r with a linear equation
    p2 = polyfit(x1(:,2),x1(:,4),1);
    rLinCD(i,2) = p2(1);
    rLinCD(i,3) = p2(2);


end

end