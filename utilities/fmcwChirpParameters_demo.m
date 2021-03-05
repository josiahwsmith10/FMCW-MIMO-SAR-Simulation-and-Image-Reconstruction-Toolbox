%% Include Necessary Directories
addpath(genpath("../"));

%% Create the Objects
fmcw = fmcwChirpParameters();

doc fmcwChirpParameters

%% Set FMCW Parameters
% When the parameters of an fmcwChirpParameters object are changed by the
% user, the object automatically updates itself, namely the property 'k'
% and other dependencies of the changed parameters.
fmcw.f0 = 77*1e9;
fmcw.K = 100.036*1e12;
fmcw.IdleTime_s = 0*1e-6;
fmcw.TXStartTime_s = 0*1e-6;
fmcw.ADCStartTime_s = 0*1e-6;
fmcw.ADCSamples = 79;
fmcw.fS = 2000*1e3;
fmcw.RampEndTime_s = 39.98*1e-6;
fmcw.fC = 79*1e9;

%% Load in Saved FMCW Parameters
fmcw.loadChirpParameters("fmcw_v1");

%% Save FMCW Parameters
fmcw.f0 = 60*1e9;
fmcw.fC = 64*1e9;
fmcw.saveChirpParameters("fmcw_v2");