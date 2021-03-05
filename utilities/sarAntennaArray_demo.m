%% Include Necessary Directories
addpath(genpath("../"));

%% Create the Objects
fmcw = fmcwChirpParameters();
ant = sarAntennaArray(fmcw);

doc sarAntennaArray

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

%% Set Antenna Array Properties
% When the parameters of an antennaArray object are changed by the user, 
% the object automatically updates itself
ant.isEPC = false;
ant.z0_m = 0;
% Antenna array from xWR1x43
ant.tableTx = [
    0   0   1.5 5   1
    0.5 0   2.5 5   0
    0   0   3.5 5   1];
ant.tableRx = [
    0   0   0   0   1
    0   0   0.5 0   1
    0   0   1   0   1
    0   0   1.5 0   1];

% Display the Antenna Array
ant.displayAntennaArray();

%% Load in Saved FMCW Parameters
ant.loadAntennaArray("AWR1243");

%% Save FMCW Parameters
ant.saveAntennaArray("AWR1243_2");