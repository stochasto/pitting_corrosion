%clear;

function [isFail] = Pit_Propagation(E)
parameters;

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

%Collated Pit Geometry description
r=[r_surf; r_subSurf];  
cosTheta=[cosTheta_surf; cosd(theta_cone)*ones(size(r_subSurf,1),1)];  
d=[zeros(size(r_surf,1),1); d_subSurf]; 

%Critical Potentials
Em=0.3628-0.1274.*log(r)-0.3525.*log(1+cosTheta)+0.0352.*log(1-cosTheta)-0.1603.*log(1+d./r./cosTheta);
Es=0.3679-0.1310*log(r)-0.4617*log(1+cosTheta)-0.0156*log(1-cosTheta)-0.1617.*log(1+d./r./cosTheta);

% Plot histograms of potential
% figure;
% hist(Em,100);
% t = strcat('Em for theta cone ',num2str(theta_cone));
% title(t);
% 
% figure;
% hist(Es,100);
% t = strcat('Es for theta cone ',num2str(theta_cone));
% title(t);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Stable_Pits = cell(1,1);
MetaStable_Pits = cell(1,1);
Non_initiated_Pits = cell(1,1);


%Number of Nucleation sites
n_nucleation=poissrnd(A*nu_n);
timestepcount=0; timesteps=100;
t_nucleation = zeros(Ni,1);
nucleation_at_inclusion=zeros(timesteps,Ni);
n_nucleation_instant=0; n_nucleation_remaining=n_nucleation;

inclusions_remaining = Ni;
isNucleated = zeros(Ni,1); % Indicator to show if a given inclusion is nucleated

for time=0:1e-3:1e-2
    timestepcount=timestepcount+1;
    q=1-exp(-gam*time);
    n_nucleation_remaining=n_nucleation_remaining-n_nucleation_instant;
    n_nucleation_instant=binornd(n_nucleation_remaining,q);
    n_nucleation_instant_inclusions = binornd(n_nucleation_instant,alpha_i);
    
    Area_Inclusions=pi*r.^2.*(1-cosTheta.^2);
    
    inclusions_nucleated = 0;
    for i=1:Ni
        if (~isNucleated(i) && (n_nucleation_instant_inclusions > 0))
            nucleation_at_inclusion(timestepcount,i)= ceil( n_nucleation_instant_inclusions*Area_Inclusions(i)/sum(Area_Inclusions));
            isNucleated(i) = 1;
            j = nucleation_at_inclusion(timestepcount,i);
            if (j > 0)
                iTimes = zeros(j,1);
                % Draw j times for the i'th inclusion. Times have to be
                % sampled from gam(1 - q(x))/q(timestepcount). The cdf
                % works out to be: F(t) = (1 -
                % exp(-gam*t))/(q(timestepcount)). Equating this to a
                % uniform random gives the time as: t = (-1/gam)*log(1 -
                % u*q(timestepcount))
                u = rand(j,1);
                iTimes = (-1/gam)*log(1 - u*q);
                t_nucleation(i) = min(iTimes);
            end
        end
    end  
end

mscount=0; noncount=0; scount=0;
for i=1:Ni
%     try
%       t_nucleation(i)=find(nucleation_at_inclusion(:,i),1,'first'); 
%     catch
%       t_nucleation(i)=NaN;
%     end
    if (isNucleated(i))
        if strcmp(expType,'potentiostatic')
            if(E>Es(i))
                scount=scount+1;
                %Stable_Pits(scount,1:3)=[i t_nucleation(i) Es(i)];
                Stable_Pits{scount}=[i t_nucleation(i) Es(i)];
            elseif((E>Em(i))&&(E<Es(i)))
                mscount=mscount+1;
                %MetaStable_Pits(mscount,1:3)=[i t_nucleation(i) Em(i)];
                MetaStable_Pits{mscount} = [i t_nucleation(i) Em(i)];
            else
                noncount=noncount+1;
                %Non_initiated_Pits(noncount,1:3)=[i t_nucleation(i) Em(i)];
                Non_initiated_Pits{noncount} = [i t_nucleation(i) Em(i)];
            end
        else
            eTime = E((find(E(:,1) >= t_nucleation(i),'first')),2);
            if(eTime>=Es(i))
                scount=scount+1;
                %Stable_Pits(scount,1:3)=[i t_nucleation(i) Es(i)];
                Stable_Pits{scount}=[i t_nucleation(i) Es(i)];
            elseif((eTime>=Em(i))&&(eTime<Es(i)))
                mscount=mscount+1;
                %MetaStable_Pits(mscount,1:3)=[i t_nucleation(i) Em(i)];
                MetaStable_Pits{mscount} = [i t_nucleation(i) Em(i)];
            else
                noncount=noncount+1;
                %Non_initiated_Pits(noncount,1:3)=[i t_nucleation(i) Em(i)];
                Non_initiated_Pits{noncount} = [i t_nucleation(i) Em(i)];
            end
        end
     end         
end

Result=[t_nucleation Em Es];

%pFail = max(size(Stable_Pits))/Ni;

if (scount > 0)
    isCount = 1;
end

%sprintf('pFail is: %f',pFail)
sprintf('Min Es: %f',min(Es(:)))
sprintf('Number of inclusions: %d',Ni)
sprintf('Number of metastable pits: %d',max(size(MetaStable_Pits)))
sprintf('Number of non-initiated pits: %d',max(size(Non_initiated_Pits)))
sprintf('Number of stable pits: %d',max(size(Stable_Pits)))
sprintf('isFail is ',isFail);
        



    



