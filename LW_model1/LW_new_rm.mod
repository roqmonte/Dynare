%----------------------------------------------------------------
% 1. Model variables and parameters
%----------------------------------------------------------------
var		gpot
		ytrend
		ygap
		ym
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
% Parameters.
rrho		= 0.8;
gpot_ss     = 0.007;
pphi1		= 0.89;
pphi2		= -0.1617;

% Std of shocks.
sig_e_obs    =  0.003;
sig_e_ytrend =  0.23;
sig_e_gpot   =  0.01;
sig_e_ygap   =  sqrt(1.0645e-04);

%----------------------------------------------------------------
% 3. Model
%----------------------------------------------------------------
model(linear);

%%%%% STOCHASTIC TREND AND SLOPE %%%%%
ytrend =  ytrend(-1)     + gpot(-1)         + e_ytrend;
gpot   =  rrho*gpot(-1)  + (1-rrho)*gpot_ss + e_gpot;
ygap   =  pphi1*ygap(-1) + pphi2*ygap(-2)   + e_ygap;

%%%%% MEASUREMENT EQUATION %%%%%
ym 	  = ytrend + ygap + e_obs;
trend = ytrend;
cycle = ygap;
end;

steady_state_model;
ytrend  = 7.65;
ym      = 7.65;
gpot    = gpot_ss;
ygap    = 0;
trend   = 7.65;
cycle   = 0;
end;
steady(nocheck);


% Defining shocks of the model, by seting up their variances.
shocks;
var e_obs    = sig_e_obs^2;
var e_ytrend = sig_e_ytrend^2;
var e_gpot   = sig_e_gpot^2;
var e_ygap   = sig_e_ygap^2;
end;

% Data simulation
% stoch_simul(drop=1000, periods=1500, IRF = 12);

%----------------------------------------------------------------
% 4. Estimated parameters and data
%----------------------------------------------------------------
% normal_pdf,    mu, sg              Range: R
% gamma_pdf,     mu, sg, lb          Range: [lb,+00]*
% beta_pdf,    , mu, sg, lb, ub      Range: [lb,ub]
% inv_gamma_pdf, mu, sg              Range: R+
% uniform_pdf,   [], []  lb, ub      Range: [lb,ub]

estimated_params;
% Parameters
rrho,  beta_pdf, 0.75, 0.075, 0;
pphi1, beta_pdf, 0.2,  0.075, 0;
pphi2, beta_pdf, 0.2,  0.075, 0;

% Shocks.
stderr e_obs,    inv_gamma_pdf, 0.5, inf;
stderr e_ytrend, inv_gamma_pdf, 0.5, inf;
stderr e_gpot,	 inv_gamma_pdf, 0.5, inf;
stderr e_ygap,	 inv_gamma_pdf, 0.01, inf;
end;

% Declare what variables are observed by the model.
varobs ym;		

%----------------------------------------------------------------
% 5. Bayesian estimation and forecasting
%----------------------------------------------------------------


options_.console_mode=1; %(default: 0)

estimation(datafile = data_load, graph_format = pdf, nodiagnostic, diffuse_filter, 
        mh_drop=.5,  mh_jscale=0.7,mh_replic = 1000, mh_nblocks = 5, 
        filtered_vars, smoother,mode_compute = 4, plot_priors = 1,forecast = 0) trend cycle;

%----------------------------------------------------------------
% 6. Reporting
%----------------------------------------------------------------

verbatim;

data_load;
% if laplace only
% smoothed
eval(['trend_ 	= oo_.SmoothedVariables.trend' ';']);
eval(['cycle_ 	= oo_.SmoothedVariables.cycle' ';']);
eval(['irreg_ 	= oo_.SmoothedShocks.e_obs' ';']);

figure(20)
plot(ym,'black')
hold on;
plot(trend_,'red')
hold off;
figure(30)
plot(cycle_)

end;