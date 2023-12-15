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
    %fprintf('n allocate, %f\n',minCurrent);
else
    minCurrent = sub2(1,5);
    %fprintf('n allocate, %f\n',minCurrent);
end

end