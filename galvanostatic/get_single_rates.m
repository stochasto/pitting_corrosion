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