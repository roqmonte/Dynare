%----------------------------------------------------------------
% 1. Model variables and parameters
%----------------------------------------------------------------
var		gpot
		ytrend
		ygap
		ym1
        trend
        cycle;

varexo	e_obs
		e_ytrend
		e_gpot
		e_ygap;

parameters
        rrho
        gpot_ss
		pphi1
        pphi2
        sig_e_obs sig_e_ytrend sig_e_gpot sig_e_ygap;


%----------------------------------------------------------------
% 2. Calibration
%----------------------------------------------------------------
% Calibration of all of the parameters of the model. This is done to
% initialize the estimation, or simlate the model using these parameters.

% Parameters.
rrho		= 0;
gpot_ss     = 0.0075;
pphi1		= 1.100;
pphi2		= -0.300;

% Std of shocks.
sig_e_obs    =  0.003;
sig_e_ytrend =  0.23; %.5;
sig_e_gpot   =  0; % 5
sig_e_ygap   =  1; % normalize

%----------------------------------------------------------------
% 3. Model
%----------------------------------------------------------------
% Linear defines that the model is linear.
model(linear);

%%%%% STOCHASTIC TREND AND SLOPE %%%%%
ytrend =  ytrend(-1)     + gpot(-1)         + e_ytrend/1;
gpot   =  rrho*gpot(-1)  + 0*(1-rrho)*gpot_ss + e_gpot/1;
ygap   =  pphi1*ygap(-1) + pphi2*ygap(-2)   + e_ygap;

%%%%% MEASUREMENT EQUATION %%%%%
ym1	  = ytrend + ygap + e_obs;
trend = ytrend;
cycle = ygap;
end;

steady_state_model;
ytrend  = 7.8;
ym1     = 7.8;
gpot    = gpot_ss;
ygap    = 0;
trend   = 7.8;
cycle   = 0;
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
var e_obs    = sig_e_obs^2;
var e_ytrend = sig_e_ytrend^2;
var e_gpot   = sig_e_gpot^2;
var e_ygap   = sig_e_ygap^2;
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
rrho,  beta_pdf, 0.5, 0.075, 0;
pphi1, beta_pdf, 0.2,  0.075, 0;
pphi2, beta_pdf, 0.2,  0.075, 0;

% Shocks.
stderr e_obs,    inv_gamma_pdf, 0.5, inf;
stderr e_ytrend, inv_gamma_pdf, 0.005, inf;
stderr e_gpot,	 inv_gamma_pdf, 0.05, inf;
stderr e_ygap,	 inv_gamma_pdf, 0.5, inf;
end;

% Declare what variables are observed by the model.
varobs ym1;		

%----------------------------------------------------------------
% 5. Bayesian estimation and forecasting
%----------------------------------------------------------------
options_.console_mode=1; %(default: 0)

estimation(datafile = lv_gdp_data, graph_format = pdf, nodiagnostic, diffuse_filter, 
        mh_drop=.5,  mh_jscale=0.85,mh_replic = 5000, mh_nblocks = 5,
        filtered_vars, smoother,mode_compute = 4, plot_priors = 1,forecast = 0) trend cycle gpot;

%----------------------------------------------------------------
% 6. Reporting
%----------------------------------------------------------------

verbatim;

lv_gdp_data;
% if laplace only
% smoothed
eval(['trend_ 	= oo_.SmoothedVariables.Mean.trend' ';']);
eval(['cycle_ 	= oo_.SmoothedVariables.Mean.cycle' ';']);
eval(['irreg_ 	= oo_.SmoothedShocks.Mean.e_obs' ';']);

figure(20)
plot(ym1,'black')
hold on;
plot(trend_,'red')
hold off;
figure(30)
plot(cycle_)

end;