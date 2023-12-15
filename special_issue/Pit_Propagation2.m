%clear;

function [isFail, Eb] = Pit_Propagation2(E,numTimes,finalTime)
parameters;

Eb = NaN;

sE = max(size(E));
isFail = 0;

if (sE > 1)
    expType = 'potentiodynamic';
else
    expType = 'potentiostatic';
end

%Geometry of the pits
[Na,Nc,r_surf,cosTheta_surf,r_subSurf,d_subSurf]=getGeom(Hmax, theta_cone);
Ni=Na+Nc;
sprintf('Number of Inclusions: %d',Ni)

%Collated Pit Geometry description
r=[r_surf; r_subSurf];  
cosTheta=[cosTheta_surf; cosd(theta_cone)*ones(size(r_subSurf,1),1)];  
d=[zeros(size(r_surf,1),1); d_subSurf]; 
Area_Inclusions=pi*r.^2.*(1-cosTheta.^2);

total_inclusions_area = sum(Area_Inclusions)

%figure
%hist(Area_Inclusions,sqrt(Ni));

%Critical Potentials
Em=0.3628-0.1274.*log(r)-0.3525.*log(1+cosTheta)+0.0352.*log(1-cosTheta)-0.1603.*log(1+d./r./cosTheta);
Es=0.3679-0.1310*log(r)-0.4617*log(1+cosTheta)-0.0156*log(1-cosTheta)-0.1617.*log(1+d./r./cosTheta);
    
% Plot histograms of potential
% figure;
% hist(Em,100);
% t = strcat('Em for theta cone ',num2str(theta_cone));
% title(t);
sprintf('Min and Max Em are %f and %f',min(Em),max(Em))

% figure;
% hist(Es,100);
% t = strcat('Es for theta cone ',num2str(theta_cone));
% title(t);
sprintf('Min and Max Es are %f and %f',min(Es),max(Es))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Stable_Pits = cell(1,1);
MetaStable_Pits = cell(1,2);
Non_initiated_Pits = cell(1,1);

% Create timestep array
%numTimes = 101;
%timer = zeros(numTimes,1);
%finalTime = 1000;
timestep = finalTime/(numTimes - 1);
timer = 0:timestep:finalTime;
timesteps = max(size(timer));

% Debugging
% nRemain = zeros(timesteps,1);
% qt = zeros(timesteps,1);
% nPresent = zeros(timesteps,1);


%Number of Nucleation sites
n_nucleation=poissrnd(A*nu_n)
timestepcount=0; %timesteps=100;
t_nucleation = zeros(Ni,1);
nucleation_at_inclusion=zeros(timesteps,Ni);
n_nucleation_instant=0; n_nucleation_remaining=n_nucleation;
nucleation_count = zeros(timesteps,1);

inclusions_remaining = Ni;
isInitiated = zeros(Ni,1); % Indicator to show if a given inclusion is initiated
initiated_inclusions_area = 0;
inclusions_area = total_inclusions_area; % Initially all inclusions are available

%Debug
% nRemain(1) = n_nucleation;
% qt(1) = 0;
% nPresent(1) = 0;

n_nucleation_prev = 0;

% fid = fopen('jfile101_20s.txt','w+');

for timestepcount=2:1:timesteps
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
    
    for i=1:Ni
        if ((~isInitiated(i)) && (n_nucleation_instant_inclusions > 0))
            z = n_nucleation_instant_inclusions*Area_Inclusions(i)/inclusions_area;
            %z = n_nucleation_instant_inclusions*Area_Inclusions(i)/total_inclusions_area;
            nucleation_at_inclusion(timestepcount,i)= round(z);
            j = nucleation_at_inclusion(timestepcount,i);
%             if (timer(timestepcount) == 20)
%                 j;
%                 fprintf(fid,'%d %f %d\n',i,Area_Inclusions(i),j);
%             end
            if (j > 0)
                iTimes = zeros(j,1);
                % Draw j times for the i'th inclusion. Times have to be
                % sampled from gam(1 - q(x))/q(timestepcount). The cdf
                % works out to be: F(t) = (1 -
                % exp(-gam*t))/(q(timestepcount)). Equating this to a
                % uniform random gives the time as: t = (-1/gam)*log(1 -
                % u*q(timestepcount))
                % However, withing time interval t1 to t2, we have to
                % sample from the truncated distribution between t1 and t2,
                % whose CDF is given by (F(t) - F(t1))/(F(t2) - F(t1)).
                % Equating this to u gives: t = (-1/gam)*log(
                % (1-u)exp(-gam*t1) + u*exp(-gam*t2))
                u = rand(j,1);
                %iTimes(1) = (-1/gam)*log(1 - u*q);
                iTimes = (-1/gam)*log( (1 - u)*exp(-gam*timer(timestepcount - 1)) + u*exp(-gam*timer(timestepcount)));
                t_nucleation(i) = min(iTimes);
%                 if (timestepcount == 10)
%                     t_nucleation(i)
%                 end
                    
                if strcmp(expType,'potentiostatic')
                    if(E>=Es(i))
                        isFail = 1;
                        %Eb = Es(i);
                        Eb = E;
                        %sprintf('Sample fails')
                        sum(isInitiated);
                        return
                    elseif ((E>=Em(i))&& (E < Es(i)))
                        isInitiated(i) = 1;
                        initiated_inclusions_area = initiated_inclusions_area + Area_Inclusions(i);
                    end
                else
                    eTime = E((find(E(:,1) >= t_nucleation(i),1,'first')),2);
                        if(eTime>=Es(i))
                            isFail = 1;
                            %Eb = Es(i);
                            Eb = eTime;
                            return
                        elseif ((eTime>=Em(i))&& (eTime < Es(i)))
                            isInitiated(i) = 1;
                            initiated_inclusions_area = initiated_inclusions_area + Area_Inclusions(i);
                        end
                end
            end    
        end
    end
    MetaStable_Pits{1,1}(timestepcount) = timer(timestepcount);
    %MetaStable_Pits{1,2}(timestepcount) = sum(isInitiated);
    MetaStable_Pits{1,2}(timestepcount) = max(size(find(isInitiated)));
end
% fclose(fid);
if (strcmp(expType,'potentiostatic'))
figure
plot(MetaStable_Pits{1,1},MetaStable_Pits{1,2})
%sum(isInitiated)

figure
plot(MetaStable_Pits{1,1},cumsum(nucleation_count))

% Debug
% figure
% plot(timer,qt)
% figure
% plot(timer,nRemain) % Nucleation sites remaining
% figure
% plot(timer,nPresent) % Nucleations in present time step
% figure
% plot(timer,nucleation_count) % Nucleations at inclusions in present step
end


%                 %%%% Alternate time
%                 timestepcount
%                 excludeTime = (timestepcount - 2)*1000;
%                 iTimes
%                 iTimes(find(iTimes >= excludeTime,1,'first'));
%                 t_nucleation(i) = iTimes(find(iTimes >= excludeTime,1,'first'));
% for jNuc = 1:1:j
%                     while (iTimes(jNuc) < time)
%                          u = rand(1,1);
%                          iTimes(jNuc) = (-1/gam)*log(1 - u*q);
%                     end
%                 end
        



    



