function [N_a,r_surf,theta_surf] = getGeom()

parameters;

nu_s = 3*alpha_i/(4*pi*exp(3*mu_log + 4.5*sigma_log^2));

% Mean r
r_mean = exp(mu_log + 0.5*sigma_log^2);

% Width of rough layer
w = Hmax - r_mean * (normcdf((log(Hmax) - mu_log  - sigma_log^2)/sigma_log)/normcdf((log(Hmax) - mu_log)/sigma_log));

% Number of inclusions N_i
N_i = poissrnd(A*nu_i);

% Number of cones
N_c = binornd(N_i,w/(w + 2*r_mean));

% Number of surface inclusions
N_a = N_i - N_c;

% Sizes of surface inclusions
r_surf = zeros(N_a,1);
theta_surf = zeros(N_a,1);

% Allocate surface sizes
u = rand(N_a,1);
r_surf = exp(mu_log + sigma_log^2 + sigma_log*norminv(u));
% Sample theta between -1 and 1. If we are sampling from a uniform random
% distribution in the range (a,b), the variate is: x = a + u*(b - a); In
% the case of cosTheta_surf, (a,b) = (-1,1); 
%cosTheta_surf = -1 + 2*rand(N_a,1);

% Sample angles between 5 and 85 degrees
theta_surf = 5 + 80*rand(N_a,1);










    

