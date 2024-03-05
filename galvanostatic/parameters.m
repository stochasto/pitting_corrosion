% Parameters for the Corr Sci Special issue paper

gridType = 'uniform';
%gridType = 'random';

% Uniform grid
gridGap = 2.4e-5;
gridSize = 50;
A = (gridSize*gridGap)^2;

% Lognormal parameters 
mu_log = -1.1239;
sigma_log = 0.7760;

%alpha_i = 0.000445;
%alpha_i = 0.000445 * 1e+4;
alpha_i = 0.08;
nu_i = 1.9e+4 * 1e+4; % m^(-2)
nu_n = 7e+7 * 1e+4;

%nu_i = 100 * 1e+4; % m^(-2)
%nu_n = 1e+7 * 1e+4;

gam = 0.0007;
%gam = 7e-5;
%A = 1.0 * 1e-4;
%A = 170e-8;


Hmax = 4; %In Micrometers
%Hmax = 1.26; %In Micrometers
theta_cone = 5;

radiusCheck = 3e-5;

rUniformMax = 1e-5;

%E=0.1;