% Function to get width and depth growth rates for a pair of pits

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
    