function [rtd, x, timeCell] = repass_time_distri(c)

s = max(size(c));

timeCell = zeros(s,1);
ind = 0;

for i = 1:1:s
    if (((c{i,1} == -2 ) | (c{i,1} == -3)) & (c{i,11}))
        ind = ind+1;
        timeCell(ind) = c{i,11};
    end
end

timeCell = timeCell(1:ind);
nbins = floor(sqrt(ind));
[rtd,x] = hist(timeCell,nbins);
