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
    p = polyfit(x1(:,2),x1(:,3),1);
    rLinTheta(i,2) = p(1);
    rLinTheta(i,3) = p(2);
end

end