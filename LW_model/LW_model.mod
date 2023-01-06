%----------------------------------------------------------------
% 1. Model variables and parameters
%----------------------------------------------------------------
var		ygap
        ym
        ytrend
        real
        rstar
        pi
        ygpot
        z;


varexo	e_ygap
        e_pi
        e_rstar
        e_ytrend
        e_ygpot;

parameters
        a1
        a2
        b1
        b2
        gpot_ss
        c
        z1
        sig_e_ygap sig_e_pi sig_e_rstar sig_e_ytrend sig_e_e_ygpot;


%----------------------------------------------------------------
% 2. Calibration
%----------------------------------------------------------------
% Calibration of all of the parameters of the model. This is done to
% initialize the estimation, or simlate the model using these parameters.

% Parameters.
a1		 = 0.5;
a2		 = 0.5;
b1       = 0.5;
b2       = 0.5;
c        = 0.9;
z1       = 0.9;
gpot_ss  =  0.0063;

% Std of shocks.
sig_e_ygap   =  1;
sig_e_pi     =  1;
sig_e_rstar  =  1;
sig_e_ytrend =  0.23;
sig_e_ygpot  =  0;


%----------------------------------------------------------------
% 3. Model
%----------------------------------------------------------------
% Linear defines that the model is linear.
model(linear);
ygap   = ym - ytrend;

ygap   = a1*ygap(-1) + (1-a1)*ygap(-2) + a2*(real(-1) - rstar(-1)) + e_ygap;

pi     = b1*pi(-1)   + (1-b1)*pi(-2)   + b2*ygap(-1) + e_pi;

rstar  = c*ygpot + z;

z      = z1*z(-1) + e_rstar;

ytrend = ytrend(-1) + ygpot(-1) + e_ytrend;

ygpot  = ygpot(-1)  + e_ygpot;

end;

steady_state_model;
ytrend  = 10;
ym      = 10;
ygpot   = gpot_ss;
ygap    = 0;
real    = 0.01;
rstar   = 0.001;
pi      = 0.003;
z       = 0;
end;

% Don’t check the steady state values when they are provided explicitly either 
% by a steady state file or a steady_state_model block. This is useful for 
% models with unit roots as, in this case, the steady state is not unique or 
% doesn’t exist
steady(nocheck);
 
% No initval for parameters because model has unit root.
%  initval;
%  end;

% Computes the eigenvalues of the model linearized around the values specified 
% by the last initval, endval or steady statement. Generally, the eigenvalues 
% are only meaningful if the linearization is done around a steady state of 
% the model. It is a device for local analysis in the neighborhood of this 
% steady state.
% check; 

% Defining shocks of the model, by seting up their variances.
shocks;
var e_ygap    = sig_e_ygap^2;
var e_pi      = sig_e_pi^2;
var e_rstar   = sig_e_rstar^2;
var e_ytrend  = sig_e_ytrend^2;
var e_ygpot   = sig_e_ygpot^2;
end;


%----------------------------------------------------------------
% 4. Estimated parameters and data
%----------------------------------------------------------------
% Define the prior distribution of the parameters.
% Check https://kevinkotze.github.io/mm-tut5-estim/ for info on priors.

% normal_pdf,    mu, sg              Range: R
% gamma_pdf,     mu, sg, lb          Range: [lb,+00]*
% beta_pdf,    , mu, sg, lb, ub      Range: [lb,ub]
% inv_gamma_pdf, mu, sg              Range: R+
% uniform_pdf,   [], []  lb, ub      Range: [lb,ub]

estimated_params;
% Parameters
a1,  beta_pdf, 0.85, 0.075, 0;
a2,  beta_pdf, 0.85, 0.075, 0;
b1,  beta_pdf, 0.85, 0.075, 0;
b2,  beta_pdf, 0.85, 0.075, 0;
c,   beta_pdf, 0.85, 0.075, 0;
z1,  beta_pdf, 0.85, 0.075, 0;

% Shocks.
stderr e_ygap,    inv_gamma_pdf, 0.5, inf;
stderr e_pi,      inv_gamma_pdf, 0.5, inf;
stderr e_rstar,   inv_gamma_pdf, 0.5, inf;
stderr e_ytrend,  inv_gamma_pdf, 0.5, inf;
stderr e_ygpot,   inv_gamma_pdf, 0.5, inf;
end;

% Declare what variables are observed by the model.
varobs ym real pi;

%----------------------------------------------------------------
% 5. Bayesian estimation and forecasting
%----------------------------------------------------------------
options_.console_mode=1; %(default: 0)

estimation(datafile = data_load, graph_format = pdf, nodiagnostic, diffuse_filter, 
        mh_drop=.5,  mh_jscale=0.2,mh_replic = 0, mh_nblocks = 5, 
        filtered_vars, smoother,mode_compute = 4, plot_priors = 1,forecast = 0) ytrend ygap;

%----------------------------------------------------------------
% 6. Reporting
%----------------------------------------------------------------

verbatim;

lw_data;
% smoothed
eval(['trend_ 	= oo_.SmoothedVariables.ytrend' ';']);
eval(['cycle_ 	= oo_.SmoothedVariables.ygap' ';']);

figure(20)
plot(ym,'black')
hold on;
plot(ytrend_,'red')
hold off;
figure(30)
plot(ygap_)

end;