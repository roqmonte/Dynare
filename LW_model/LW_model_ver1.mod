%----------------------------------------------------------------
% 1. Model variables and parameters
%----------------------------------------------------------------
var		ygap
        ym
        ytrend
        ygpot;

varexo	e_irr
        e_ygap
        e_ytrend
        e_ygpot;

parameters
        a1
        a2
        rho
        gpot_ss
        sig_e_irr sig_e_ygap sig_e_ytrend sig_e_ygpot;


%----------------------------------------------------------------
% 2. Calibration
%----------------------------------------------------------------
% Calibration of all of the parameters of the model. This is done to
% initialize the estimation, or simlate the model using these parameters.

% Parameters.
rho		= 0;
a1		 = 1.100;
a2		 = -0.300;
gpot_ss  = 0.025/4;

% Std of shocks.
sig_e_irr    =  0.003;
sig_e_ytrend =  0.23;
sig_e_ygpot  =  0;
sig_e_ygap   =  1;

%----------------------------------------------------------------
% 3. Model
%----------------------------------------------------------------
% Linear defines that the model is linear.
model(linear);
ytrend = ytrend(-1) + ygpot(-1) + e_ytrend/1000;

ygpot  = rho*ygpot(-1) + (1-rho)*gpot_ss + e_ygpot/100;

ygap   = a1*ygap(-1) + (1-a1)*ygap(-2) + e_ygap;

ygap   = ym - ytrend + e_irr;

end;

steady_state_model;
ytrend  = 10.3;
ym      = 10.3;
ygpot   = gpot_ss;
ygap    = 0;
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
var e_irr     = sig_e_irr^2;
var e_ytrend  = sig_e_ytrend^2;
var e_ygpot   = sig_e_ygpot^2;
var e_ygap    = sig_e_ygap^2;
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
rho,  0.9359, beta_pdf, 0.85, 0.075;
a1,	  0.2,	  beta_pdf, 0.2, 0.075;
a2,	  0.2,	  beta_pdf, 0.2, 0.075;
%a1,  beta_pdf, 0.85, 0.075, 0;
%a2,  beta_pdf, 0.85, 0.075, 0;

% Shocks.
stderr e_irr, .38, inv_gamma_pdf,  0.5, inf;
stderr e_ytrend,  .5, inv_gamma_pdf, 0.5, inf;
stderr e_ygpot,   .5, inv_gamma_pdf, 0.5, inf;
stderr e_ygap,    .5, inv_gamma_pdf, 0.5, inf;
end;

% Declare what variables are observed by the model.
varobs ym;

%----------------------------------------------------------------
% 5. Bayesian estimation and forecasting
%----------------------------------------------------------------
options_.console_mode=1; %(default: 0)

estimation(datafile = data_load, graph_format = pdf, nodiagnostic, diffuse_filter, 
        mh_drop=.5,  mh_jscale=0.2,mh_replic = 0, mh_nblocks = 0,
        filtered_vars, smoother,mode_compute = 4, plot_priors = 1,forecast = 0) ytrend ygap;

%----------------------------------------------------------------
% 6. Reporting
%----------------------------------------------------------------

verbatim;

load lw_data;
% smoothed
eval(['ytrend_ 	= oo_.SmoothedVariables.ytrend' ';']);
eval(['ygap_ 	= oo_.SmoothedVariables.ygap' ';']);

figure(20)
plot(ym,'black')
hold on;
plot(ytrend_,'red')
hold off;
figure(30)
plot(ygap_)

end;