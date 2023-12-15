function plot_galvano_mat(fName)

c = readmatrix(fName);
s = max(size(c));

for i = 1:1:s
    if ( max(c(i,1)) > 0 )
        if (c(i,8))
            col = 'r'; % Growing
            %fprintf('Here %d\n',i)
            %circle(c{i,2},c{i,3},0.5*c{i,4},col)
            %hold on
        else
            col = 'b'; % Uninitiated
        end    
    elseif (c(i,1) == -2)
        col = 'y'; % Repassivated
    elseif (c(i,1) == -3)
        col = 'k'; % Consumed, could have been initiated and then repassivated, or uninitiated
    end
    circle(c(i,2),c(i,3),0.5*c(i,4),col);
    hold on
end

function h = circle(x,y,r,col)
%hold on
th = 0:pi/50:2*pi;
xunit = r * cos(th) + x;
yunit = r * sin(th) + y;
h = plot(xunit, yunit, col);